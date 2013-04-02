import unittest,os,tempfile
from stat import *
from jobqueue import *

class JobQueueTest(unittest.TestCase):

  def test_size(self):
    q = JobQueue(8)
    for i in range(1300):
      q.push(i)
    q.run()

  def test_SysJobs(self):
    q = SystemJobs(2,True)
    for i in range(1000):
      q.push("date")
    q.run()

if __name__ == '__main__':
  unittest.main()

# vim:sw=2
