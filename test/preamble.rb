# frozen_string_literal: true

require 'pathname'
require 'minitest/autorun'
require 'minitest/assert_errors'

$LOAD_PATH << File.expand_path('../lib', __dir__)
require 'ogle'

def load_support
  root = File.expand_path('..', __dir__)
  Dir[File.join(root, 'test/support/**/*.rb')].each { |file| require file }
end
load_support

class Minitest::Test
  protected

  def test_root
    Pathname.new(File.expand_path(__dir__))
  end
end
