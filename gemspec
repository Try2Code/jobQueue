require 'rubygems'

spec = Gem::Specification.new do |s|
  s.name              = "jobQueue"
  s.version           = '1.0.1'
  s.platform          = Gem::Platform::RUBY
  s.bindir            = 'bin'
  s.files             = ["lib/jobqueue.rb","bin/prun.rb"] + ["gemspec","LICENSE","README.rdoc"]
  s.executables       << 'prun.rb'
  s.description       = "Run Shell commands or Ruby methods in parallel"
  s.summary           = s.description
  s.author            = "Ralf Mueller"
  s.email             = "stark.dreamdetective@gmail.com"
  s.homepage          = "https://github.com/Try2Code/jobQueue"
  s.extra_rdoc_files          = ["README.rdoc","LICENSE"]
  s.required_ruby_version = ">= 1.9"
end

# vim:ft=ruby
