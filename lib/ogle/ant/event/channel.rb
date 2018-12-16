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

        def id
          data[0]
        end

        def definition
          Ogle::Ant::Event::CHANNEL_EVENTS[id]
        end

        def name
          definition[0]
        end

        def description
          definition[1]
        end

        def to_exception
          case name
          when 'rx_search_timeout', 'close_all_channels'
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
