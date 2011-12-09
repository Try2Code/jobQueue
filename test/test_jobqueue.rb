$:.unshift File.join(File.dirname(__FILE__),"..","lib")
require 'test/unit'
require 'jobqueue'


NTHREDs = ENV['NTHREDs'].nil? ? 4 : ENV['NTHREDs']

class A
  @i = nil
  def seti(i)
    @i = i
  end
end

class TestJobQueue < Test::Unit::TestCase

  def setup
    @jq = JobQueue.new(NTHREDs)
  end

  def test_string
    @jq.push(*%w[ls]*7)
    @jq.run
  end

  def test_proc_simple
    halo = lambda { puts "halo"}
    @jq.push(*([halo]*11))
    @jq.run
  end
  def test_proc
    sqrt = lambda {|v| puts Math.sqrt(v)}
    10.times { @jq.push([sqrt,rand])}
    @jq.run
  end
  def test_method
#   a = A.new
#   assert_equal(nil,a.i)
#   i = 10
#   @jq.push([a,[seti,i]])
#   @jq.run
  end

  def test_object
  end
end
