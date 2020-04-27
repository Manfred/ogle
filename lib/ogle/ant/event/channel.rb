# frozen_string_literal: true

require 'ogle/ant/event/channel_events'

module Ogle
  class Ant
    class Event
      class Channel
        attr_reader :data

        def initialize(data)
          @data = data
        end

        def failed?
          data[0] == 0x0
        end

        def response_to
          Ogle::Ant::Event.name(data[1])
        end

        def result
          Ogle::Ant::Event::CHANNEL_EVENTS[data[2]]
        end

        def name
          result[0]
        end

        def description
          result[1]
        end

        def to_exception
          case name
          when 'invalid_message'
            Ogle::Ant::InvalidOperation.new(self)
          end
        end

        def attributes
          { name: name, description: description }
        end
      end
    end
  end
end
