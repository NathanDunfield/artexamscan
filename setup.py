
from __future__ import print_function

# Needs:
#  pdftk
#  pdfimages
#  pdftoppm
#  zbar

import os
try:
	from setuptools import setup
except ImportError:
	print('Unable to import setuptools, using distutils instead.')
	from distutils.core import setup

this_directory = os.path.dirname(__file__)
source_directory = os.path.join(this_directory, 'source')
exec(open(os.path.join(source_directory, 'version.py')).read())  # Load in the variable __version__.

setup(
	name='artexamscan',
	version=__version__,
	description='Bulk processing of artisanally hand-graded exams.',
	author='Mark C Bell and Nathan M Dunfield',
	author_email='nathan@dunfield.info',
	url='https://bitbucket.org/nathan_dunfield/artexamscan',
	# Remember to update these if the directory structure changes.
	packages=[
		'artexamscan',
		'artexamscan.demo',
		'artexamscan.doc',
                'artexamscan.tag',
		'artexamscan.scan',
		],
	package_dir={'artexamscan': source_directory},
	package_data={
		'artexamscan.demo': ['*.pdf', '*.conf', '*.html', '*.xlsx'],
		'artexamscan.doc': ['artexamscan.pdf'],
		},
	install_requires=[
		# scan requirements.
		'six',
		'numpy',
		'scipy',
                'imageio',
		'scikit-image',
		'pandas',
		'xlrd',
		'libzbar-cffi',
                'PyPDF2',
		]
	)
