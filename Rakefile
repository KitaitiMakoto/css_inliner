require 'rake/testtask'
require 'yard'
require "bundler/gem_tasks"

task :default => [:test]

Rake::TestTask.new do |test|
  test.pattern = 'test/**/*_test.rb'
end

YARD::Rake::YardocTask.new do |task|
  task.files += Dir['lib/**/*.rb']
end
