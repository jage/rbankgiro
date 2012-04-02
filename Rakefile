require 'rake'
require 'rake/testtask'
require 'bundler/gem_tasks'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
end

task :default => :test