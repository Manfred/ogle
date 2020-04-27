# frozen_string_literal: true

require 'logger'
require 'ogle/ant'
require 'ogle/ant/broadcast_data'
require 'ogle/device'

module Ogle
  class Scanner
    attr_reader :logger

    def initialize
      @running = true
      @logger = Logger.new('ant.log')
    end

    def running?
      @running
    end

    def run
      Ogle::Device.first do |device, handle|
        ant = Ogle::Ant.new(
          logger: logger, device: device, handle: handle
        )
        #ant.send_system_reset
        while(running?)
          ant.scan do |message|
            handle(message)
          end
        end
      end
    end

    private

    def handle(message)
      case message.name
      when 'broadcast_data_id'
        m = Ogle::Ant::BroadcastData.new(message.data[3..-1])
        puts [m.device_type, m.device_number]
      end
    end
  end
end
