''' Examscan is a program for adding tags to a pdf.  It can then
analyse scans of these exams to extract scoring information.

or analyse some completed exams by using:
    > python -m artexamscan.scan [options] '''

from artexamscan.version import __version__

import artexamscan.tag
import artexamscan.scan
