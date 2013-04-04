import unittest,os,time
from jobqueue import *
import pylab as pl
import matplotlib.pyplot as plt
import numpy as np
from cdo import *
from math import *

def plot(args):
  num, i = args
  fig = plt.figure()
  data = np.random.randn(num).cumsum()
  plt.plot(data)
  plt.title('Plot of a %i-element brownian noise sequence' % num)
  fig.savefig('temp_fig_%02i.png' % i)
  print '%i  plot finished'%(i)

def topoPlot(arg):
  print('started for arg=',arg)
  cdo = Cdo()
  topo = cdo.setrtomiss(arg,arg+1000,input='-topo',returnArray='topo',options='-f nc')
  pl.imshow(topo,interpolation="nearest")
  pl.savefig('testImage_%i'%(arg))
  print 'finished saving for arg =',arg

class JobQueueTest(unittest.TestCase):
  def test_sys(self):
    q = SystemJobs(8,True)
    for i in range(200):
      q.push("date")
    q.run()

  def test_push(self):
    """Test with a codce block executed with threads"""
    def makeFunc(arg):
      def work():
        print(arg,' started')
        n = exp(sqrt(arg*arg))
        print 'n = ',n
        #os.system("ls")
        topo = np.array([[1.,2.],[3.,4.]])
        print os.system("gnuplot -p <<EOF\nplot sin(%i*x) t '%i'\nEOF"%(n+1,n))
        print arg,' finished'

      return work

    q = JobQueue(18)
    for i in range(5):
      q.push(makeFunc(float(i)))
    q.run()

#  if 'thingol' == os.popen('hostname').read().strip()
  def test_cdo(self):
    """Test with a code block executed with threads using cdo.py"""
    cdo = Cdo()
    def makeFunc(arg):
      def work():
        print(arg,' started')
        topo = cdo.topo(options='-f nc',returnArray='topo')
        print(topo.shape)
        meanheight = cdo.outputkey('value',input="-fldmean -topo")
        print meanheight
        return topo

      return work

    q = JobQueue(12)
    for i in range(10):
      q.push(makeFunc(float(i)))
    q.run()

  def test_pylab(self):
    def makeWork(arg):
      def work():
        print('started for arg=',arg)
        topo = np.array([[1.,2.],[3.,4.]])
        pl.imshow(topo,interpolation="nearest")
        pl.savefig('testImage_%i'%(arg))
        print 'finished saving for arg =',arg

      return work

    f = makeWork(4321)
    f()

    q=JobQueue(1,True)
    for z in range(-5000,5000,1000):
      q.push(makeWork(z))
    print 'SIZE =',q.queue.qsize()
    q.run
    print 'SIZE =',q.queue.qsize()

    pass

  def test_mp(self):
    """Test with mp queue with code block definition"""
    def _makeWork(arg):
      print('started for arg=',arg)
      topo = np.array([[1.,2.],[3.,4.]])
      print 'finished saving for arg =',arg

    mpq = mpJobQueue(10)
    for z in range(-5000,5000,1000):
      mpq.push(_makeWork,z)

#    mpq.run()
#    raises PicklingError

  def test_mpPlot(self):
    pool = multiprocessing.Pool(processes=8)
    jobs = []
    num_figs = 10
    input = zip(np.random.randint(10,1000,num_figs), range(num_figs))
    #pool.map(plot, input)
    #pool.map(topoPlot,range(-5000,5000,1000))

    work = [[plot,input],[topoPlot,range(-5000,5000,1000)]]

   #for a,b in work:
   #  print a,b
   #  pool.map(a,b)

    for z in range(-5000,5000,1000):
      pool.apply_async(topoPlot,args=[z])

    pool.close()
    pool.join()


  def test_mpQueuePlot(self):
    """Test mp queue with outer function definition"""
    mpq = mpJobQueue(12)
    for z in range(-5000,5000,1000):
      mpq.push(topoPlot,z)
    mpq.run()

    pass

if __name__ == '__main__':
  unittest.main()

# vim:sw=2
