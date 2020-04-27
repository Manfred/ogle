# frozen_string_literal: true

require 'ogle/ant/channel'
require 'ogle/ant/event'
require 'ogle/ant/message'

module Ogle
  class Ant
    class StandardError < ::StandardError
    end

    class InvalidOperation < Ogle::Ant::StandardError
      attr_reader :event

      def initialize(event)
        @event = event
      end

      def message
        event.description
      end
    end

    ANTPLUS_PUBLIC_NETWORK = 0x1
    ANTPLUS_NETWORK_KEY = [
      0xb9, 0xa5, 0x21, 0xfb, 0xbd, 0x72, 0xc3, 0x45
    ].freeze
    ANTPLUS_HEARTRATE_NETWORK = 0x78

    CHANNEL_TYPES = {
      two_way_receive: 0x00,
      two_way_transmit: 0x10,
      shared_receive: 0x20,
      shared_transmit: 0x30,
      one_way_receive: 0x40,
      one_way_transmit: 0x50
    }

    attr_reader :device
    attr_reader :handle
    attr_reader :logger

    def initialize(device:, handle:, logger:)
      @device = device
      @handle = handle
      @logger = logger
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
      Ogle::Ant::Channel.new(self, number: number)
    end

    # Sets a channel to scan mode and yields Ant::Message objects.
    def scan(&block)
      channel(0).scan do |message|
        yield message
      end
    end

    def send_system_reset
      write(:system_reset_id, [0x00])
      wait_until_reset
    end

    def wait_until_reset
      loop do
        message = read
        return unless message

        sleep 0.5
      end
    end

    def send_network_key
      write(:network_key_id, [ANTPLUS_PUBLIC_NETWORK] + ANTPLUS_NETWORK_KEY)
      read
    end

    def send_channel_type(number, type:)
      type_id = CHANNEL_TYPES[type]
      raise ArgumentError, "Unknown channel type `#{type}'" unless type_id
      write(:assign_channel_id, [number, type_id, ANTPLUS_PUBLIC_NETWORK, 0x0])
      read
    end

    def send_channel_id(number)
      write(:channel_id_id, [number, 0x0, 0x0, 0x0, 0x0])
      read
    end

    def send_channel_period(number, period:)
      write(:channel_mesg_period_id, [number, period])
      read
    end

    def send_channel_frequency(number, frequency:)
      write(:channel_radio_freq_id, [number, frequency])
      read
    end

    #  Power is 0..4 where 3 = 0dBm.
    def send_tx_power(power)
      write(:radio_tx_power_id, [0x0, power])
      read
    end

    # Set timeout in ticks; a tick is 2.5 seconds
    def send_search_timeout(number, ticks:)
      write(:set_lp_search_timeout_id, [number, ticks])
    end

    def send_antlib_config(number, how:)
      write(:antlib_config_id, [number, Ogle::Ant::Message.id(how)])
    end

    def send_accept_extended_messages
      write(:rx_ext_mesgs_enable_id, [0x0, 0x1])
      read
    end

    def send_enable_scan_mode
      write(:open_rx_scan_id, [0x0, 0x0])
      read
    end

    def send_open_channel(number)
      write(:open_channel_id, [number])
      read
    end

    def send_close_channel(number)
      write(:close_channel_id, [number])
      read
    end

    def message_id(name)
      Ogle::Ant::Message.id(name)
    end

    def calculate_checksum(packet)
      packet.inject(0x00) do |checksum, byte|
        checksum ^ byte
      end
    end

    def packet(message, bytes)
      packet = [
        message_id(:tx_sync),
        bytes.length,
        message_id(message),
        *bytes
      ]
      packet << calculate_checksum(packet)
    end

    def write(message, bytes)
      packet = packet(message, bytes)
      logger.debug('<-- (' + message.to_s + ') ' + Ogle::Ant::Message.format(packet))
      transfer = LIBUSB::InterruptTransfer.new(
        allow_device_memory: true,
        dev_handle: handle,
        endpoint: output_endpoint.bEndpointAddress,
        buffer: packet.pack('C*')
      )
      transfer.submit_and_wait
      unless transfer.status == :TRANSFER_COMPLETED
        raise transfer.status.to_s
      end
    end

    def read
      transfer = LIBUSB::BulkTransfer.new(
        timeout: 5000,
        allow_device_memory: true,
        dev_handle: handle,
        endpoint: input_endpoint.bEndpointAddress
      )
      transfer.alloc_buffer(1024)
      transfer.submit_and_wait
      case transfer.status
      when :TRANSFER_COMPLETED
        packet = transfer.actual_buffer
        message = Ogle::Ant::Message.parse(packet)
        logger.debug('--> ' + Ogle::Ant::Message.format(message.data))
        logger.debug(' M: ' + message.attributes.inspect)
        if (exception = message.to_exception)
          raise exception
        else
          message
        end
      when :TRANSFER_TIMED_OUT
        nil
      else
        raise transfer.status.to_s
      end
    end
  end
end
