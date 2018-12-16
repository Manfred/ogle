# frozen_string_literal: true

require 'ogle/ant/event/channel'
require 'ogle/ant/event/names'
require 'ogle/ant/event/startup'

module Ogle
  class Ant
    class Event
      attr_reader :data
      attr_reader :id

      def initialize(data)
        @data = data
        @id = data[0]
      end

      def name
        self.class.name(id)
      end

      def details
        case name
        when 'startup'
          Ogle::Ant::Event::Startup.new(data[1..-1])
        when 'channel_event'
          Ogle::Ant::Event::Channel.new(data[1..-1])
        end
      end

      def attributes
        {
          name: name,
          details: details&.attributes
        }.compact
      end

      def to_exception
        details&.to_exception
      end

      def self.name(id)
        Ogle::Ant::Event::NAMES[id]
      end
    end
  end
end
