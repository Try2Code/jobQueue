require 'rubygems'

spec = Gem::Specification.new do |s|
  s.name              = "jobQueue"
  s.version           = '1.0'
  s.platform          = Gem::Platform::RUBY
  s.bindir            = 'bin'
  s.files             = ["lib/jobqueue.rb","bin/prun.rb"] + ["gemspec","LICENSE"]
  s.executables       << 'prun.rb'
  s.description       = "Run Shell commands or Ruby methods in parallel"
  s.summary           = s.description
  s.author            = "Ralf Mueller"
  s.email             = "stark.dreamdetective@gmail.com"
#  s.homepage          = "http://
  s.has_rdoc          = false
end

# vim:ft=ruby
