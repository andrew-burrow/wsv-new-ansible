#########################################################################################
# IAC - ITSS Artifactory Client
#
# ci Command 
#
# Author: Des Drury     Date: 18/02/2014
#
# HISTORY
#
# 18/02/2014 DD   First Version.
#   
#########################################################################################

"""
List and show details of CIs for an application.

usage:
    ci list -a <app> 
    ci versions -a <app> -c <ci>
    ci show -a <app> -c <ci> -v <ver>

options:
    -a, --app=<app>   is the application name.
    -c, --ci=<ci>     is the configuration item name.
    -v, --ver=<ver>   is the configuration item version.

examples:
    ci list -a Avanti
    ci versions -a Avanti -c ecv
    ci show -a Avanti -c ecv -v 1.0.0
"""

# ITSS Artifactory Client (IAC) - Ci Command

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

class CiArtifactory(IAC):

    _HEADERS = {'User-Agent': 'IAC-ci/{{VERSION}}'}

    def __init__(self, arguments):
        self._get_config()
        self.application = arguments['--app']
        self.ci = arguments['--ci']
        self.version = arguments['--ver']
        self.repo = self._BUILD_REPO
        
    def list(self):     
        print('\n+-----------+')
        print('|  CI List  |')
        print('+-----------+\n')
        print('App : {0}\n'.format(self.application))

        for ci in self._get_cis(self.repo, self.application):
            print('  {0}'.format(ci))

    def versions(self):
        if self.ci not in self._get_cis(self.repo, self.application):
            error(['CI \'{0}\' does not exist'.format(self.ci)])

        print('\n+---------------+')
        print('|  CI Versions  |')
        print('+---------------+\n')
        print('App : {0}'.format(self.application))
        print('CI  : {0}\n'.format(self.ci))

        versions = self._get_ci_versions(self.repo, self.application, self.ci)
        versions = [LooseVersion(version) for version in versions]
        for version in sorted(versions):
            print('  {0}'.format(version))

    def show(self):
        if self.ci not in self._get_cis(self.repo, self.application):
            error(['CI \'{0}\' does not exist'.format(self.ci)])
        if self.version not in self._get_ci_versions(self.repo, self.application, self.ci):
            error(['Version \'{0}\' does not exist'.format(self.version)])

        print('\n+-----------+')
        print('|  CI Show  |')
        print('+-----------+\n')
        print('App    : {0}'.format(self.application))
        print('CI     : {0}'.format(self.ci))
        print('CI Ver : {0}'.format(self.version))
        print('\nProperties\n')

        build_ci_properties = self._get_build_ci_properties(self.application, self.ci, self.version)
        if build_ci_properties:
            for (property, value) in build_ci_properties.items():
                print('  {0} = {1}'.format(property, value))

if __name__ == '__main__':
    arguments = docopt(__doc__, version='IAC - ci command - version {{VERSION}}')

    artifactory = CiArtifactory(arguments)
    artifactory.validate()

    if arguments['list']:
        artifactory.list()
    elif arguments['versions']:
        artifactory.versions()
    elif arguments['show']:
        artifactory.show()