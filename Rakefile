require 'rubygems'
require 'rake'
require 'rake/testtask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "rbankgiro"
    gemspec.summary = "Parse Bankgiro transaction files"
    gemspec.description = "Parsing transaction files from swedish Bankgiro central"
    gemspec.email = "johan@duh.se"
    gemspec.homepage = "http://github.com/jage/rbankgiro"
    gemspec.authors = ["Johan Eckerström"]
    gemspec.files = FileList['lib/rbankgiro.rb']
  end
rescue LoadError
  $stderr.puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test