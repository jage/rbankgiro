$:.unshift File.expand_path('../lib', __FILE__)
require 'rbankgiro/version'

spec = Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'rbankgiro'
  s.version     = Rbankgiro::VERSION
  s.author      = 'Johan Eckerström'
  s.email       = 'johan@duh.se'
  s.summary     = 'Parse Bankgiro transaction files'
  s.description = 'Parsing transaction files from swedish Bankgiro central'
  s.homepage    = 'https://github.com/jage/rbankgiro'

  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.MD']

  # Tests
  s.add_development_dependency('rake', '~> 0.9.2')

  s.require_path = 'lib'
  s.files = Dir.glob('lib/*')
  s.test_files = Dir.glob('test/*')
end