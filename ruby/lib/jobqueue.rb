require 'thread'
require 'open3'
require 'parallel'
# ==============================================================================
# Author: Ralf Mueller, ralf.mueller@mpimet.mpg.de
#         suggestions from Robert Klemme (https://www.ruby-forum.com/topic/68001#86298)
#
# ==============================================================================
# Sized Queue for limiting the number of parallel jobs
# ==============================================================================

include Parallel::ProcessorCount
class JobQueue
  attr_reader :workers, :threads

  # Create a new queue qith a given number of worker threads
  def initialize(nWorkers=processor_count,debug=:off)
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
  def run(threads2run=@workers)
    @threads = (1..threads2run).map {|i|
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
end

# Special class for runing operating system commands with Ruby's system call
class SystemJobs < JobQueue
  def run
    if :off == @debug then
      $stdout.reopen("/dev/null", "w")
      $stderr.reopen("/dev/null", "w")
    end

    @threads = (1..@workers).map {|i|
      Thread.new(@queue,@debug) {|queue,debug|
        Thread.current.abort_on_exception = true
        until ( queue == ( task = queue.deq ) )
          case debug
          when :buffered
            # output is buffered until jobs are finished
            stderr_and_stdout,waitThr = Open3.capture2e(task.first)
            puts stderr_and_stdout

          when :flushed
            # stdout and stderr are read + printed in parallel
            _, stderr, stdout, waitThr = Open3.popen3(task.first)
            # Create a thread to read from each stream
            [stdout,stderr].map {|stream|
              Thread.new(stream,debug) {|_stream|
                Thread.current.abort_on_exception = true
                puts $_ until _stream.gets.nil?
              }
            }.map(&:join)

          when :off
            # no output at all (switched off globally at the beginning of this method)'
            system(task.first)
          else
            raise ArgumentError,"Unknown debug mode '#{debug}'!"
          end
        end
      }
    }
    @threads.size.times { @queue.enq @queue}
    @threads.map(&:join)
  end
end
