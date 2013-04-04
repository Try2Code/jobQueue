import Queue
import threading
import os,subprocess
import multiprocessing
# ==============================================================================
# Author: Ralf Mueller, ralf.mueller@zmaw.de
# ==============================================================================
def version(self):
  '0.0.2'

class JobWorker(threading.Thread):
  # Create a new queue qith a given number of worker threads
  def __init__(self,queue,debug=False):
    threading.Thread.__init__(self)
    self.queue = queue
    self.debug = debug

  def run(self):
    while True:
      item = self.queue.get()
      item()
      self.queue.task_done()

class SystemWorker(JobWorker):
  def call(self,cmd):
    if self.debug:
      print '# DEBUG ====================================================================='
      print 'CALL:' + cmd
      print '# DEBUG ====================================================================='

    proc = subprocess.Popen(cmd,
        shell  = True,
        stderr = subprocess.PIPE,
        stdout = subprocess.PIPE)
    retvals = proc.communicate()
    return {"stdout"     : retvals[0]
           ,"stderr"     : retvals[1]
           ,"returncode" : proc.returncode}

  def run(self):
    while True:
      item = self.queue.get()
      returnValues = self.call(item)
      print(returnValues["stdout"])
      self.queue.task_done()
# ==============================================================================
# Sized Queue for limiting the number of parallel jobs
# ==============================================================================
class JobQueue(object):
  def __init__(self,nWorkers,debug=False,mode="job"):
    self.workers = nWorkers
    self.queue   = Queue.Queue()
    self.debug   = debug
    self.mode    = mode

    for i in range(self.workers):
      if "job" == self.mode:
        t = JobWorker(self.queue,self.debug)
      else:
        t = SystemWorker(self.queue,self.debug)

      t.setDaemon(True)
      t.start()

  def push(self,item):
    self.queue.put(item)

  def run(self):
    self.queue.join()

class SystemJobs(JobQueue):
  def __init__(self,nWorkers,debug=False):
    super(SystemJobs,self).__init__(nWorkers,debug,"system")

class mpJobQueue(object):
  def __init__(self,nWorkers,debug=False):
    self.workers = nWorkers
    self.queue   = []
    self.debug   = debug
    self.pool  = multiprocessing.Pool(processes=nWorkers)

  def push(self,*item):
    self.queue.append(item)

  def run(self):
    for func,args in self.queue:
      self.pool.apply_async(func,[args])

    self.pool.close()
    self.pool.join()
