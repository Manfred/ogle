# frozen_string_literal: true

module Ogle
  class Ant
    class Device
      def initialize(data)
        @data = data
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
