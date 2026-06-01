#########################################################################################
# IAC - ITSS Artifactory Client
#
# get_latest Command 
#
# Author: Des Drury     Date: 19/02/2014
#
# HISTORY
#
# 19/02/2014 DD   First Version.
#   
#########################################################################################

"""
Get the latest version of a CI for an application.

usage:
    get_latest -a <app> -c <ci>

options:
    -a, --app=<app>   is the application name.
    -c, --ci=<ci>     is the configuration item name.

examples:
    get_latest -a Avanti -c ecv
"""

# ITSS Artifactory Client (IAC) - latest_ver Command

import requests
import os
import sys
import json
from distutils.version import LooseVersion
if hasattr(sys,"frozen") and sys.frozen in ("windows_exe", "console_exe"):
    root_path = os.path.dirname(unicode(sys.executable, sys.getfilesystemencoding( )))
else:
    root_path = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
sys.path.append(root_path)
from lib import IAC, error
from lib.docopt import docopt

class GetLatestArtifactory(IAC):

    _HEADERS = {'User-Agent': 'IAC-get_latest/{{VERSION}}'}

    def __init__(self, arguments):
        self._get_config()
        self.application = arguments['--app']
        self.ci = arguments['--ci']
        self.repo = self._BUILD_REPO

    def get_latest(self):
        versions = self._get_ci_versions(self.repo, self.application, self.ci)
        versions = [LooseVersion(version) for version in versions]
        print(sorted(versions)[len(versions)-1])

    def get_latest_startwith(self):
        versions = self._get_ci_versions_startwith(self.repo, self.application, self.ci, self.mayorversion)
        versions = [LooseVersion(version) for version in versions]
        print(sorted(versions)[len(versions)-1])

    def validate(self):
        super(GetLatestArtifactory, self).validate()

        cis = self._get_cis(self.repo, self.application)
        if self.ci not in cis:
            messages = ['Configuration Item \'{0}\' not available.  Options are:'.format(self.ci)]
            messages += ['  ' + ' '.join(cis)]
            error(messages)
            

if __name__ == '__main__':
    arguments = docopt(__doc__, version='IAC - get_latest command - version {{VERSION}}')

    artifactory = GetLatestArtifactory(arguments)
    artifactory.validate()
    artifactory.get_latest()
