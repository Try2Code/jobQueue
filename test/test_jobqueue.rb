$:.unshift File.join(File.dirname(__FILE__),"..","lib")
require 'test/unit'
require 'jobqueue'


NTHREDs = ENV['NTHREDs'].nil? ? 4 : ENV['NTHREDs']

class A
  attr_accessor :i,:j,:k,:h
  @@lock = Mutex.new

  def initialize
    @i, @j, @k = nil,nil,nil
    @h    = {}
  end
  def seti(i)
    @i = i
  end
  def seth(v)
    @@lock.synchronize{ @h[v] = 2*v}
  end
end
class B
  @@val = 0
  def B.set(val)
    @@val = val
  end
  def B.get
    @@val
  end
end
module C
  def C.sqrt(v)
    Math.sqrt(v)
  end
end

class TestJobQueue < Test::Unit::TestCase

  def setup
    @jq    = JobQueue.new(NTHREDs)
    @jqSer = JobQueue.new(1)
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
    norm = lambda {|x,y| puts Math.sqrt(x*x + y*y)}
    10.times { @jq.push([sqrt,rand])}
    10.times { @jq.push([norm,rand,rand])}
    @jq.run
  end
  def test_method
    a = A.new
    assert_equal(nil,a.i)
    assert_equal(nil,a.j)
    assert_equal(nil,a.k)
    i = 10
    @jq.push([a,[:seti,i]])
    @jq.run
    assert_equal(i,a.i)
    i = 11
    @jq.push([a,[:seti,i]])
    @jq.run
    assert_equal(i,a.i)
  end
  def test_accessor
    a = A.new
    assert_equal(nil,a.i)
    assert_equal(nil,a.j)
    assert_equal(nil,a.k)
    # try ruby style accessors
    @jqSer.push([a,[:i=,1]])
    @jqSer.push([a,[:j=,2]])
    @jqSer.push([a,[:k=,3]])
    @jqSer.run
    assert_equal(1,a.i)
    assert_equal(2,a.j)
    assert_equal(3,a.k)
    @jq.push([a,[:i=,10]])
    @jq.push([a,[:j=,20]])
    @jq.push([a,[:k=,30]])
    @jq.run
    assert_equal(10,a.i)
    assert_equal(20,a.j)
    assert_equal(30,a.k)
  end

  def test_class_methods
    @jq.push([B,[:set,1]])
    @jq.run
    assert_equal(1,B.get)
  end
  def test_module
    @jq.push([C,[:sqrt,10]])
    @jq.push([C,[:sqrt,100]])
    @jq.push([C,[:sqrt,1000]])
    @jq.run
  end
  def test_lock
    lockfill = lambda {|myhash,value,lock|
      lock.synchronize { myhash[value] = value}
    }
    fill = lambda {|myhash,value| myhash[value] = value}
    a = A.new
    a.seth(1)
    assert_equal(2,a.h[1])
    (0..77).each {|i|
      @jq.push([a,[:seth,i]])
    }
    @jq.run
    (0..77).each {|i|
      assert_equal(2*i,a.h[i])
    }
  end
end
