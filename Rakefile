require 'rspec/core/rake_task'
require "bundler/gem_tasks"

# Default directory to look in is `/specs`
# Run with `rake spec`
RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = ['--color', '--format', 'documentation']
end

task :install_gem do
  system "gem build live_paper.gemspec"
  system "gem install live_paper-0.0.32.gem"
end

task :default => :spec
