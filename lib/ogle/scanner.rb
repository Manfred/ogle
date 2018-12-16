# frozen_string_literal: true

require 'logger'
require 'ogle/ant'
require 'ogle/device'

module Ogle
  class Scanner
    attr_reader :logger

    def initialize
      @running = true
      @logger = Logger.new(STDERR)
    end

    def running?
      @running
    end

    def run
      Ogle::Device.first do |device, handle|
        ant = Ogle::Ant.new(
          logger: logger, device: device, handle: handle
        )
        while(running?)
          ant.scan do |message|
            handle(message)
          end
        end
      end
    end

    private

    def handle(message)
    end
  end
end
