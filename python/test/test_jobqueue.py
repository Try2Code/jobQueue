import unittest,os,tempfile
from stat import *
from jobqueue import *

class JobQueueTest(unittest.TestCase):
  def test_sys(self):
    q = SystemJobs(8,True)
    for i in range(200):
      q.push("date")
    q.run()

  def test_push(self):
    def makeFunc(arg):
      def work():
        print 'Im ',arg

      return work
    q = JobQueue(4,True)
    for i in range(10):
      f = makeFunc(i)
      q.push(f)
    q.run()

if __name__ == '__main__':
  unittest.main()

# vim:sw=2
