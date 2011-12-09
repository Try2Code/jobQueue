#!/usr/bin/env ruby
require 'jobqueue'
# ==============================================================================
# Example script:
# Read in a script and process line in parallel with a given number of threads:
# Usage: prun.rb 10 myScript.sh
# Attention: each line of the input script is regarded as a separate command
# ==============================================================================
if $0 == __FILE__
  unless ARGV.size == 2
    warn "provide number of threads and input data"
    exit
  end
  # read number of threads
  noTh = ARGV[0].to_i
  # read file line per line
  lines = File.open(ARGV[1]).readlines.map(&:chomp)
  q = JobQueue.new(noTh)
  q.push(lines)
  q.run
end

