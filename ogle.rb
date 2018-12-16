# require 'libusb'
#
# class Ant
#   MESSAGES = {
#     sync_tx: 0xa4,
#     reset_system: 0x4a,
#     startup: 0x6f,
#     network_key: 0x46,
#     rx_scan_mode: 0x5b,
#
#     channel_type: 0x42,
#     channel_id: 0x51,
#     channel_frequency: 0x45,
#     open_channel: 0x4b,
#     close_channel: 0x4c,
#
#     accept_extended_messages: 0x66,
#     config_lib: 0x6e,
#
#     ext_channel_id: 0x80,
#     ext_rssi: 0x40,
#     ext_timestamp: 0x20,
#
#     two_way_receive: 0x00,
#     two_way_transmit: 0x10,
#     shared_receive: 0x20,
#     shared_transmit: 0x30,
#     one_way_receive: 0x40,
#     one_way_transmit: 0x50,
#
#     broadcast: 0x4e,
#
#     speed_and_cadance: 0x79,
#     power: 0x0b
#   }
#
#   RESPONSES = {
#     0x5b => :open_rx_scan_mode,
#     0x6f => :startup,
#     0x40 => :channel_event
#   }
#
#   ANTPLUS_NETWORK_KEY = "\xB9\xA5\x21\xFB\xBD\x72\xC3\x45".unpack('C*')
#   ANTPLUS_PUBLIC_NETWORK = 0x00
#
#   class Event
#     def self.new(name, data:)
#       case name
#       when :startup
#         Ant::Startup.new(data)
#       when :channel_event
#         Ant::ChannelEvent.new(data)
#       else
#         raise ArgumentError, "Unus"
#       end
#     end
#   end
#
#   class Startup
#     REASONS = {
#       0 => 'Hardware reset line',
#       1 => 'Watch dog reset',
#       5 => 'Command reset',
#       6 => 'Synchronous reset',
#       7 => 'Suspend reset'
#     }
#
#     attr_reader :data
#
#     def initialize(data)
#       @data = data
#     end
#
#     def reason_byte
#       data[0]
#     end
#
#     def reasons
#       reasons = []
#       REASONS.each do |bit, reason|
#         reasons << reason if reason_byte & (0x01 << bit)
#       end
#       reasons
#     end
#
#     def attributes
#       {
#         reasons: reasons
#       }
#     end
#   end
#
#   class ChannelEvent
#     CHANNEL_EVENT = {
#       0x00 => [
#         :no_error,
#         'Returned on a successful operation'
#       ],
#       0x01 => [
#         :rx_search_timeout,
#         'A receive channel has timed out on searching. The search is terminated, and the channel has been automatically closed. In order to restart the search the Open Channel message must be sent again.'
#       ],
#       0x02 => [
#         :rx_fail,
#         'A receive channel missed a message which it was expecting. This happens when a follower is tracking a primary and is expecting a message at the set message rate.'
#       ],
#       0x03 => [
#         :tx,
#         'A Broadcast message has been transmitted successfully. This event should be used to send the next message for transmission to the ANT device if the node is setup as a primary.'
#       ],
#       0x04 => [
#         :transfer_rx_failed,
#         'A receive transfer has failed. This occurs when a Burst Transfer Message was incorrectly received.'
#       ],
#       0x05 => [
#         :transfer_tx_completed,
#         'An Acknowledged Data message or a Burst Transfer sequence has been completed successfully. When transmitting Acknowledged Data or Burst Transfer, there is no EVENT_TX message.'
#       ],
#       0x06 => [
#         :transfer_tx_failed,
#         'An Acknowledged Data message, or a Burst Transfer Message has been initiated and the transmission failed to complete successfully.'
#       ],
#       0x07 => [
#         :channel_closed,
#         'The channel has been successfully closed. When the Host sends a message to close a channel, it first receives a RESPONSE_NO_ERROR to indicate that the message was successfully received by ANT; however, EVENT_CHANNEL_CLOSED is the actual indication of the closure of the channel. As such, the Host must use this event message rather than the RESPONSE_NO_ERROR message to let a channel state machine continue.'
#       ],
#       0x08 => [
#         :rx_fail_go_to_search,
#         'The channel has dropped to search mode after missing too many messages.'
#       ],
#       0x09 => [
#         :channel_collision,
#         'Two channels have drifted into each other and overlapped in time on the device causing one channel to be blocked.'
#       ],
#       0x0a => [
#         :transfer_tx_start,
#         'Sent after a burst transfer begins, effectively on the next channel period after the burst transfer message has been sent to the device.'
#       ],
#       0x11 => [
#         :transfer_next_data_block,
#         'Returned to indicate a data block release on the burst buffer.'
#       ],
#       0x15 => [
#         :wrong_state,
#         'Returned on attempt to perform an action on a channel that is not valid for the channel’s state.'
#       ],
#       0x16 => [
#         :not_opened,
#         'Attempted to transmit data on an unopened channel.'
#       ],
#       0x18 => [
#         :channel_id_not_set,
#         'Returned on attempt to open a channel before setting a valid ID.'
#       ],
#       0x19 => [
#         :close_all_channels,
#         'Returned when an OpenRxScanMode() command is sent while other channels are open.'
#       ],
#       0x1f => [
#         :transfer_in_progress,
#         'Returned on an attempt to communicate on a channel with a transmit transfer in progress.'
#       ],
#       0x20 => [
#         :transfer_sequence_number_error,
#         'Returned when sequence number is out of order on a Burst Transfer.'
#       ],
#       0x21 => [
#         :transfer_in_error,
#         'Returned when a burst message passes the sequence number check but will not be transmitted due to other reasons.'
#       ],
#       0x27 => [
#         :message_size_exceeded_limit,
#         'Returned if a data message is provided that is too large.'
#       ],
#       0x28 => [
#         :invalid_message,
#         'Returned when message has invalid parameters.'
#       ],
#       0x30 => [
#         :invalid_network_number,
#         'Returned when an invalid network number is provided. As mentioned earlier, valid network numbers are between 0 and MAX_NET-1.'
#       ],
#       0x31 => [
#         :invalid_scan_tx_channel,
#         'Returned when attempting to transmit on ANT channel 0 in scan mode.'
#       ],
#       0x33 => [
#         :invalid_parameter_provided,
#         'Returned when invalid configuration commands are requested.'
#       ],
#       0x34 => [
#         :serial_que_overflow,
#         'This event indicates that the outgoing serial buffer of the USB chip has overflowed. This typically happens if the ANT chip is actively generating serial messages but the PC application is stalled/not running. This event is sent to notify the host application that the message buffer was full and some messages were lost.'
#       ],
#       0x35 => [
#         :event_que_overflow,
#         'May be possible when using synchronous serial port, or using all channels on a slow asynchronous connection. Indicates that one or more events were lost due to excessive latency in reading events out over the serial port. This typically happens if the serial queue is full.'
#       ],
#       0x38 => [
#         :encrypt_negotiation_success,
#         'When an ANT follower has negotiated successfully with an encrypted ANT primary this event is passed to both the primary and the follower.'
#       ],
#       0x39 => [
#         :encrypt_negotiation_fail,
#         'When an ANT slave fails negotiation with an encrypted ANT master this event is passed to both the master and the slave. This can occur due to configuration mismatch, poor RF, mismatched encryption keys, or white/blacklisting by the master .'
#       ],
#       0x40 => [
#         :nvm_full_error,
#         'Returned when the NVM for SensRcore mode is full.'
#       ],
#       0x41 => [
#         :nvm_write_error,
#         'Returned when writing to the NVM for SensRcore mode fails.'
#       ],
#       0x70 => [
#         :usb_string_write_fail,
#         'Returned when configuration of a USB descriptor string fails.'
#       ],
#       0xae => [
#         :mesg_serial_error_id,
#         <<~SERIAL_ERROR_ID
#           This message is generated if the ANT chip receives a USB data packet that is not correctly formatted. The data portion of this message may be used to debug the USB packet.
#           The first byte of the data (usually channel number) is the error number.
#           0 – the first byte of the USB data packet was not the ANT serial message Tx sync byte (0xA4)
#           2 – the checksum of the ANT message was incorrect
#           3 – the size of the ANT message was too large
#           The rest of the data is a copy of the message that was sent.
#         SERIAL_ERROR_ID
#       ]
#     }
#
#     attr_reader :data
#
#     def initialize(data)
#       @data = data
#     end
#
#     def name_id
#       data[0]
#     end
#
#     def name
#       CHANNEL_EVENT[name_id][0]
#     end
#
#     def description
#       CHANNEL_EVENT[name_id][1]
#     end
#
#     def attributes
#       {
#         name: name,
#         description: description
#       }
#     end
#   end
#
#   class Message
#     attr_reader :data
#
#     def initialize(input)
#       @data = input.unpack('C*')
#       validate_message
#     end
#
#     def to_s
#       self.class.format(data)
#     end
#
#     def length
#       data[1]
#     end
#
#     def name_id
#       data[2]
#     end
#
#     def name
#       RESPONSES[name_id]
#     end
#
#     def event
#       Ant::Event.new(name, data: data[3..-1])
#     end
#
#     def attributes
#       {
#         length: length,
#         name: name,
#         event: event&.attributes
#       }.compact
#     end
#
#     def validate_message
#       if data[0] != Ant::MESSAGES[:sync_tx]
#         raise ArgumentError, "Got unsupported data: `#{to_s}'"
#       end
#     end
#
#     def self.format(data)
#       data.map { |byte| byte.to_s(16).rjust(2, '0') }.join(' ')
#     end
#   end
#
#   class Channel
#     attr_reader :ant
#     attr_reader :channel
#
#     def initialize(ant, channel:)
#       @ant = ant
#       @channel = channel
#     end
#
#     def start_scan
#       ant.send_network_key(channel)
#       ant.send_channel_type(channel, type: :one_way_receive)
#       ant.send_channel_id(channel)
#       ant.send_channel_frequency(channel, frequency: 66)
#       ant.send_accept_extended_messages
#       ant.send_enable_scan_mode
#     end
#
#     def scan
#       start_scan
#       while(42)
#         if data = ant.read
#           yield
#         end
#       end
#     end
#   end
#
#   attr_reader :device
#   attr_reader :handle
#
#   def initialize(device:, handle:)
#     @device = device
#     @handle = handle
#   end
#
#   def endpoints
#     device.endpoints
#   end
#
#   def output_endpoint
#     @output_endpoint ||= endpoints.find do |endpoint|
#       endpoint.direction == :out
#     end
#   end
#
#   def input_endpoint
#     @input_endpoint ||= endpoints.find do |endpoint|
#       endpoint.direction == :in
#     end
#   end
#
#   def channel(number)
#     Ant::Channel.new(self, channel: number)
#   end
#
#   def send_system_reset
#     result = write(:reset_system, [0x00])
#     pp result
#   end
#
#   def send_network_key(number)
#     write(:network_key, ANTPLUS_NETWORK_KEY << number)
#   end
#
#   def send_channel_type(number, type:)
#     type_id = message_id(type)
#     raise ArgumentError, "Unknown channel type `#{type}'" unless type_id
#     write(:channel_type, [number, type_id, ANTPLUS_PUBLIC_NETWORK])
#   end
#
#   def send_channel_id(number)
#     write(:channel_id, [number, 0x00, 0x00, 0x00, 0x00])
#   end
#
#   def send_channel_frequency(number, frequency:)
#     write(:channel_frequency, [number, 2400 + frequency])
#   end
#
#   def send_accept_extended_messages
#     write(:accept_extended_messages, [0x01])
#   end
#
#   def send_enable_scan_mode
#     write(:rx_scan_mode, [0x00])
#   end
#
#   def message_id(name)
#     MESSAGES[name]
#   end
#
#   def calculate_checksum(packet)
#     packet.inject(0x00) do |checksum, byte|
#       checksum ^ byte
#     end
#   end
#
#   def packet(message, bytes)
#     packet = []
#     packet << message_id(:sync_tx)
#     packet << bytes.length
#     packet << message_id(message)
#     packet.concat bytes
#     packet << calculate_checksum(packet)
#   end
#
#   def write(message, bytes)
#     packet = packet(message, bytes)
#     puts '<-- ' + Ant::Message.format(packet)
#     transfer = LIBUSB::InterruptTransfer.new(
#       allow_device_memory: true,
#       dev_handle: handle,
#       endpoint: output_endpoint.bEndpointAddress,
#       buffer: packet.pack('C*')
#     )
#     transfer.submit_and_wait
#     if transfer.status == :TRANSFER_COMPLETED
#       Ant::Message.new(transfer.actual_buffer)
#     else
#       raise transfer.status.to_s
#     end
#   end
#
#   def read
#     transfer = LIBUSB::BulkTransfer.new(
#       timeout: 5000,
#       allow_device_memory: true,
#       dev_handle: handle,
#       endpoint: input_endpoint.bEndpointAddress
#     )
#     transfer.alloc_buffer(1024)
#     transfer.submit_and_wait
#     if transfer.status == :TRANSFER_COMPLETED
#       Ant::Message.new(transfer.actual_buffer)
#     end
#   end
#
#   class Monitor
#     attr_reader :device
#     attr_accessor :running
#
#     def initialize
#       @device = find_device
#       @running = true
#     end
#
#     def find_device
#       context = LIBUSB::Context.new
#       context.set_option(LIBUSB::OPTION_LOG_LEVEL, LIBUSB::LOG_LEVEL_INFO)
#       context.devices(idProduct: 0x1008).first
#     end
#
#     def handle_channel_event(event)
#       case event.name
#       when :close_all_channels
#         throw :reset
#       end
#     end
#
#     def handle(message)
#       puts '--> ' + message.to_s
#       pp message.attributes
#       case message.name
#       when :channel_event
#         handle_channel_event(message.event)
#       end
#     end
#
#     def run
#       return unless device
#
#       device.open_interface(0) do |handle|
#         while(running)
#           catch(:reset) do
#             ant = Ant.new(device: device, handle: handle)
#             channel = ant.channel(0)
#             channel.scan do |message|
#               handle(message)
#             end
#           end
#         end
#       end
#     end
#   end
# end
#
# Ant::Monitor.new.run
