require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new

desc 'Open an irb session preloaded with the library'
task :console do
  sh "irb -rubygems -r hkdf -I lib"
end

task :default => :spec
