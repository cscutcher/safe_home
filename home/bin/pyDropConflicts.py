#!/usr/bin/env python
'''pyDropConflicts.py - Python Dropbox Conflict Resolver
Copyleft Eliphas Levy Theodoro
This script was primarily made for my personal conflict resolutions on Dropbox.
Being made public in hopes it will be of use of someone else.
'''
version = "0.4"
'''CHANGELOG
2009-05-24.0.1
	First try
2009-05-30.0.2
	Using pickles and base64 instead of raw binascii
2009-06-01.0.3
	Working around a possible bug in sqlite3 by opening db after chdir()
2010-03-31.0.4
	Supporting v2 database (0.8.x new config.db)
'''

import sqlite3, sys, os, re
from os.path import dirname, basename, getsize, getmtime, isfile, isdir, exists, join
from shutil import copy
from datetime import datetime as dt
from base64 import b64decode
from pickle import loads
db = 'dropbox.db'
simulate = True
if len(sys.argv) == 2:
	if sys.argv[1] == 'YES':
		simulate = False


def HumanSize(bytes):
	"""Humanize a given byte size"""
	if bytes/1024/1024/1024:
		return "%dG" % round(bytes/1024/1024/1024.0)
	if bytes/1024/1024:
		return "%dM" % round(bytes/1024/1024.0)
	elif bytes/1024:
		return "%dK" % round(bytes/1024.0)
	else:
		return "%dB" % bytes


ruler='-'*78
ruler2='='*78
dateFormat = "%Y-%m-%d %H:%M"

def GetFileDetails(filename):
	fsize = HumanSize(getsize(filename))
	fdate = dt.fromtimestamp(getmtime(filename)).strftime(dateFormat)
	return [fdate, fsize]


def GetDbFile():
	if sys.platform == 'win32':
		assert os.environ.has_key('APPDATA'), Exception('APPDATA env variable not found')
		dbpath = join(os.environ['APPDATA'],'Dropbox')
	elif sys.platform in ('linux2','darwin'):
		assert os.environ.has_key('HOME'), Exception('HOME env variable not found')
		dbpath = join(os.environ['HOME'],'.dropbox')
	else: # FIXME other archs?
		raise Exception('platform %s not known, please report' % sys.platform)
	print "Trying to open dropbox's database (%s):" % sys.platform
	if isfile(join(dbpath,'config.db')):
		return (join(dbpath,'config.db'), 2)
	elif isfile(join(dbpath, 'dropbox.db')):
		return (join(dbpath,'dropbox.db'), 1)
	else:
		raise Exception('Dropbox database not found, is dropbox installed?')


def GetDbFolder(db, version=1):
	dbpath, dbfile = dirname(db), basename(db)
	print 'Reading dropbox database'
	lastdir = os.getcwd()
	os.chdir(dbpath)
	connection = sqlite3.connect(dbfile, isolation_level=None)
	os.chdir(lastdir)
	cursor = connection.cursor()
	cursor.execute('SELECT value FROM config WHERE key="dropbox_path"')
	row = cursor.fetchone()
	cursor.close()
	connection.close()
	print 'Done reading database'
	if row is None:
		if sys.platform == 'win32':
			import ctypes
			dll = ctypes.windll.shell32
			buf = ctypes.create_string_buffer(300)
			dll.SHGetSpecialFolderPathA(None, buf, 0x0005, False)
			dbfolder = join(buf.value,'My Dropbox')
		elif sys.platform in ('linux2','darwin'):
			dbfolder = join(os.environ['HOME'],'Dropbox')
		else:
			raise Exception('platform %s not known, please report' % sys.platform)
		print 'No dropbox path defined in config, using default location %s' % dbfolder
		return dbfolder
	else:
		if version == 1:
			return loads(b64decode(row[0]))
		elif version == 2:
			return row[0]
		else:
			raise Exception('version not supported')

db, v = GetDbFile()
print 'Dropbox folder path is: %s (v%d)' % (db, v)
dbfolder = GetDbFolder(db, v)
assert isdir(dbfolder), Exception('Did not find Dropbox folder, please report')

