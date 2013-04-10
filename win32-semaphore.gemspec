require 'rubygems'

Gem::Specification.new do |spec|
  spec.name        = 'win32-semaphore'
  spec.version     = '0.4.1'
  spec.author      = 'Daniel J. Berger'
  spec.license     = 'Artistic 2.0'
  spec.email       = 'djberg96@gmail.com'
  spec.homepage    = 'http://www.github.com/djberg96/win32-semaphore'
  spec.summary     = 'Interface to MS Windows Semaphore objects.'
  spec.test_file   = 'test/test_win32_semaphore.rb'
  spec.files       = Dir['**/*'].reject{ |f| f.include?('git') }

  spec.rubyforge_project = 'win32utils'
  spec.extra_rdoc_files  = ['README', 'CHANGES', 'MANIFEST']
  spec.required_ruby_version = '> 1.9.0'

  spec.add_dependency('win32-ipc')
  spec.add_development_dependency('test-unit')

  spec.description = <<-EOF
    The win32-semaphore library provides an interface to semaphore objects
    on MS Windows. A semaphore is a kernel object used for resource counting.
    This allows threads to query the number of resources available, and wait
    if there aren't any available.
  EOF
end
