require 'rubygems'

spec = Gem::Specification.new do |gem|
   gem.name        = 'win32-semaphore'
   gem.version     = '0.3.1'
   gem.author      = 'Daniel J. Berger'
   gem.license     = 'Artistic 2.0'
   gem.email       = 'djberg96@gmail.com'
   gem.homepage    = 'http://www.rubyforge.org/projects/win32utils'
   gem.platform    = Gem::Platform::RUBY
   gem.summary     = 'Interface to MS Windows Semaphore objects.'
   gem.test_file   = 'test/test_win32_semaphore.rb'
   gem.has_rdoc    = true
   gem.files       = Dir['**/*'].reject{ |f| f.include?('CVS') }

   gem.rubyforge_project = 'win32utils'
   gem.extra_rdoc_files  = ['README', 'CHANGES', 'MANIFEST']

   gem.add_dependency('win32-ipc')

   gem.description = <<-EOF
      The win32-semaphore library provides an interface to semaphore objects
      on MS Windows. A semaphore is a kernel object used for resource counting.
      This allows threads to query the number of resources available, and wait
      if there aren't any available.
   EOF
end

Gem::Builder.new(spec).build
