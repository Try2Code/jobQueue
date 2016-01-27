require 'benchmark/ips'
$:.unshift File.join(File.dirname(__FILE__),"..","lib")
require 'jobqueue'
require 'parallel_queue'



def jq
  q = JobQueue.new(10)
  100.times {|i| 
    q.push {
      Math.sqrt(i**2 + 1)
    }
  }
  q
end

def pq
  q = Queue.new
  100.times {|i| 
    q.push {
      Math.sqrt(i**2 + 1)
    }
  }
  q
end

_jq = jq
_pq = pq

Benchmark.ips do |x|
  x.report('JobQueue.run') { _jq.run }
  x.report('Queue.run') { _pq.run(10) }
  x.compare!
end
