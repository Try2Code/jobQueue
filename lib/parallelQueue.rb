require 'parallel'
# ==============================================================================
# Author: Ralf Mueller, ralf.mueller@mpimet.mpg.de
#         suggestions from Robert Klemme (https://www.ruby-forum.com/topic/68001#86298)
#
# ==============================================================================

# ParallelQueue is nothing but a regular queue with the ability to store blocks
# or methods (plus aruments)
class ParallelQueue < Queue
  alias :queue_push :push
  include Parallel::ProcessorCount

  # puts code to the queue as a 
  # * method: push(method,arg1,arg2,...)
  # * block: push { ... }
  def push (*item, &block)
    queue_push(item   ) unless item.empty?
    queue_push([block]) unless block.nil?
  end

  # run things with the 'parallel' library - results are returned automatically 
  def run(workers=processor_count)
    queue_push(Parallel::Stop)
    Parallel.map(self,:in_threads => workers) {|task|
      if task.size > 1
        if task[0].kind_of? Proc
          # Expects proc/lambda with arguments,e.g.
          # [mysqrt,2.789]
          # [myproc,x,y,z]
          task[0].call(*task[1..-1])
        else
          # expect an object in task[0] and one of its methods with arguments
          # in task[1] as a symbol
          # e.g. [a,[:attribute=,1] or
          # Math,:exp,0
          task[0].send(task[1],*task[2..-1])
        end
      else
        task[0].call
      end
    }
  end

  # run the given calls WITHOUT automatic result storage, but faster
  def justRun(workers=processor_count)
    @threads = (1..workers).map {|i|
      Thread.new(self) {|q|
        until ( q == ( task = q.deq ) )
          if task.size > 1
            if task[0].kind_of? Proc
              # Expects proc/lambda with arguments, e.g. [mysqrt,2.789]
              task[0].call(*task[1..-1])
            else
              # expect an object in task[0] and one of its methods with
              # arguments in task[1] as a symbol
              # e.g. [a,[:attribute=,1]
              task[0].send(task[1],*task[2..-1])
            end
          else
            task[0].call
          end
        end
      }
    }
    @threads.size.times { self.enq self}
    @threads.each {|t| t.join}
  end
end
