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
  attr_reader :workers, :threads

  # Create a new queue qith a given number of worker threads
  def initialize(nWorkers,debug=false)
    @workers = nWorkers
    @queue   = Queue.new
    @debug   = debug
  end

  # borrow some useful methods from Queue class
  [:size,:length,:clear,:empty?].each {|method|
    define_method(method) { @queue.send(method) }
  }

  # Put jobs into the queue. Use
  #   proc,args for single methods
  #   object,:method,args for sende messages to objects
  def push(*item,&block)
    @queue << item    unless item.empty?
    @queue << [block] unless block.nil?
  end

  # Start workers to run through the queue
  def run
    @threads = (1..@workers).map {|i|
      Thread.new(@queue) {|q|
        until ( q == ( task = q.deq ) )
          if task.size > 1
            if task[0].kind_of? Proc
              # Expects proc/lambda with arguments, e.g. [mysqrt,2.789]
              task[0].call(*task[1..-1])
            else
              # expect an object in task[0] and one of its methods with arguments in task[1] as a symbol
              # e.g. [a,[:attribute=,1]
              task[0].send(task[1],*task[2..-1])
            end
          else
            task[0].call
          end
        end
      }
    }
    @threads.size.times { @queue.enq @queue}
    @threads.each {|t| t.join}
  end

  # Get the maximum number of parallel runs
  def JobQueue.maxnumber_of_processors
    case RUBY_ENGINE
    when 'jruby'
      return Runtime.getRuntime().availableProcessors().to_i
      #  processors = java.lang.Runtime.getRuntime.availableProcessors
    when 'ironruby'
      return System::Environment.ProcessorCount
    when 'ruby'
      case  RUBY_PLATFORM
      when /linux/
        return `cat /proc/cpuinfo | grep processor | wc -l`.to_i
      when /darwin/
        return `sysctl -n hw.logicalcpu`.to_i
      when /(win32|mingw|cygwin)/
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
      end
    end
    raise "Cannot determine the number of available Processors for RUBY_PLATFORM:'#{RUBY_PLATFORM}' and RUBY_ENGINE:#{RUBY_ENGINE}"
  end
end

# Special class for runing operating system commands with Ruby's system call
class SystemJobs < JobQueue
  def run
    @threads = (1..@workers).map {|i|
      Thread.new(@queue,@debug) {|q,dbg|
        until ( q == ( task = q.deq ) )
          ret = IO.popen(task.first).read
          #puts ret if dbg
        end
      }
    }
    @threads.size.times { @queue.enq @queue}
    @threads.each {|t| t.join}
  end
end
