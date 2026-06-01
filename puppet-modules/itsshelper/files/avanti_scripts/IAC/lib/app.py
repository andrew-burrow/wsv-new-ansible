#########################################################################################
# IAC - ITSS Artifactory Client
#
# app Command 
#
# Author: Des Drury     Date: 18/02/2014
#
# HISTORY
#
# 18/02/2014 DD   First Version.
#   
#########################################################################################

"""
List and show details of applications.

usage:
    app list  
    app show -a <app> 

options:
    -a, --app=<app>   is the application name.

examples:
    app list
    app show -a Avanti
"""

# ITSS Artifactory Client (IAC) - App Command

import os
import sys
import json
import requests
from docopt import docopt

if hasattr(sys,"frozen") and sys.frozen in ("windows_exe", "console_exe"):
    root_path = os.path.dirname(unicode(sys.executable, sys.getfilesystemencoding( )))
else:
    root_path = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
sys.path.append(root_path)
from lib import IAC, error


class AppArtifactory(IAC):

    _HEADERS = {'User-Agent': 'IAC-app/{{VERSION}}'}

    def __init__(self, arguments):
        self._get_config()
        self.application = arguments['--app']        
        self.repo = self._BUILD_REPO
        
    def list(self):     
        print('\n+------------+')
        print('|  App List  |')
        print('+------------+\n')
        
        for application in self._get_applications():
            print(application)

    def show(self):
        print('\n+------------+')
        print('|  App Show  |')
        print('+------------+\n')
        print('App    : {0}\n'.format(self.application))

        print('CIs\n')
        for ci in self._get_cis(self._BUILD_REPO, self.application):
            print('  {0}'.format(ci))

if __name__ == '__main__':
    arguments = docopt(__doc__, version='IAC - app command - version {{VERSION}}')

    artifactory = AppArtifactory(arguments)
    
    if arguments['list']:
        artifactory.list()
    elif arguments['show']:
        artifactory.validate()
        artifactory.show()