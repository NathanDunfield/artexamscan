
import time
import os, json, hashlib, glob
import pandas as pd
import numpy as np
import shutil
from six.moves import input

try:
	from itertools import imap
except ImportError:  # Python 3.
	imap = map

from examscanuiuc.scan import Roster, PDFPages, image_from_pdf, read_page_id, read_uin, read_tickbox
from examscanuiuc.scan import ScoreReadError, CouldNotGetQRCode
from .manual import manual_process_page
import examscanuiuc.scan.report

ERROR, UIN, SCORE = 'Error', 'UIN', 'Score'

def md5_hash(file_path):
	with open(file_path, 'rb') as input_file:
		return hashlib.md5(input_file.read()).hexdigest()

def setup_directories():
	output_dirs = ['exams', 'finished', 'manual', 'scores', 'errors', 'uins']

	for name in output_dirs:
		full_name = os.path.join('tmp', name)
		if not os.path.exists(full_name):
			os.makedirs(full_name)

def load_data(directory):
	ans = [json.loads(line.strip()) for file_path in glob.glob(directory + '/*.json') for line in open(file_path).readlines() if line.strip()]
	if len(ans) == 0: return pd.DataFrame()
	return pd.DataFrame(ans)

def process_page(file_name, page_num, page_path, roster):
	image = image_from_pdf(page_path)
	try:
		parts = read_page_id(image).split(',')
		extras = dict()
		if len(parts) == 7:
			term, CRN, exam_name, exam_version, exam_num, exam_pagenum, page_max = read_page_id(image).split(',')
			parts = [exam_num, exam_pagenum, page_max]
			extras = {'term':term, 'CRN':int(CRN), 'exam_name':exam_name, 'exam_version':exam_version}
		if len(parts) == 9:
			term, course, CRN, instr_netid, exam_name, exam_version, exam_num, exam_pagenum, page_max = read_page_id(image).split(',')
			parts = [exam_num, exam_pagenum, page_max]
			extras = {'term':term, 'course':int(course), 'CRN':int(CRN), 'exam_name':exam_name, 'exam_version':exam_version}
		exam_num, exam_pagenum, page_max = [int(p) for p in parts]
		message = ''
		if exam_pagenum == 1:
			state = UIN
			uin = read_uin(image)
			matched = roster.match(uin)
			if matched['UIN'] != uin:
				message = 'Warning on page %s: UIN fudged %s -> %s' % (page_num, uin, matched['UIN'])
			matched['exam'] = exam_num
			parsed = dict(matched)
			parsed.update(extras)
		else:
			state = SCORE
			score, quality = read_tickbox(image)
			if score > page_max: raise ValueError('Tried to award %d on %d point question.' % (score, page_max))
			parsed = {'exam': exam_num, 'page': exam_pagenum, 'score': score, 'tickcertainty': quality}

		this_exam_dir = os.path.join('tmp', 'exams', str(exam_num))
		if not os.path.exists(this_exam_dir): os.makedirs(this_exam_dir)
		shutil.copy(page_path, os.path.join(this_exam_dir, '%d.pdf' % exam_pagenum))
	except (CouldNotGetQRCode, ScoreReadError, ValueError) as error:
		state = ERROR
		parsed = None
		error_str = error if isinstance(error, str) else error.args[0]
		message = 'Error on page %d of %s: ' % (page_num, file_name) + error_str
		shutil.copy(page_path, os.path.join('tmp', 'errors', '%s_%d.pdf' % (file_name, page_num)))

	return state, parsed, message

def helper(data):
	return process_page(*data)

