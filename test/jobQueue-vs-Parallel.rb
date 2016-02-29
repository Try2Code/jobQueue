require 'benchmark'
require 'jobqueue'
$:.unshift File.join(File.dirname(__FILE__),"..","lib")
require 'parallelQueue'

n         = 199999
nworker   = 4
jQ        = JobQueue.new(nworker)
pQ        = ParallelQueue.new
resultsJQ = []
lock      = Mutex.new

n.times {|i|
  pQ.push {
    Math.sin((i**3).to_f);
  }
}
n.times {|i|
  jQ.push {
    r = Math.sin((i**3).to_f)
    lock.synchronize { resultsJQ << r}
  }
}

input = (0..n).to_a

Benchmark.bm do |x|
  x.report("Parallel     :") { 
    r = Parallel.map(input,:in_threads => nworker) {|i|
      Math.sin((i**3).to_f)
    } 
  }

  x.report("ParallelQueue:") {     
    r = pQ.run(nworker)
  }

  x.report("JobQueue     :") {     
    jQ.run
  }

# puts resultsJQ[0,10].map(&:to_s).join
end
