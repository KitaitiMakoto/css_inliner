require 'rake/testtask'
require 'yard'
require "bundler/gem_tasks"

task :default => [:test]

Rake::TestTask.new
YARD::Rake::YardocTask.new

desc "Generates and opens code coverage report."
namespace :cover_me do
  task :report => :test do
    require 'cover_me'
    CoverMe.config do |conf|
      conf.at_exit = proc {`opera coverage/index.html`}
    end
    CoverMe.complete!
  end
end
