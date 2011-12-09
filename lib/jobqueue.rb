#!/usr/bin/env ruby
require 'thread'

# ==============================================================================
# Author: Ralf Mueller, ralf.mueller@zmaw.de
#         suggestions from Robert Klemme (https://www.ruby-forum.com/topic/68001#86298)
#
# ==============================================================================
# Sized Queue for limiting the number of parallel jobs
# ==============================================================================
class JobQueue
  attr_reader :size, :queue, :threads

  def initialize(size)
    @size  = size
    @queue = Queue.new
  end

  def push(*items)
    items.each {|it| @queue << it}
  end

  def run
    @threads = (1..@size).map {|i|
      Thread.new(@queue) {|q|
        until ( q == ( task = q.deq ) )
          
          if task.kind_of? String
            system(task)
          elsif task.kind_of? Proc
            task.call
          end
        end
      }
    }
    @threads.size.times { @queue.enq @queue}
    @threads.each {|t| t.join}
  end

  def number_of_processors
    if RUBY_PLATFORM =~ /linux/
      return `cat /proc/cpuinfo | grep processor | wc -l`.to_i
    elsif RUBY_PLATFORM =~ /darwin/
      return `sysctl -n hw.logicalcpu`.to_i
    elsif RUBY_PLATFORM =~ /(win32|mingw|cygwin)/
      # this works for windows 2000 or greater
      require 'win32ole'
      wmi = WIN32OLE.connect("winmgmts://")
      wmi.ExecQuery("select * from Win32_ComputerSystem").each do |system|
        begin
          processors = system.NumberOfLogicalProcessors
        rescue
          processors = 0
        end
        return [system.NumberOfProcessors, processors].max
      end
      elseif RUBY_PLATFORM =~ /java/
        return Runtime.getRuntime().availableProcessors().to_i
    end
    raise "can't determine 'number_of_processors' for '#{RUBY_PLATFORM}'"
  end
end

