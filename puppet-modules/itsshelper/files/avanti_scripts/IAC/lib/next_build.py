#########################################################################################
# IAC - ITSS Artifactory Client
#
# next_build Command 
#
# Author: Des Drury     Date: 19/02/2014
#
# HISTORY
#
# 19/02/2014 DD   First Version.
#   
#########################################################################################

"""
Get the next build number of a CI for an application.

usage:
    next_build -a <app> -c <ci> -v <ver>

options:
    -a, --app=<app>   is the application name.
    -c, --ci=<ci>     is the configuration item name.
    -v, --ver=<ver>   is the configuration item version.

examples:
    next_build -a novus -c efile -v N-5.7.0.2.1
"""

# ITSS Artifactory Client (IAC) - next_build Command

import os
import sys
from distutils.version import LooseVersion
if hasattr(sys,"frozen") and sys.frozen in ("windows_exe", "console_exe"):
    root_path = os.path.dirname(unicode(sys.executable, sys.getfilesystemencoding( )))
else:
    root_path = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
sys.path.append(root_path)
from lib import IAC, error
from lib.docopt import docopt

class NextBuildArtifactory(IAC):

    _HEADERS = {'User-Agent': 'IAC-next_build/{{VERSION}}'}

    def __init__(self, arguments):
        self._get_config()
        self.application = arguments['--app']
        self.ci = arguments['--ci']
        self.version = arguments['--ver']
        self.repo = self._BUILD_REPO

    def next_build(self):

        cis = self._get_cis(self.repo, self.application)
        if self.ci not in cis:
            print('b001')
        elif self.version[self.version.rfind('.')+1:].lower().startswith('b'):
            error(['The supplied version includes a build number.  Please remove it.\n'])
        else:
            versions = self._get_ci_versions(self.repo, self.application, self.ci)
            matched_versions = [version for version in versions if version.startswith(self.version)]

            if matched_versions:
                latest_version = str(sorted([LooseVersion(version) for version in matched_versions], reverse = True)[0])
                if latest_version[latest_version.rfind('.')+1:].lower().startswith('b'):
                    new_build_num = 'b%s' % str(int(latest_version[latest_version.rfind('.')+1:][1:])+1).zfill(3)
                    print new_build_num
                else:
                    print('b001')
            else:
                print('b001')

    def validate(self):
        super(NextBuildArtifactory, self).validate()

if __name__ == '__main__':
    arguments = docopt(__doc__, version='IAC - get_latest command - {{VERSION}}')

    artifactory = NextBuildArtifactory(arguments)
    artifactory.validate()
    artifactory.next_build()