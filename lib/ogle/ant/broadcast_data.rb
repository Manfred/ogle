# frozen_string_literal: true

require 'ogle/ant/device/names'

module Ogle
  class Ant
    class BroadcastData
      attr_reader :data
      attr_reader :extended

      def initialize(data)
        @data = data[0, 8]
        @extended = data[8..-1]
      end

      def device_number
        extended[2] + extended[3] << 8
      end

      def device_type
        Ogle::Ant::Device::NAMES[extended[4]]
      end
    end
  end
end
