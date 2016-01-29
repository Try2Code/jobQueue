require 'benchmark'
require 'benchmark/ips'
require 'pp'
require 'tempfile'
require 'cdo_lib'
$:.unshift File.join(File.dirname(__FILE__),"..","lib")
require 'jobqueue'
require 'parallel_queue'

Benchmark.ips do |x|
  x.report('JobQueue.run') { _jq.run }
  x.report('Queue.run') { _pq.run(10) }
  x.report('JobQueue.run - with results') { _jqR.run }
  x.report('Queue.run - with results') { _pqR.run(10) }
  x.compare!
end if false

def doIO
  #Cdo.topo
end
n=99999
nworker = 10
jQ = JobQueue.new(nworker)
pQ = Queue.new
aQ = Array.new

    n.times {|i| 
      pQ.push { 
        Math.sin((i**3).to_f);
      }
    }
    n.times {|i| 
      aQ.push { 
        Math.sin((i**3).to_f);
      }
    }
    n.times {|i| 
      jQ.push { 
        Math.sin((i**3).to_f)
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

 #x.report("ParallelArray:") {     
 #  r = aQ.run(nworker)
 #}
end
