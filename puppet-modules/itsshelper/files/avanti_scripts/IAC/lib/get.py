#########################################################################################
# IAC - ITSS Artifactory Client
#
# get Command 
#
# Author: Des Drury     Date: 18/02/2014
#
# HISTORY
#
# 18/02/2014 DD   First Version.
#   
#########################################################################################

"""
Get a single file or all files from a CI in Artifactory. 

usage:
    get -r build -a <app> -c <ci> -v <ver> [-f <file>] [-t <dir>]
    get -r release -a <app> -v <ver> -c <ci> [-f <file>] [-t <dir>]

options:
    -r, --repo=<repo>   Must be either 'build' or 'release'.
    -a, --app=<app>     is the application name.
    -c, --ci=<ci>       is the configuration item name.
    -v, --ver=<ver>     is the configuration item version if getting
                        from the build repo.  Is the release version
                        if getting from the release repo.
    -f, --file=<file>   is a file.  If not specified all files 
                        from the CI will be downloaded.
    -t, --target=<dir>  is the target directory to download to.
                        Is current working directory by default.

examples:
    get -r build -a ITSS -c Logs -v 1.0.1.1 -f Logs-1.0.1.1.zip
    get -r release -a Avanti -v 11.3.4.1 -c ECV -t /build/ECV/ 
"""

# ITSS Artifactory Client (IAC) - Get Command

import requests
import os
import sys
import json
from docopt import docopt
if hasattr(sys,"frozen") and sys.frozen in ("windows_exe", "console_exe"):
    root_path = os.path.dirname(unicode(sys.executable, sys.getfilesystemencoding( )))
else:
    root_path = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
sys.path.append(root_path)
from lib import IAC, error
from lib.docopt import docopt

class GetArtifactory(IAC):
	
	_HEADERS = {'User-Agent': 'IAC-get/{{VERSION}}'}

	def __init__(self, arguments):
		self._get_config()
		self.repo = arguments['--repo']
		self.application = arguments['--app']
		self.ci = arguments['--ci']
		self.version = arguments['--ver']
	
	def show_header(self):
		print('\n+-------+')
		print('|  Get  |')
		print('+-------+\n')
		print('Repo    : {0}'.format(self.repo))
		print('App     : {0}'.format(self.application))
		
		if self.repo == self._BUILD_REPO:
			print('CI      : {0}'.format(self.ci))
			print('CI Ver  : {0}\n'.format(self.version))
		else:
			print('Rel Ver : {0}'.format(self.version))
			print('CI      : {0}\n'.format(self.ci))

	def get_file(self, filename, target_dir=None):	
		if not target_dir:
			target_dir = os.getcwd().replace('\\','/')

		if self.repo == self._BUILD_REPO:
			uri = '{0}/{1}/{2}/{3}/{4}/{5}'.format(self._BASE_ARTIFACTORY_URI,
										self.repo,
										self.application,
										self.ci,
										self.version,
										filename.lstrip('/'))
		else:
			uri = '{0}/{1}/{2}/{3}/{4}_{5}/{6}'.format(self._BASE_ARTIFACTORY_URI,
										self.repo,
										self.application,
										self.version,
										self.ci,
										self._get_ci_ver_for_release(self.application, self.version, self.ci),
										filename.lstrip('/'))
		response = requests.get(uri, auth=(self._USER, self._PASSWD), headers=self._HEADERS)
		if response.status_code == requests.codes.NOT_FOUND:
			message = ['File \'{0}\' not found.'.format(filename)]
			error(message)
		elif not response.ok:
			message = ['{0}'.format(response.text)]
			error(message)

		with open(os.path.join(target_dir,os.path.basename(filename)), 'w') as file:
			file.write(response.content)

		print('Downloaded file: {0}, to: {1}'.format(filename, target_dir))

	def get_ci(self, target_dir=None):

		if target_dir:
			target_dir = target_dir.rstrip('/')
			if not os.path.isdir(target_dir):
				try:
					os.makedirs(target_dir)
				except:
					messages = ['Target dir \'{0}\' does not exist and cannot be created.'.format(target_dir)]
					error(messages)
		else:
			target_dir = os.getcwd().replace('\\','/')

		if self.repo == self._BUILD_REPO:
			uri = '{0}/{1}/{2}/{3}/{4}?list=&deep=1&listFolders=1'.format(
										self._BASE_ARTIFACTORY_STORAGE_API_URI,
										self.repo,
										self.application,
										self.ci,
										self.version)
		else:
			uri = '{0}/{1}/{2}/{3}/{4}_{5}?list=&deep=1&listFolders=1'.format(
										self._BASE_ARTIFACTORY_STORAGE_API_URI,
										self.repo,
										self.application,
										self.version,
										self.ci,
										self._get_ci_ver_for_release(self.application, self.version, self.ci))
		response = requests.get(uri, auth=(self._USER, self._PASSWD), headers=self._HEADERS)
		if response.status_code != requests.codes.OK:
			error([response.text])

		items = response.json()['files']	
		for item in items:
			if item['folder'] == True:
				folder = '{0}{1}'.format(target_dir, item['uri'])
				print('Creating folder: {0}'.format(folder))
				try:
					if not os.path.exists(folder):
						os.makedirs(folder)
				except Exception as ex:
					messages = ['Unable to create dir \'{0}\'.'.format(folder)]
					messages += [ex]
					error(messages)
			else:
				directory = '{0}{1}'.format(target_dir, os.path.split(item['uri'])[0])
				self.get_file(item['uri'], directory)

	def validate(self):
		super(GetArtifactory, self).validate()

		if self.repo == self._BUILD_REPO:
			cis = self._get_cis(self.repo, self.application)
			if self.ci not in cis:
				messages = ['Configuration Item \'{0}\' not available.  Options are:'.format(self.ci)]
				messages += ['  ' + ' '.join(cis)]
				error(messages)

			versions = self._get_ci_versions(self.repo, self.application, self.ci)
			if self.version not in versions:
				messages = ['Version \'{0}\' not available.  Options are:'.format(self.version)]
				messages += ['  ' + ' '.join(versions)]
				error(messages)
		else:
			versions = self._get_rel_versions(self.application)
			if self.version not in versions:
				messages = ['Version \'{0}\' not available.  Options are:'.format(self.version)]
				messages += ['  ' + ' '.join(versions)]
				error(messages)

			ci_names = self._get_rel_ci_names(self.application, self.version)
			if self.ci not in ci_names:
				messages = ['CI \'{0}\' not available.  Options are:'.format(self.ci)]
				messages += ['  ' + ' '.join(ci_names)]
				error(messages)

			self._check_if_release_unlocked(self.application, self.version)

if __name__ == '__main__':
    arguments = docopt(__doc__, version='IAC - get command - version {{VERSION}}')
    if arguments['--repo'] not in ['build', 'release']:
    	print('Error: Repo must be either \'build\' or \'release\'')
    	sys.exit(1)
    else:
    	arguments['--repo'] = 'ITSS_{0}'.format(arguments['--repo'].upper())

    artifactory = GetArtifactory(arguments)
    artifactory.validate()
    artifactory.show_header()

    if not arguments['--file']:
    	artifactory.get_ci(arguments['--target'])
    else:
    	artifactory.get_file(arguments['--file'], arguments['--target'])
