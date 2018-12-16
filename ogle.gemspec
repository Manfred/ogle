# frozen_string_literal: true

require File.expand_path('lib/ogle/version', __dir__)

Gem::Specification.new do |spec|
  spec.name = 'ogle'
  spec.version = Ogle::VERSION
  spec.authors = [
    'Manfred Stienstra'
  ]
  spec.email = [
    'manfred@fngtps.com'
  ]
  spec.summary = <<-EOF
  ANT+ library.
  EOF
  spec.description = <<-EOF
  Ogle allows you to talk ANT+ through an ANT+ adapter connected to your USB
  buss.
  EOF
  spec.homepage = 'https://github.com/manfred/ogle'
  spec.license = 'MIT'

  spec.files = [
    'LICENSE.txt',
    'lib/ogle.rb',
    'lib/ogle/message.rb',
    'lib/ogle/message/ids.rb',
    'lib/ogle/message/names.rb',
    'lib/ogle/version.rb'
  ]
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1'
  spec.add_development_dependency 'rake', '~> 12'
  spec.add_development_dependency 'minitest-assert_errors'

  spec.add_dependency 'libusb'
end
