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
options  = {:workers => nTh,:debug => :buffered}
optparse = OptionParser.new do|opts|
  opts.banner = "Usage: prun.rb [options] command-files"

  opts.separator ""
  opts.on('-j [NUM]',"Number of worker threads (default:#{nTh})") do |num|
    options[:workers] = num.to_i.abs
  end
  opts.on('-D','--no-debug','subpress output from workers') do
    options[:debug] = :off
  end
  opts.on('-l','--logging','stdout and stderr are printed as produced by the child processes') do
    options[:debug] = :flushed
  end
  opts.on('-b','--buffering','stdout and stderr are buffered and printed when jobs are finished (default)') do
    options[:debug] = :buffered
  end
  opts.on('-v','--version','Print version nummer') do
    puts '1.0.10'
    exit
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
  puts "Run with #{q.workers} threads" unless :off == options[:debug]
  lines.each {|line| q.push(line) }
  q.run
end