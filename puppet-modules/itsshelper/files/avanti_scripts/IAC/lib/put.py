#########################################################################################
# IAC - ITSS Artifactory Client
#
# put Command 
#
# Author: Des Drury     Date: 18/02/2014
#
# HISTORY
#
# 14/04/2014 RE   Added checksum algorithm to file/folder deployments to artifactory
# 18/02/2014 DD   First Version.
#   
#########################################################################################

"""
Put a file or directory into Artifactory.  If a directory it will be recursed.

usage:
    put -a <app> -c <ci> -v <ver> (-f <file> | -d <dir>) [-p <property>=<name>]...

options:
    -a, --app=<app>   is the application name.
    -c, --ci=<ci>     is the configuration item name.
    -v, --ver=<ver>   is the configuration item version.
    -f, --file=<file> is the file.
    -d, --dir=<dir>   is the directory.
    -p, --props=<property>=<value>  A property / value pair.

examples:
    put -a ITSS -c Logs -v 1.0.1.1 -f Logs-1.0.1.1.zip
    put -a Avanti -c ECV -v 11.3.4.1 -d c:/build/ECV/ -p status=built
"""

# ITSS Artifactory Client (IAC) - Put Command

# BUG: It appears that Artifactory will not allow a file of 0 bytes to be uploaded!

import requests
import os
import sys
import json
import hashlib
if hasattr(sys,"frozen") and sys.frozen in ("windows_exe", "console_exe"):
    root_path = os.path.dirname(unicode(sys.executable, sys.getfilesystemencoding( )))
else:
    root_path = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
sys.path.append(root_path)
from lib import IAC, error
from lib.docopt import docopt

class PutArtifactory(IAC):

	_HEADERS = {'User-Agent': 'IAC-put/{{VERSION}}'}

	def __init__(self, arguments):
		self._get_config()
		self.repo = self._BUILD_REPO
		self.application = arguments['--app']
		self.ci = arguments['--ci']
		self.version = arguments['--ver']
		self.properties = arguments['--props']
		
	def show_header(self):
		print('\n+-------+')
		print('|  Put  |')
		print('+-------+\n')
		print('App    : {0}'.format(self.application))
		print('CI     : {0}'.format(self.ci))
		print('CI Ver : {0}\n'.format(self.version))


	def put_file(self, filename, root=None):
		if root and root == '.':
			uri_filename = filename.lstrip('./')
		elif root:
			uri_filename = filename.split(root)[1]
		else:
			uri_filename = filename

		uri_filename = os.path.join(os.path.dirname(os.path.splitdrive(uri_filename)[1]), 
									os.path.basename(uri_filename)).replace('\\','/')
		
		# Hack to remove svn files
		if '.svn' not in uri_filename:

			print('Putting: {0}'.format(filename))
			uri = '{0}/{1}/{2}/{3}/{4}/{5}'.format(self._BASE_ARTIFACTORY_URI,
										self.repo,
										self.application,
										self.ci,
										self.version,
										uri_filename)

			self._HEADERS.update({'X-Checksum-Sha1': self.sha1OfFile(filename)})
			with open(filename, 'rb') as f:
			    response = requests.put(uri, data=f, auth=(self._USER, self._PASSWD), headers=self._HEADERS)
			
			if response.status_code != requests.codes.CREATED:
				error([response.text])

			# Set properties on the version directory and recusre on all files / folders.
			properties = '|'.join(self.properties)
			uri = '{0}/{1}/{2}/{3}/{4}?properties={5}'.format(self._BASE_ARTIFACTORY_STORAGE_API_URI,
										self.repo,
										self.application,
										self.ci,
										self.version,
										properties)
			response = requests.put(uri, auth=(self._USER, self._PASSWD), headers=self._HEADERS)
			if response.status_code != requests.codes.NO_CONTENT:
				error([response.text])


	def recurse_dir(self, dir):
		for root, dirs, files in os.walk(dir):
			for filename in files:
				if root != '.':
					filename = os.path.join(root, filename)
				filename = filename.replace('\\', '/')
				self.put_file(filename.rstrip('/'), dir)

	def validate(self):
		super(PutArtifactory, self).validate()
		if self.ci in self._get_cis(self._BUILD_REPO, self.application):
			if self.version in self._get_ci_versions(self._BUILD_REPO, self.application, self.ci):
				error(['Version \'{0}\' already exists.'.format(self.version)])

	def sha1OfFile(self, filepath):
		with open(filepath, 'rb') as f:
			return hashlib.sha1(f.read()).hexdigest()

				
				
if __name__ == '__main__':
    arguments = docopt(__doc__, version='IAC - put command - version {{VERSION}}')
    
    artifactory = PutArtifactory(arguments)
    artifactory.validate()
    artifactory.show_header()

    if arguments['--file']:
    	if os.path.isfile(arguments['--file']):
    		artifactory.put_file(arguments['--file'])
    	else:
    		message = ['\'{0}\' is not a file'.format(arguments['--file'])]
    		error(message)
    else:
    	if os.path.isdir(arguments['--dir']):
    		artifactory.recurse_dir(arguments['--dir'])
    	else:
    		message = ['\'{0}\' is not a directory'.format(arguments['--dir'])]
    		error(message)

