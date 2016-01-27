$:.unshift File.join(File.dirname(__FILE__),"..","lib")
require 'minitest/autorun'
require 'parallel_queue'
require 'pp'

class TestParallelQueue < Minitest::Test

  def test_block
    q = ParallelQueue.new
    results = []
    lock = Mutex.new
    10.times { 
      q.push { 
        a = Math.sin(rand()*Math::PI)
        lock.synchronize {results << a}
      }
    }
    q.run(10)
    pp results
    assert_equal(10,results.size)
  end

  def test_proc
    # drawback: no results with this kind of items in queue
    q = ParallelQueue.new
    myProc = lambda {|r| Math.sqrt(r)}
    q.push(myProc,4.0)
    q.push(Math,:sqrt,16.0)
    q.push(Math,:sqrt,529.0)
    q.run
  end
end
