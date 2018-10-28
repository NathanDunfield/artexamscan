''' Examscan is a program for adding tags to a pdf.  It can then
analyse scans of these exams to extract scoring information.

or analyse some completed exams by using:
    > python -m artexamscan.scan [options] '''

from .version import __version__
from . import tag
from . import scan
