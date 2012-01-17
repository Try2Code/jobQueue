#!/usr/bin/env ruby
require 'optparse'
require 'jobqueue'
# ==============================================================================
# Example script:
# Read in a script and process line in parallel with a given number of threads:
# Usage: prun.rb <num> myScript.sh
# Attention: each line of the input script is regarded as a separate command
# ==============================================================================

nTh      = SystemJobs.maxnumber_of_processors
options  = {:workers => nTh,:debug => false}
optparse = OptionParser.new do|opts|
  opts.banner = "Usage: prun.rb [options] command-files"

  opts.separator ""
  opts.on('-j [NUM]',"Number of worker threads (default:#{nTh})") do |num|
    options[:workers] = num.to_i.abs
  end
  opts.on('-d','--debug','Print output from workers on stdout') do
    options[:debug] = true
  end
  # This displays the help screen, all programs are
  # assumed to have this option.
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end
optparse.parse!

if ARGV.empty?
  warn "Provide an input file"
  puts optparse.help
  exit
end

ARGV.each do|f|
  # read file line per line
  lines = File.open(f).readlines.map(&:chomp)
  q     = SystemJobs.new(options[:workers],options[:debug])
  puts "Run with #{q.workers} threads"
  lines.each {|line| q.push(line) }
  q.run
end
