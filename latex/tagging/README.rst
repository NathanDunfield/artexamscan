Tagging exams via LaTeX
=======================

This directory describes how to add the QR tags and grader boxes to an
exam. It requires only a reasonably recent TeX setup. Provided you use
LuaLaTeX, you can tag 1,500+ pages/minute using this method.

An example
==========

Here is a simple example with two exam versions where we want 10
copies of each, numbered 1-10 and 11-20 respectively.

1. The instructor provides PDF files for each version, in our example
   "m1-9am.pdf" and "m1-10am.pdf" as well as a PDF of the desired
   coversheet, here "cover.pdf".  (You can use different cover sheets
   with different versions if you want.)

2. To tag an exam, one creates very short LaTeX files, here called
   "m1-9am-tagged.tex" and "m1-10am-tagged.tex".  These rely on the
   included LaTeX class "tickyoverlay.cls". You will need to
   modify the "examdefault" parameters in the file to suit.

3. Now just run PDFLaTeX on these files::

     pdflatex m1-9am-tagged.tex
     pdflatex m1-10am-tagged.tex

   which will generate two 70 page PDF files, one for each version.

     
LuaLaTeX
========

For a 4 times speedup, one can use LuaLaTeX instead of PDFLaTeX. Just
make sure the file "qrencode.lua" is in the same directory as
"tickyoverlay.cls" and then do::

  lualatex m1-9am-tagged.tex
  lualatex m1-10am-tagged.tex


Timings
=======

Time needed to generate 100 copies of a 7 page exam (including
coversheet) on Nathan's 2014 MacPro:

1. PDFLaTeX: 2 minutes 43 seconds

2. LuaLaTeX: 28 seconds

The first way results in a 3M file, the second in a 2.2M one.