conflicts = {}
print 'Starting directory walk and conflict find'
pattern = "^(.+) \((.+)'s conflicted copy ([0-9-]{10})\)(\..+)?$"
regex = re.compile(pattern)
copycount = 0
for curDir, dirs, files in os.walk(dbfolder):
	files.sort()
	for filename in files:
		if not isfile(join(curDir,filename)): continue # do NOT touch anything other than normal files
		fullfilename = join(curDir, filename)
		search = regex.search(filename)
		if search:
			conflictedname, computer, conflictlabel, extension = search.groups()
			if extension:
				conflictedname = conflictedname + extension
			details = GetFileDetails(fullfilename) + [filename, computer, conflictlabel]
			if conflicts.has_key((curDir, conflictedname)):
				conflicts[(curDir, conflictedname)].append(details)
				copycount+=1
			else:
				copycount+=1
				conflicts[(curDir, conflictedname)] = [details]
				basefile = join(curDir,conflictedname)
				if exists(basefile):
					copycount+=1
					details = GetFileDetails(basefile) + [conflictedname, 'CURRENT', 'CURRENT']
					conflicts[(curDir, conflictedname)].append(details)


if not len(conflicts):
	raw_input('Congratulations, no conflicting files found!\nPress <ENTER> to exit...')
	sys.exit(0)

print '%d files with %d conflicts found.\n' % (len(conflicts), copycount)
logFileName = join(dbfolder, 'pyDropConflicts.log')

print 'Opening log file'
logFile = file(logFileName,'w')
print 'All changes on filesystem will be logged to the file:\n', logFileName
if simulate:
	logFile.write(dt.now().strftime(dateFormat) + ' NOTICE: all changes here are SIMULATED. Nothing really has changed.\n')
else:
	logFile.write(dt.now().strftime(dateFormat) + ' Log Started.\n')

print 'Will display the copies ordered by modified time, most recently modified first.\n',

for conflDir, conflFile in sorted(conflicts.keys()):
	copies = conflicts[(conflDir, conflFile)]
	# sort copies by last changed
	copies.sort()
	copies.reverse()
	print ruler2, '\nFolder: %s' % conflDir
	print ruler,  '\nFile:   %s (%d copies)' % (conflFile, len(copies))
	print ruler,  '\n%5s %-25s %-15s %-17s %10s' % ('index','Computer','Label','Changed','Size')
	i = 0
	filenames = {}
	current = ''
	for copDate, copSize, copName, copComputer, copLabel, in copies:
		filenames[i] = copName
		if copLabel == 'CURRENT':
			current = copName
		print '%5d %-25s %-15s %-17s %10s' % (i, copComputer, copLabel, copDate, copSize)
		i+=1
	print ruler
	print 'Press <ENTER> to choose the most recent file (index-zero)'
	print 'Press a number and <ENTER> to choose your file by the index'
	print 'Press ''S'' and <ENTER> to skip, or ''Q'' and <ENTER> to Quit'
	while True:
		resp = raw_input('Choose [%sSQ]:' % ''.join([str(i) for i in range(len(copies))]))
		if resp in ('Q','q'):
			raw_input('Program quit.\nPress <ENTER> to exit...')
			sys.exit(0)
		if not resp: # defaults to most recent file
			resp='0'
		elif resp in ('S','s'):
			print '***Conflict skipped***'
			break
		elif not resp.isdigit():
			print 'Invalid answer.'
			continue
		resp = int(resp)
		if not resp in range(len(copies)):
			print 'Invalid answer. Choose again.'
			continue
		print 'You chose: ''%d'', which is the file:\n\n%s\n' % (resp, filenames[resp])
		if raw_input('Press ''B'' and <ENTER> to go back, or <ENTER> to confirm:') in ('B','b'):
			print 'Going back.'
			continue
		if filenames[resp] == current:
			for f in filenames.values():
				if f == current: continue
				logFile.write(dt.now().strftime(dateFormat) + ' removing: %s\n' % join(conflDir, f))
				if not simulate:
					os.unlink(join(conflDir, f))
			print '***Conflicting files removed, keeping CURRENT***'
		else:
			logFile.write(dt.now().strftime(dateFormat) + ' copying: ''%s'' to ''%s''\n' % (join(conflDir, filenames[resp]), join(conflDir, conflFile)))
			if not simulate:
				copy(join(conflDir, filenames[resp]), join(conflDir, conflFile))
			for f in filenames.values():
				if f == current: continue
				logFile.write(dt.now().strftime(dateFormat) + ' removing: %s\n' % join(conflDir, f))
				if not simulate:
					os.unlink(join(conflDir, f))
			print '***Conflicting files removed, keeping selected file as CURRENT***'
		break
	print ruler2, '\n'
logFile.close()
raw_input('Program end.\nPlease check the logfile at:\n%s\nPress <ENTER> to exit...' % logFileName)
sys.exit(0)
