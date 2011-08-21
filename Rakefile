require 'rake/testtask'
require 'yard'
require "bundler/gem_tasks"

task :default => ['coverage:console']

Rake::TestTask.new
YARD::Rake::YardocTask.new

namespace :coverage do
  desc "Generates and outputs code coverage report."
  task :console => :test do
    require 'cover_me'
    CoverMe.config do |conf|
      conf.formatter = CoverMe::ConsoleFormatter
    end
    CoverMe.complete!
  end

  desc "Generates and opens code coverage report."
  task :html => :test do
    require 'cover_me'
    CoverMe.config do |conf|
      conf.formatter = CoverMe::HtmlFormatter
    end
    CoverMe.complete!
  end
end
