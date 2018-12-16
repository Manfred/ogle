# frozen_string_literal: true

module Ogle
  class Ant
    class Event
      NAMES = {
        0x5b => 'open_rx_scan_mode',
        0x6f => 'startup',
        0x40 => 'channel_event'
      }
    end
  end
end
