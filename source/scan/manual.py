
import os, sys, json, subprocess
import examscanuiuc
from six.moves import input

def default_open(file_path):
	if sys.platform.startswith('darwin'):
	    subprocess.call(['open', file_path])
	elif os.name == 'nt':
	    os.startfile(file_path)
	elif os.name == 'posix':
	    subprocess.call(['xdg-open', file_path])

def manual_process_page(page_path, roster):
	print('Processing %s' % os.path.basename(page_path))
	default_open(page_path)

	image = examscanuiuc.scan.image_from_pdf(page_path)
	try:
		parts = examscanuiuc.scan.read_page_id(image).split(',')
		extras = dict()
		if len(parts) == 7:
			term, CRN, exam_name, exam_version, exam_num, exam_pagenum, page_max = examscanuiuc.scan.read_page_id(image).split(',')
			parts = [exam_num, exam_pagenum, page_max]
		if len(parts) == 9:
			term, course, CRN, instr_netid, exam_name, exam_version, exam_num, exam_pagenum, page_max = examscanuiuc.scan.read_page_id(image).split(',')
			parts = [exam_num, exam_pagenum, page_max]
		exam_num, exam_pagenum, page_max = [int(p) for p in parts]
	except examscanuiuc.scan.CouldNotGetQRCode:
		print('Could not read QR code.')
		exam_num = input('Enter exam number: ')
		if exam_num == '': return False
		exam_pagenum = input('Enter page number: ')
		if exam_pagenum == '': return False
		page_max = input('Enter max score: ')
		if page_max == '': return False
		exam_num, exam_pagenum, page_max = int(exam_num), int(exam_pagenum), int(page_max)

	if exam_pagenum == 1:
		try:
			uin = examscanuiuc.scan.read_uin(image)
		except examscanuiuc.scan.ScoreReadError:
			uin = input('Enter correct UIN: ')
			if uin == '': return False
		try:
			matched = roster.match(uin)
		except examscanuiuc.scan.errors.ScoreReadError:
			uin = input('Enter correct UIN: ')
			matched = roster.match(uin)
		if matched['UIN'] != uin:
			print('Entered UIN: %d matched %d of %s' % (uin, matched['UIN'], dict(matched)))
			ans = input('Enter "Yes" to accept this correction: ')
			if ans != 'Yes': return False
		matched['exam'] = exam_num
		parsed = dict(matched)

		with open(os.path.join('tmp', 'uins', 'manual.json'), 'a') as uins:
			uins.write(json.dumps(parsed) + '\n')
	else:
		try:
			score, quality = examscanuiuc.scan.read_tickbox(image)
			if score > page_max: raise ValueError('Tried to award %d on %d point question.' % (score, page_max))
		except examscanuiuc.scan.ScoreReadError:
			score = input('Enter correct score: ')
			if score == '': return False
			score, quality = int(score), 10

		assert(0 <= score <= page_max)
		parsed = {'exam': exam_num, 'page': exam_pagenum, 'score': score, 'tickcertainty': quality}
		with open(os.path.join('tmp', 'scores', 'manual.json'), 'a') as scores:
			scores.write(json.dumps(parsed) + '\n')

	this_exam_dir = os.path.join('tmp', 'exams', str(exam_num))
	if not os.path.exists(this_exam_dir): os.makedirs(this_exam_dir)
	subprocess.call(['cp', page_path, os.path.join(this_exam_dir, str(exam_pagenum) + '.pdf')])
	subprocess.call(['mv', page_path, os.path.join('tmp', 'manual')])
	return True
