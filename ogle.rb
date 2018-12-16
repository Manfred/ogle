require 'libusb'

class Ant
  MESSAGES = {
  	sync_tx: 0xa4,
    reset_system: 0x4a,
    startup: 0x6f,
    network_key: 0x46,
    rx_scan_mode: 0x5b,

    channel_type: 0x42,
    channel_id: 0x51,
    channel_frequency: 0x45,
    open_channel: 0x4b,
    close_channel: 0x4c,

  	accept_extended_messages: 0x66,
    config_lib: 0x6e,

    ext_channel_id: 0x80,
    ext_rssi: 0x40,
    ext_timestamp: 0x20,

    two_way_receive: 0x00,
  	two_way_transmit: 0x10,
    shared_receive: 0x20,
    shared_transmit: 0x30,
    one_way_receive: 0x40,
    one_way_transmit: 0x50,

    broadcast: 0x4e,

    speed_and_cadance: 0x79,
    power: 0x0b
  }

  RESPONSES = {
    0x6f => :startup,
    0x40 => :channel_event
  }

  ANTPLUS_NETWORK_KEY = "\xB9\xA5\x21\xFB\xBD\x72\xC3\x45".unpack('C*')
  ANTPLUS_PUBLIC_NETWORK = 0x00

  class Startup
    REASONS = {
      0 => 'Hardware reset line',
      1 => 'Watch dog reset',
      5 => 'Command reset',
      6 => 'Synchronous reset',
      7 => 'Suspend reset'
    }

    attr_reader :data

    def initialize(data)
      @data = data
    end

    def reason_byte
      data[0]
    end

    def reasons
      reasons = []
      REASONS.each do |bit, reason|
        reasons << reason if reason_byte & (0x01 << bit)
      end
      reasons
    end

    def attributes
      {
        reasons: reasons
      }
    end
  end

  class ChannelEvent
    CHANNEL_EVENT = {
      0x19 => [
        :close_all_channels,
        'Returned when an OpenRxScanMode() command is sent while other channels are open.'
      ]
    }

    attr_reader :data

    def initialize(data)
      @data = data
    end

    def name_id
      data[0]
    end

    def name
      CHANNEL_EVENT[name_id][0]
    end

    def description
      CHANNEL_EVENT[name_id][1]
    end

    def attributes
      {
        name: name,
        description: description
      }
    end
  end

  class Message
    attr_reader :data

    def initialize(input)
      @data = input.unpack('C*')
      validate_message
    end

    def to_s
      self.class.format(data)
    end

    def length
      data[1]
    end

    def name_id
      data[2]
    end

    def name
      RESPONSES[name_id]
    end

    def event
      case name
      when :startup
        Ant::Startup.new(data[3..-1])
      when :channel_event
        Ant::ChannelEvent.new(data[3..-1])
      end
    end

    def attributes
      {
        length: length,
        name: name,
        event: event&.attributes
      }.compact
    end

    def validate_message
      if data[0] != Ant::MESSAGES[:sync_tx]
        raise ArgumentError, "Got unsupported data: `#{to_s}'"
      end
    end

    def self.format(data)
      data.map { |byte| byte.to_s(16).rjust(2, '0') }.join(' ')
    end
  end

  class Channel
    attr_reader :ant
    attr_reader :channel

    def initialize(ant, channel:)
      @ant = ant
      @channel = channel
    end

    def start_scan
      ant.send_network_key(channel)
      ant.send_channel_type(channel, type: :one_way_receive)
      ant.send_channel_id(channel)
      ant.send_channel_frequency(channel, frequency: 66)
      ant.send_accept_extended_messages
      ant.send_enable_scan_mode
    end

    def scan
      start_scan
      while(42)
        if data = ant.read
          yield Ant::Message.new(data)
        end
      end
    end
  end

  attr_reader :device
  attr_reader :handle

  def initialize(device:, handle:)
    @device = device
    @handle = handle
    send_system_reset
  end

  def endpoints
    device.endpoints
  end

  def output_endpoint
    @output_endpoint ||= endpoints.find do |endpoint|
      endpoint.direction == :out
    end
  end

  def input_endpoint
    @input_endpoint ||= endpoints.find do |endpoint|
      endpoint.direction == :in
    end
  end

  def channel(number)
    Ant::Channel.new(self, channel: number)
  end

  def send_system_reset
    write(:reset_system, [0x00])
  end

  def send_network_key(number)
    write(:network_key, ANTPLUS_NETWORK_KEY << number)
  end

  def send_channel_type(number, type:)
    type_id = message_id(type)
    raise ArgumentError, "Unknown channel type `#{type}'" unless type_id
    write(:channel_type, [number, type_id, ANTPLUS_PUBLIC_NETWORK])
  end

  def send_channel_id(number)
    write(:channel_id, [number, 0x00, 0x00, 0x00, 0x00])
  end

  def send_channel_frequency(number, frequency:)
    write(:channel_frequency, [number, 2400 + frequency])
  end

  def send_accept_extended_messages
    write(:accept_extended_messages, [0x01])
  end

  def send_enable_scan_mode
    write(:rx_scan_mode, [0x00])
  end

  def message_id(name)
    MESSAGES[name]
  end

  def calculate_checksum(packet)
    packet.inject(0x00) do |checksum, byte|
      checksum ^ byte
    end
  end

  def packet(message, bytes)
    packet = []
    packet << message_id(:sync_tx)
    packet << bytes.length
    packet << message_id(message)
    packet.concat bytes
    packet << calculate_checksum(packet)
  end

  def write(message, bytes)
    packet = packet(message, bytes)
    puts '<-- ' + Ant::Message.format(packet)
    transfer = LIBUSB::InterruptTransfer.new(
      allow_device_memory: true,
      dev_handle: handle,
      endpoint: output_endpoint.bEndpointAddress,
      buffer: packet.pack('C*')
    )
    transfer.submit_and_wait
    if transfer.status == :TRANSFER_COMPLETED
      transfer.actual_buffer
    else
      raise transfer.status.to_s
    end
  end

  def read
    transfer = LIBUSB::BulkTransfer.new(
      allow_device_memory: true,
      dev_handle: handle,
      endpoint: input_endpoint.bEndpointAddress
    )
    transfer.alloc_buffer(1024)
    transfer.submit_and_wait
    if transfer.status == :TRANSFER_COMPLETED
      transfer.actual_buffer
    end
  end

  class Monitor
    attr_reader :device

    def initialize
      @device = find_device
    end

    def find_device
      context = LIBUSB::Context.new
      context.set_option(LIBUSB::OPTION_LOG_LEVEL, LIBUSB::LOG_LEVEL_INFO)
      context.devices(idProduct: 0x1008).first
    end

    def handle_channel_event(event)
      case event.name
      when :close_all_channels
        exit -1
      end
    end

    def handle(message)
      puts '--> ' + message.to_s
      pp message.attributes
      case message.name
      when :channel_event
        handle_channel_event(message.event)
      end
    end

    def run
      device.open_interface(0) do |handle|
        ant = Ant.new(device: device, handle: handle)
        channel = ant.channel(1)
        channel.scan do |message|
          handle(message)
        end
      end
    end
  end
end

Ant::Monitor.new.run