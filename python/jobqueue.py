import Queue
import threading
import os,subprocess
# ==============================================================================
# Author: Ralf Mueller, ralf.mueller@zmaw.de
# ==============================================================================
class JobWorker(threading.Thread):
  # Create a new queue qith a given number of worker threads
  def __init__(self,queue,debug=False):
    threading.Thread.__init__(self)
    self.queue = queue
    self.debug = debug

  def run(self):
    while True:
      item = self.queue.get()
      print(item)
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
  def __init__(self,nWorkers,typ="internal",debug=False):
    self.workers = nWorkers
    self.queue   = Queue.Queue()
    self.debug   = debug

    for i in range(self.workers):
      if "internal" == typ:
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
    super(SystemJobs,self).__init__(nWorkers,"system",debug)