def process_file(file_path, roster, reprocess=False, perfect=False, mapper=None):
	setup_directories()
	file_path_hash = md5_hash(file_path)
	file_name = os.path.basename(file_path)
	if os.path.exists(os.path.join('tmp', 'finished', file_path_hash)) and not reprocess:
		print('Skipping as already finished: ' + file_name)
		return

	print('Starting processing of: ' + file_name)

	# Split the PDF
	pages = PDFPages(file_path)

	# Now operate on each page
	todo = [(file_name, index, page_file_path, roster) for index, page_file_path in enumerate(pages, start=1)]

	if mapper is None:
		results = imap(helper, todo)
	else:
		results = mapper(helper, todo)

	error_count = 0
	with open(os.path.join('tmp', 'uins', '%s.json' % file_name), 'w') as uins:
		with open(os.path.join('tmp', 'scores', '%s.json' % file_name), 'w') as scores:
			for state, parsed, message in results:
				print(state, parsed)
				if state == ERROR:
					error_count += 1
				if state == UIN:
					uins.write(json.dumps(parsed) + '\n')
				if state == SCORE:
					scores.write(json.dumps(parsed) + '\n')

				if message:
					print('   ' + message)

	print('Processed %d pages with %d errors\n' % (len(todo), error_count))

	if error_count == 0 or not perfect:
		# Skip this file next time
		with open(os.path.join('tmp', 'finished', file_path_hash), 'w') as f:
			f.write('')

def collate(uins_path, scores_path):
	df = load_data(uins_path)
	needed_cols = ['exam', 'UIN', 'name', 'netid']
	if df.empty:
		df = pd.DataFrame(columns=needed_cols)
	df = df.drop_duplicates(['netid'])
	df = df.drop_duplicates(['exam'])

	ds = load_data(scores_path)
	if not ds.empty:
		ds = ds[['exam', 'page', 'score']]
		ds = ds.drop_duplicates()
		ds = ds.pivot(index='exam', columns='page', values='score')

	ds['score'] = ds.sum(axis=1)
	ds.score.astype(int)
	ds.loc[ds.isnull().any(axis=1), 'score'] = np.nan

	return df.join(ds, on='exam', how='outer')

if __name__ == '__main__':
	import argparse
	parser = argparse.ArgumentParser(description='Extract tagged exams')
	parser.add_argument('files', nargs='*', type=str, default='', help='files to process')
	parser.add_argument('--roster', required=True, type=str, help='roster file')
	parser.add_argument('--reprocess', action='store_true', help='reprocess files that have already been completed')
	parser.add_argument('--perfect', action='store_true', help='only mark a file as complete if there were no errors')
	parser.add_argument('--results', type=str, default='results.csv', help='results output file')
	parser.add_argument('--template', type=str, help='report template to use')
	parser.add_argument('--reports', type=str, default='reports', help='report output directory')
	parser.add_argument('--cpus', type=int, default=1, help='number of cpus to use at once')
	args = parser.parse_args()

	roster = Roster.from_file(args.roster)

	if args.cpus > 1:
		import multiprocessing
		pool = multiprocessing.Pool(args.cpus)
		mapper = pool.map
	else:
		mapper = None

	for file_path in args.files:
		process_file(file_path, roster, reprocess=args.reprocess, perfect=args.perfect, mapper=mapper)

	manual_pages = sorted(glob.glob('tmp/errors/*.pdf'))
	print('%d page(s) require manual entry.' % len(manual_pages))
	if manual_pages:
		ans = input('Enter "Yes" to correct now: ')
		if ans.lower()[0] == 'y':
			for page_path in manual_pages:
				if not manual_process_page(page_path, roster): break

	results = collate('tmp/uins', 'tmp/scores')
	unmatched = roster.roster[-roster.roster.UIN.isin(results.UIN)]  # The students we don't have anything for.

	print('Progress:')
	for column in sorted(results.columns, key=str):
		missing = results[column].isnull()
		print('\tPage %s: Have %s, missing %s' % (column, sum(-missing), sum(missing)))

	num_incomplete = len(results[results.isnull().any(axis=1)])
	print('%d exams with complete information.' % (len(results) - num_incomplete))
	print('%d exams with incomplete information.' % num_incomplete)
	print('%d students in roster without an exam assigned.' % len(unmatched))

	if num_incomplete:
		print('\tProcess more files and/or deal with any errors to begin report generation.')
		exit(0)

	print('Saving results to "%s".' % args.results)
	results.to_csv(args.results, index=False)

	if args.template is not None:
		print('Generating report:')
		examscanuiuc.scan.report.main(results, args.template, args.reports)
	else:
		print('\tRerun with --template to generate student reports.')
