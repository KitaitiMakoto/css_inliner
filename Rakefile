require 'rake/testtask'
require 'yard'
require "bundler/gem_tasks"

task :default => [:test]

Rake::TestTask.new
YARD::Rake::YardocTask.new

desc "Generates and opens code coverage report."
namespace :cover_me do
  task :report do
    begin
      require 'cover_me'
      CoverMe.complete!
    rescue LoadError
    end
  end
end

task :test do
  Rake::Task['cover_me:report'].invoke
end
