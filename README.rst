ArtExamScan
===========

ArtExamScan is a Python package for bulk processing of artisanally
hand-graded exams.

Installation
============

This code under active development at the moment, so it is best to
install from source into your preferred version of Python 3::

  python3 -m pip install mercurial
  python3 -m pip install hg+http://exam

ExamScanUIUC requires pdfimages, pdftoppm, and zbar, as well as
possibly pdftk.  

Usage
=====

Once installed, an exam can be tagged by using::

	> python -m examscanuiuc.tag exam.pdf

Later, scans of completed exams can be analysed by using::

	> python -m examscanuiuc.scan scan.pdf

For full examples of usage, see the ExamScanUIUC documentation, which can be open by using::

	> python -m examscanuiuc.doc


History
=======

The basic strategy used here originated in 2016 in Nathan Dunfield's
unpublished "examautomat" program.  In 2017, Marc C Bell did a
complete rewrite as `ExamScanUIUC
<https://bitbucket.org/Mark_Bell/examscanuiuc>`_.  This current
version derives from both sources, and is maintained by Nathan.  The
authors thank Pat Szuta and Malik Obeidin for their help on this project.

License
=======

This code is released under the open-source MIT 3-clause license.
