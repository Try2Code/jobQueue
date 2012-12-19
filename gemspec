require 'rubygems'

spec = Gem::Specification.new do |s|
  s.name              = "jobQueue"
  s.version           = '1.0.8'
  s.platform          = Gem::Platform::RUBY
  s.bindir            = 'bin'
  s.files             = ["lib/jobqueue.rb","bin/prun.rb"] + ["gemspec","LICENSE","README.rdoc"]
  s.executables       << 'prun.rb'
  s.description       = "Run Shell commands or Ruby methods in parallel"
  s.summary           = "Run Shell commands or Ruby methods in parallel"
  s.author            = "Ralf Mueller"
  s.email             = "stark.dreamdetective@gmail.com"
  s.homepage          = "https://github.com/Try2Code/jobQueue"
  s.extra_rdoc_files          = ["README.rdoc","LICENSE"]
  s.license           = "BSD"
  s.test_file         = "test/test_jobqueue.rb"
  s.required_ruby_version = ">= 1.8"
  s.has_rdoc          = true
end

# vim:ft=ruby
