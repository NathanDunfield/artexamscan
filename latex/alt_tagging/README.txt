Tagging exams via LaTeX
=======================

This directory describes an alternate way of adding the QR tags and
grader boxes to an exam. Instead of using Python combined with several
add-on packages, it requires only a reasonably recent TeX setup. The
disadvantage is that is considerably slower which is a real concern
when generating more than 1000 pages of exams.

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

For a 50% reduction in running time, one can use LuaLaTeX to compute
the QR codes.  Just make sure the file "qrencode.lua" is in the same
directory as "tickyoverlay.cls" and do

  lualatex m1-9am-tagged.tex
  lualatex m1-10am-tagged.tex


Timings
=======

Time needed to generate 100 copies of a 7 page exam (including
coversheet) on Nathan's 2014 MacPro:

1. PDFLaTeX: 3m38s

2. LuaLaTeX: 1m49s

Either way results in a 2.7M file.  If one removes the QR codes,
PDFLaTeX can assemble the copies into a 1.6M file in 1m05s with the
rest of the TikZ overlay. A straight-up use of PDFLaTeX's "pdfpages"
package creates a 0.2M files in just 9 seconds. 

