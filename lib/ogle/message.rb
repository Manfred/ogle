# frozen_string_literal: true

require 'ogle/message/ids'
require 'ogle/message/names'

module Ogle
  class Message
    attr_reader :id
    attr_reader :data

    def initialize(id, data:)
      @id = id
      @data = data
    end

    def name
      Ogle::Message::NAMES[id]
    end
  end
end
