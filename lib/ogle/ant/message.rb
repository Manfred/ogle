# frozen_string_literal: true

require 'ogle/ant/message/ids'
require 'ogle/ant/message/names'

module Ogle
  class Ant
    class Message
      attr_reader :data
      attr_reader :operation
      attr_reader :length
      attr_reader :id

      def initialize(data)
        @data = data
        @operation = self.class.operation(data[0])
        @length = data[1]
        @id = data[2]
      end

      def name
        self.class.name(id)
      end

      def event
        Ogle::Ant::Event.new(data[2..-1])
      end

      def to_exception
        event&.to_exception
      end

      def attributes
        {
          operation: operation,
          length: length,
          name: name,
          event: event&.attributes
        }.compact
      end

      def self.operation(message_id)
        case message_id
        when 0xa4
          :transmit
        when 0xa5
          :receive
        else
          raise(
            ArgumentError,
            "ANT message started with invalid message ID: `#{message_id}'"
          )
        end
      end

      def self.id(name)
        Ogle::Ant::Message::IDS[name]
      end

      def self.name(id)
        Ogle::Ant::Message::NAMES[id]
      end

      def self.format(bytes)
        bytes.map { |byte| byte.to_s(16).rjust(2, '0') }.join(' ')
      end

      def self.pack(bytes)
        bytes.pack('C*')
      end

      def self.unpack(input)
        input.strip.unpack('C*')
      end

      def self.parse(input)
        new(unpack(input))
      end
    end
  end
end
