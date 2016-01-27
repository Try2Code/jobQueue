$:.unshift File.join(File.dirname(__FILE__),"..","lib")
require 'minitest/autorun'
require 'parallel_queue'

class TestParallelQueue < Minitest::Test

  def test_simple
    q = ParallelQueue.new
    q.push {
      puts Math.sin(123)
    }
    q.run(1)
  end
end
