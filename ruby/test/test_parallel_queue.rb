$:.unshift File.join(File.dirname(__FILE__),"..","lib")
require 'minitest/autorun'
require 'parallel_queue'
require 'pp'
require 'cdo'

class TestParallelQueue < Minitest::Test

  def test_block
    q = Queue.new
    results = []
    lock = Mutex.new
    actions = 9999
    actions.times {
      q.push {
        a = Math.sin((0.1+rand()))
        lock.synchronize {results << a}
      }
    }
    q.run(10)

    assert_equal(actions,results.size)
    results.each {|r| assert(0.01 < r,"found results below lower boundary") }
  end

  def test_block_with_results
    q = Queue.new

    99.times {|i|
      q.push {
        Cdo.topo(:output => "topo_#{i.to_s.rjust(4,'0')}.grb")
      }
    }

    results = q.run

    assert(results == results.sort)
  end

  def test_proc
    # drawback: no results with this kind of items in queue
    q = Queue.new
    myProc = lambda {|r| Math.sqrt(r)}
    q.push(myProc,4.0)
    q.push(Math,:sqrt,16.0)
    q.push(Math,:sqrt,529.0)
    q.run

    #now with results
    q.push(myProc,4.0)
    q.push(Math,:sqrt,16.0)
    q.push(Math,:sqrt,529.0)
    results = q.run
    assert_equal([2.0,4.0,23.0],results.sort)
  end
  def test_proc_more_parameters
    q = Queue.new
    norm = lambda {|x,y| Math.sqrt(x*x + y*y)}
    11.times { q.push(norm,rand,rand)}
    q.run

    #now with results
    11.times { q.push(norm,rand,rand)}
    results = q.run
    assert(Float,results.map(&:class).uniq.first)
  end
end
