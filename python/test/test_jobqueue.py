import unittest,os,tempfile
from stat import *
from jobqueue import *
import pylab as pl
from cdo import *
import numpy as np

class JobQueueTest(unittest.TestCase):
  def test_sys(self):
    q = SystemJobs(8,True)
    for i in range(200):
      q.push("date")
    q.run()

  def test_push(self):
    def makeFunc(arg):
      def work():
        n = arg*arg
        print 'n = ',n
        os.system("ls")
        z=3000
        cdo = Cdo()
        info = cdo.infov(input='-topo',options='-f nc')[1]
        print(info)

      return work
    q = JobQueue(2)
    for i in range(10):
      q.push(makeFunc(i))
    q.run()

  def test_pylab(self):
    def makeWork(z):
      def work():
        print('z=',z)
        topo = np.array([[1.,2.],[3.,4.]])
        pl.imshow(topo,interpolation="nearest")
        pl.savefig('testImage_%i'%(z))
        print 'finished saving for z =',z

      return work

    f = makeWork(4321)
    f()

    q=JobQueue(10)
    for z in range(-5000,5000,1000):
      q.push(makeWork(z))
    print 'SIZE =',q.queue.qsize()
    q.run
    print 'SIZE =',q.queue.qsize()
    pass

if __name__ == '__main__':
  unittest.main()

# vim:sw=2
