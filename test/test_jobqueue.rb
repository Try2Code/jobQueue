$:.unshift File.join(File.dirname(__FILE__),"..","lib")
require 'minitest/autorun'
require 'jobqueue'
require 'tempfile'


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

class TestJobQueue < Minitest::Test

  def setup
    @jq    = JobQueue.new(NTHREDs)
    @jqSer = JobQueue.new(1)
    @sysjq = SystemJobs.new(NTHREDs)
  end

  def test_queue_methods
    assert_equal(NTHREDs,@jq.workers)
    assert_equal(0,@jq.size)
    assert_equal(0,@jq.length)
    assert(@jq.empty?,"jobQueue is not empty")
    4.times { @jq.push(Math,:sqrt,rand) }
    assert_equal(4,@jq.size)
    @jq.clear
    assert(@jq.empty?,"jobQueue is not empty")
    4.times { @jq.push(Math,:sqrt,rand) }
    @jq.run
    assert(@jq.empty?,"jobQueue is not empty")
  end
  def test_system_cmds
    cmds = %w[date ls echo true]
    7.times { @sysjq.push(cmds[(4*rand).floor])}
    20.times { @sysjq.push('ls')}
    @sysjq.run
  end

  def test_proc_simple
    halo = lambda { puts "halo"}
    11.times { @jq.push(halo) }
    @jq.run
  end
  def test_proc
    sqrt = lambda {|v| puts Math.sqrt(v)}
    norm = lambda {|x,y| puts Math.sqrt(x*x + y*y)}
    10.times { @jq.push(sqrt,rand)}
    10.times { @jq.push(norm,rand,rand)}
    @jq.run
  end
  def test_method
    a = A.new
    assert_equal(nil,a.i)
    assert_equal(nil,a.j)
    assert_equal(nil,a.k)
    i = 10
    @jq.push(a,:seti,i)
    @jq.run
    assert_equal(i,a.i)
    i = 11
    @jq.push(a,:seti,i)
    @jq.run
    assert_equal(i,a.i)
    (0..77).each {|i| @jq.push(a,:seth,i) }
    @jq.run
    (0..77).each {|i| assert_equal(2*i,a.h[i]) }
    a.h.clear;assert_equal({},a.h)
  end
  def test_accessor
    a = A.new
    assert_equal(nil,a.i)
    assert_equal(nil,a.j)
    assert_equal(nil,a.k)
    # try ruby style accessors
    @jqSer.push(a,:i=,1)
    @jqSer.push(a,:j=,2)
    @jqSer.push(a,:k=,3)
    @jqSer.run
    assert_equal(1,a.i)
    assert_equal(2,a.j)
    assert_equal(3,a.k)
    @jq.push(a,:i=,10)
    @jq.push(a,:j=,20)
    @jq.push(a,:k=,30)
    @jq.run
    assert_equal(10,a.i)
    assert_equal(20,a.j)
    assert_equal(30,a.k)
  end

  def test_class_methods
    @jq.push(B,:set,1)
    @jq.run
    assert_equal(1,B.get)
  end
  def test_module
    @jq.push(C,:sqrt,10)
    @jq.push(C,:sqrt,100)
    @jq.push(C,:sqrt,1000)
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

    #(0..1000).each {|i| @jq.push(fill,a.h,i) }
    #@jq.run
    #assert_not_equal(a.h.keys, a.h.keys.sort)
    #(0..20).each {|i|
    #  assert_equal(i,a.h[i])
    #}
    a.h.clear;assert_equal({},a.h)
 
    lock = Mutex.new
    (0..20).each {|i| @jq.push(lockfill,a.h,i,lock) }
    @jq.run
  end

  def test_max
    assert_equal(8,JobQueue.maxnumber_of_processors) if `hostname`.chomp == 'thingol'
    assert_equal(JobQueue.maxnumber_of_processors,SystemJobs.maxnumber_of_processors)
    pp SystemJobs.maxnumber_of_processors
  end

  def test_push
    a = A.new
    @jq.push(a,:seth,1)
    @jq.push(a,:i=,77)
    @jq.push($stdout,:puts,"halo")
    @jq.push(Math,:sqrt,22)
    @jq.push(lambda { puts "halo"})
    @jq.run
    assert_equal(2,a.h[1])
    assert_equal(77,a.i)
  end

  def test_block
    a = A.new
    @jq.push { a.i = 111 }
    @jq.run
    assert_equal(111,a.i)

    size = 100
    (0..size).each {|i| a.h[i] = nil }
    (0..size).each {|i|
      @jq.push do
        a.h[i] = i*i
      end
    }
    @jq.run
    (0..size).each {|i| 
      assert_equal(i*i,a.h[i])
    }
  end

  def test_block_vs_method
    a = A.new
    size = 100
    # use blocks
    (0..size).each {|i|
      @jq.push do
        a.seth(i)
      end
    }
    @jq.run
    (0..size).each {|i| assert_equal(2*i,a.h[i]) }
    a.h.clear

    # use method
    (0..size).each {|i| @jq.push(a,:seth,i) }
    @jq.run
    (0..size).each {|i| assert_equal(2*i,a.h[i]) }
  end

  if 'luthien' == `hostname`.chomp
    def test_init_without_args
      jq = JobQueue.new
      assert_equal(8,jq.workers)
      jq = JobQueue.new(1)
      assert_equal(1,jq.workers)
    end
    def test_bench_shortQueue
      # rand()
      runTimes = 5*10**6
      # date
      runTimes = 10**2

      times = {}
      #[1,2,3,4,6,8].each {|nworker|
      [1,2,4].each {|nworker|
        puts nworker
        jq = JobQueue.new(nworker)
        nworker.times {|i|
          jq.push {
            runTimes.times { system("date >/dev/null") }
            #runTimes.times { rand() }
          }
        }
        print "start ..."
        start = Time.new
        jq.run
        times[nworker] = Time.new - start
        puts
      }
      pp times
    end
    def test_bench_longQueue
      runTimes = 10**5

      times = {}
      [1,2,4,8].each {|nworker|
        puts nworker
        jq = JobQueue.new(nworker)
        nworker.times {|i|
          runTimes.times {
            #jq.push(Kernel,:rand)
            jq.push {
              rand()
            }
          }
          start = Time.new
          jq.run
          times[nworker] = Time.new - start
        }
      }
      pp times
    end
  end
end
