require 'rake'
require 'rake/clean'
require 'rake/testtask'

CLEAN.include("**/*.gem")

namespace :gem do
  desc 'Create the win32-semaphore gem'
  task :create => [:clean] do
    require 'rubygems/package'
    spec = eval(IO.read('win32-semaphore.gemspec'))
    spec.signing_key = File.join(Dir.home, '.ssh', 'gem-private_key.pem')
    Gem::Package.build(spec, true)
  end

  desc 'Install the win32-semaphore gem'
  task :install => [:create] do
    file = Dir["*.gem"].first
    sh "gem install -l #{file}"
  end
end

desc 'Run the example program'
task :example do
  ruby '-Ilib examples/example_semaphore.rb'
end

Rake::TestTask.new do |t|
  t.verbose = true
  t.warning = true
end

task :default => :test
