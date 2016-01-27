$:.unshift File.join(File.dirname(__FILE__),"..","lib")
require 'minitest/autorun'
require 'parallel_queue'

class TestParallelQueue < Minitest::Test

  def test_simple
    q = ParallelQueue.new
    100.times { q.push { puts Math.sin(rand()*Math::PI) }}
    q.run(10)
  end
  def test_block
  end
  def test_proc
  end
  def test_results
  end
end
