require 'benchmark'
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

def jq_with_results
  results = []
  lock = Mutex.new
  q = JobQueue.new(10)
  100.times {|i|
    q.push {
      r = Math.sqrt(i**2 + 1)
      lock.synchronize{ results << r}
    }
  }
  [q,results]
end
def pq_with_results
  results = []
  q = Queue.new
  lock = Mutex.new
  100.times {|i|
    q.push {
      r = Math.sqrt(i**2 + 1)
      lock.synchronize{ results << r}
    }
  }
  [q,results]
end

_jq = jq
_pq = pq

_jqR, jR = jq_with_results
_pqR, pR = pq_with_results

Benchmark.ips do |x|
  x.report('JobQueue.run') { _jq.run }
  x.report('Queue.run') { _pq.run(10) }
  x.report('JobQueue.run - with results') { _jqR.run }
  x.report('Queue.run - with results') { _pqR.run(10) }
  x.compare!
end if false

n=10000
nworker = 10
jq = JobQueue.new(nworker)
qp = Queue.new
Benchmark.bm do |x|
  x.report("JobQueue     :") { n.times {|i| jq.push { Math.sin((i**3).to_f)} ; jq.run} }
  x.report("ParallelQueue:") { n.times {|i| pq.push { Math.sin((i**3).to_f)} ; pq.run(nworker)} }
end
