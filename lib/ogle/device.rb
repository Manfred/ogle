# frozen_string_literal: true

require 'libusb'

module Ogle
  class Device
    def self.first
      context = LIBUSB::Context.new
      context.set_option(LIBUSB::OPTION_LOG_LEVEL, LIBUSB::LOG_LEVEL_INFO)
      device = context.devices(idProduct: 0x1008).first
      device.open_interface(0) do |handle|
        yield [device, handle]
      end
    end
  end
end
