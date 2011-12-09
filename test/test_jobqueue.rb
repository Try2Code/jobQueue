$:.unshift File.join(File.dirname(__FILE__),"..","lib")
require 'test/unit'
require 'jobqueue'


NTHREDs = ENV['NTHREDs'].nil? ? 4 : ENV['NTHREDs']

class TestJobQueue < Test::Unit::TestCase

  def setup
    @jq = JobQueue.new(NTHREDs)
  end

  def test_string
    @jq = JobQueue.new(4)
    @jq.push(%w[ls]*7)
    @jq.run
  end

  def test_proc
    sqrt = lambda {|v| Math.sqrt(v)}
    halo = lambda { puts "halo"}
    @jq.push([halo]*11)
    @jq.run
  end
end
