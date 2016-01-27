require 'thread'
require 'parallel'
class ParallelQueue < Queue
  alias :parent_push :push
  def push (*item, &block)
    super(item   ) unless item.empty?
    super([block]) unless block.nil?
  end
  def run(workers=9)
    parent_push(Parallel::Stop)
    Parallel.each(self,:in_threads => workers) {|task|
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
    }
  end
# alias_method :push, :parent_push
end
