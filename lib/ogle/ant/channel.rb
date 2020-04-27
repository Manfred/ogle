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

      def enable_scan_mode
        ant.send_network_key
        ant.send_channel_type(number, type: :two_way_receive)
        ant.send_channel_id(number)
        ant.send_channel_frequency(number, frequency: 57)
        # ant.send_channel_period(number, period: 32768)
        # ant.send_tx_power(3)
        # ant.send_search_timeout(0, ticks: 255)
        # ant.send_antlib_config(number, how: :ext_id_0)
        # ant.send_accept_extended_messages
        ant.send_enable_scan_mode
      end

      def scan
        enable_scan_mode
        loop do
          if message = ant.read
            yield message
          end
        end
      ensure
        close
      end

      def close
        ant.send_close_channel(number)
      end
    end
  end
end
