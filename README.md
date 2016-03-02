# JobQueue / ParallelQueue - Let run your jobs in parallel

This repository containt JobQueue and ParallelQueue. Both libraries provide
similar functionality: Push arbitrary blocks of code to a Queue and execute
them on a user-defined number of Threads.

JobQueue offers no support for returning the results of the blocks, i.e. the
user has to collect them. ParallelQueue is based on [parallel]
(https://github.com/grosser/parallel, https://rubygems.org/gems/parallel) which
handles the return values internally and users can get the results
out-of-the-box. 

For the moment I keep both classes, but the ParallelQueue class is a lot
cleaner and also includes the slightly faster JobQueue implentation. That's why
I'll remove the JobQueue class sometime in the future.

jobQueue/parallelQueue can do the following things:

* Run blocks, Procs and Lambdas
* Run instance and class methods
* Respect user definded locks (not needed on ParallelQueue)
* Parallelizing System commands is removed, because it can easily be implemented with 'parallel'

I started a python2 implementation of this, which can be installed via [pip]
(https://pypi.python.org/pypi/jobqueue). But I stopped because the
multiprocessing.Pool module nearly does what I need ... and blocks do _not_
exist in python ;-)

## Installation

### Gem Installation

Download and install jobQueue with the following.

   gem install jobQueue
   gem install parallelQueue

### Requirements

JobQueue requires Ruby only, but versions 1.9.x are needed to make use of system threads.

## Usage

### Parallelize Ruby's blocks, procs, lambdas and things

Create a JobQueue with nThreads worker with:

  jq = JobQueue.new(nThreads)
  pq = ParallelQueue.new

ParallelQueue does not need the number of workers in the constructor. It has to
be provided in the run methods.

Use its push method to put in something to do

* For blocks:
    jq.push do
      myObject.method0(...)
      myObject.method1(...)
      myObject.method3(...)
    end

* For procs and lambdas: 
    
    jp.push(myProc,arg0,arg1,...)

* For object methods:

    jq.push([myObject,[:method,arg0,arg1,...])

* Same code can be used for class methods:

    jq.push(myClass,[:myClassMethod,arg0,arg1,...])

To start the workers, call 

`
  jq.run
  results = qp.run(8)
  pq.justRun(8)        # no results
`

That's it. You might have look at tests.

## Support, Issues, Bugs, ...

please use personal mail, ruby-lang mailing list or github

## Changelog

JobQueue:

* 1.0.11: prun.rb now ignores empty lines
* 1.0.10: more flexible logging control (new switches '-l' and '-b')
* 1.0.9: print out stdout and stderr from the jobs given to prun.rb, use '-D' to avoid printing
* 1.0.8: support AIX for getting the maximum number of processors, improve processor count for jruby and rbx

ParallelQueue:

* 1.0.0: parallel-based child-class of Queue, JobQueue.run is implementation as justRun

## Credits

[<b>Robert Klemme</b>] For the first hints: https://www.ruby-forum.com/topic/68001#86298

## License

jobQueue use the BSD License
parallelQueue use the IRC License

:include LICENSE


---

= Other stuff

Author::   Ralf Mueller <stark.dreamdetective@gmail.com>
Requires:: Ruby 1.9 or later
License::  Copyright 2011-2016 by Ralf Mueller
           Released under BSD-style license.  See the LICENSE
           file included in the distribution.
