Installation
============

This code under active development at the moment, so it is best to
install from source into your preferred version of Python 3::

  python3 -m pip install https://bitbucket.org/nathan_dunfield/artexamscan/get/tip.zip

ArtExamScan requires pdfimages, pdftoppm, and zbar, as well as
possibly pdftk.  On Linux systems derived from Debian (e.g. Ubuntu),
do::

  apt-get install libzbar-dev poppler-utils pdftk

before executing the above command.


Usage
=====

The first step is to "tag" the exam PDF with the QR codes and grader
score boxes that will eventually be scanned. This requires only a
reasonably recent TeX setup and the files available `here
<https://bitbucket.org/nathan_dunfield/artexamscan/src/default/latex/tagging/>`_;
see the README file there for details.

For the mechanics of hand grading the exams see the `grading instructions
<https://bitbucket.org/nathan_dunfield/artexamscan/raw/default/latex/grader_instructions/grader_instructions.pdf>`_

After scanning the exams (which must be done rotated 180 degrees), do
something like::

  python3 -m artexamscan.scan --roster=roster.csv scans/*.pdf

to read in all the scores, which are eventually dumped it "results.csv".


History
=======

The basic strategy used here originated Nathan Dunfield's unpublished
"examautomat" program written in 2016.  In 2017, Marc C Bell did a
complete rewrite as `ExamScanUIUC
<https://bitbucket.org/Mark_Bell/examscanuiuc>`_.  This current
version derives from both sources, and is maintained by Nathan.  The
authors thank Pat Szuta and Malik Obeidin for their help on this
project.


License
=======

This code is released under the open-source MIT 3-clause license.
