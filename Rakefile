require 'rake/testtask'
require 'yard'
require "bundler/gem_tasks"

task :default => ['test:all']

namespace :test do
  task :all => [:test, :report]

  Rake::TestTask.new

  desc 'Generate coverage report'
  task :report do
    require 'cover_me'
    CoverMe.complete!
  end
end

YARD::Rake::YardocTask.new
