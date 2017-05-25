
ExamScan is a python package for adding and analysing tags on exams.
It can be run as a Python 2 or Python 3 module and has been tested on:

Installation
============

`ExamScan <https://pypi.python.org/examscan>`_ is available on the `Python Package Index <https://pypi.python.org>`_.
The preferred method for installing the latest stable release is to use `pip <http://pip.readthedocs.org/en/latest/installing.html>`_ (included in Python 2.7.9 and Python 3.4 by default)::

	> python -m pip install examscan --user --upgrade

ExamScan requires pdfimages, pdftoppm and zbar.

.. warning::
	The packages used by ExamScanUIUC require an updated version of the `six <https://pypi.org/project/six/>_` package.
	Since this is included as an Extra package in the included system Python on OS X, Mac users may need to:
	
	- install Python manually,
	- modify their \texttt{PYTHONPATH} environment variable, or
	- install ExamScanUIUC within \texttt{virtualenv}
	
	as described `here <http://stackoverflow.com/questions/29485741/unable-to-upgrade-python-six-package-in-mac-osx-10-10-2>_`.

Usage
=====

Once installed, an exam can be tagged by using::

	> python -m examscan.tag exam.pdf

Later, scans of completed exams can be analysed by using::

	> python -m examscan.scan scan.pdf

For full examples of usage, see the ExamScan documentation, which can be open by using::

	> python -m examscan.doc

Development
===========

The latest development version of ExamScan is available from `BitBucket <https://bitbucket.org/Mark_Bell/examscan>`_.
Alternatively, you can clone the mercurial repository directly using the command::

	> hg clone https://bitbucket.org/mark_bell/examscan

And then install by using::

	> python setup.py install --user
