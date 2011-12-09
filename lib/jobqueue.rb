#!/usr/bin/env ruby
require 'thread'
require 'pp'
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
          $stdout << task.class.to_s
          if task.kind_of? String
            system(task)
          elsif task.kind_of? Proc
            task.call
          elsif task.kind_of? Array
            if task.size > 1
              if not task[1].kind_of? Array 
                # Expects proc/lambda with arguments, e.g. [mysqrt,2.789]
                task[0].call(*task[1..-1])
              else
                # expect an object in task[0] and one of its methods with arguments in task[1] as a symbol
                # e.g. [a,[:attribute=,1]
                task[0].send(task[1][0],*task[1][1..-1])
              end
            else
              warn 'provide 2d arrays'
            end
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

