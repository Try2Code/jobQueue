#!/usr/bin/env python
from setuptools import setup

setup (name   = 'jobqueue',
  version     = '0.0.2',
  author      = "Ralf Mueller",
  author_email= "stark.dreamdetective@gmail.com",
  license     = "BSD",
  description = """Queues with a user definied number of working threads """,
  py_modules  = ["jobqueue"],
  url         = "https://github.com/Try2Code/jobQueue",
  classifiers = [
        "Development Status :: 3 - Alpha",
        "Topic :: Utilities",
        "Programming Language :: Python",
    ],
  )
