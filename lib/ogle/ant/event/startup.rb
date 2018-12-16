# frozen_string_literal: true

module Ogle
  class Ant
    class Event
      class Startup
        FLAGS = {
          0 => 'Hardware reset line',
          1 => 'Watch dog reset',
          5 => 'Command reset',
          6 => 'Synchronous reset',
          7 => 'Suspend reset'
        }

        attr_reader :data

        def initialize(data)
          @data = data
        end

        def to_exception
          nil
        end

        def flag_byte
          data[0]
        end

        def flags
          flags = []
          FLAGS.each do |bit, flag|
            flags << flag if flag_byte & (0x01 << bit)
          end
          flags
        end

        def attributes
          { flags: flags }
        end
      end
    end
  end
end
