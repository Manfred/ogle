# frozen_string_literal: true

module Ogle
  class Ant
    class Channel
      attr_reader :ant
      attr_reader :number

      def initialize(ant, number:)
        @ant = ant
        @number = number
      end

      def prepare_for_scan
        ant.send_system_reset
        ant.send_network_key(number)
        ant.send_channel_type(number, type: :one_way_receive)
        ant.send_channel_id(number)
        ant.send_channel_frequency(number, frequency: 57)
        ant.send_accept_extended_messages
      rescue Ogle::Ant::InvalidOperation => error
        if error.event.name == 'close_all_channels'
          ant.send_close_channel(number)
          retry
        else
          raise
        end
      end

      def enable_scan_mode
        ant.send_enable_scan_mode
      rescue Ogle::Ant::InvalidOperation => error
        if error.event.name == 'rx_search_timeout'
          sleep 5
          retry
        else
          raise
        end
      end

      def scan
        prepare_for_scan
        enable_scan_mode
        while(42)
          if message = ant.read
            yield message
          end
        end
      end
    end
  end
end
