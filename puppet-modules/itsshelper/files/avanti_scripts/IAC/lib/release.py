#########################################################################################
# IAC - ITSS Artifactory Client
#
# release Command
#
# Author: Des Drury     Date: 18/02/2014
#
# HISTORY
#
# 18/02/2014 DD   First Version.
#
#########################################################################################

"""
Work with releases in Artifactory.

Note:
By default a new release will be based on the most recent release.
This can be overidden with the -b argument.

usage:
    release list -a <app>
    release show -a <app> -v <ver>
    release show_json -a <app> -v <ver>
    release create -a <app> -v <ver> [-b <base>]
    release ciadd -a <app> -v <ver> (-c <ci> -n <num>)...
    release cidel -a <app> -v <ver> -c <ci>...
    release lock -a <app> -v <ver>
    release unlock -a <app> -v <ver>
    release freeze -a <app> -v <ver>

commands:
    list    List all releases for an application.
    show    Show details of a particular release.
    show_json    Show details of a particular release json output.
    create  Create a release.
    ciadd   Add / replace CI(s) on a release. *
    cidel   Delete CI(s) on a release. *
    lock    Lock a release.
    Unlock    Lock a release. *
    freeze    Freeze a release.

* Note: This can only be done whilst the release is not locked.
* Note: This can only be done whilst the release is not freezed.

options:
    -a, --app=<app>    is the application name.
    -v, --ver=<ver>    is the version of the release.
    -b, --base=<base>  is the version of a previous release to use as the base.
    -c, --ci=<ci>      is the configuration item name.
    -n, --num=<num>    is the configuration item version (number).

examples:
    release list -a Avanti
    release show -a Novus -v 10.0.1
    release show_json -a Novus -v 10.0.1
    release create -a Avanti -v 11.4.1.1
    release ciadd -a Avanti -v 11.4.1.1 -c custom-webapp -v 11.4.1.1.12
    release cidel -a Avanti -v 11.4.1.1 -c custom-webapp
    release lock -a Avanti -v 11.4.1.1
    release unlock -a Avanti -v 11.4.1.1
"""

# ITSS Artifactory Client (IAC) - Release Command


import requests
import os
import sys
import re
import json

if hasattr(sys, "frozen") and sys.frozen in ("windows_exe", "console_exe"):
    root_path = os.path.dirname(
        unicode(sys.executable, sys.getfilesystemencoding()))
else:
    root_path = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
sys.path.append(root_path)
from lib import IAC, error, warning
from lib.docopt import docopt

class ReleaseArtifactory(IAC):

    _HEADERS = {'User-Agent': 'IAC-release/{{VERSION}}'}

    def __init__(self, arguments):
        self._get_config()
        self.application = arguments['--app']
        self.version = arguments['--ver']
        self.base_ver = arguments['--base']
        self.repo = self._RELEASE_REPO
        self.cis = arguments['--ci']
        self.nums = arguments['--num']

    def list(self):
        uri = '{0}/{1}/{2}/'.format(self._BASE_ARTIFACTORY_STORAGE_API_URI,
                                    self._RELEASE_REPO,
                                    self.application)
        response = self._get(uri)

        print('\n+----------------+')
        print('|  Release List  |')
        print('+----------------+\n')
        print('Application: {0}\n'.format(self.application))
        print('Releases\n')

        for item in response.json()['children']:
            if item['folder']:
                print(item['uri'].lstrip('/'))

    def show(self):
        # TODO: Don't forget to show the CIs in their groups

        self._check_rel_version_exists(self.application, self.version)
        uri = '{0}/{1}/{2}/{3}?list=&listFolders=1'.format(
            self._BASE_ARTIFACTORY_STORAGE_API_URI,
            self._RELEASE_REPO,
            self.application,
            self.version)
        response = self._get(uri)

        print('\n+----------------+')
        print('|  Release Show  |')
        print('+----------------+\n')
        print('App     : {0}'.format(self.application))
        print('Rel Ver : {0}'.format(self.version))
        print('Status  : {0}\n'.format(
            self._get_release_status(self.application, self.version)[0]))
        print('Configuration Items (CI)\n')

        cis = {}
        for item in response.json()['files']:
            if item['folder']:
                ci = item['uri'].lstrip('/')
                #ci = item['uri'][:item['uri'].rfind('_')].lstrip('/')
                ci_ver = item['uri'][item['uri'].rfind('_')+1:]
                cis[ci] = ci_ver

        longest = self._find_longest(cis.keys())
        for ci in cis:
            print (ci)
            #output = '  {0: <' + str(longest) + '} [{1}]'
            #print(output.format(ci, cis[ci]))

    def show_json(self):

        self._check_rel_version_exists(self.application, self.version)
        uri = '{0}/{1}/{2}/{3}?list=&listFolders=1'.format(
            self._BASE_ARTIFACTORY_STORAGE_API_URI,
            self._RELEASE_REPO,
            self.application,
            self.version)
        response = self._get(uri)

        cis = {}
        for item in response.json()['files']:
            if item['folder']:
                ci = item['uri'].lstrip('/')
                release_ci_name = re.split("(_[AN]-)",ci)[0]
                release_ci_version = re.split("(_[AN]-)",ci)[1] + re.split("(_[AN]-)",ci)[2]
                release_ci_version = release_ci_version[1:]
                #print ('ci name:: \'{0}\' - Value'.format(release_ci_name))
                #print ('ci Version:: \'{0}\' - Value'.format(release_ci_version))
                cis[release_ci_name] = release_ci_version
                
        
        json_cis = json.dumps(cis)
        print (json_cis)


    def create(self):
        rel_versions = self._get_rel_versions(self.application)
        if len(rel_versions) == 0:
            base_ver = 'N/A'
        elif self.base_ver:
            self._check_rel_version_exists(self.application, self.base_ver)
            base_ver = self.base_ver
        else:
            base_ver = 'N/A'
            #base_ver = sorted(rel_versions, reverse=True)[0]

        if self.version in rel_versions:
            warning(['Version \'{0}\' already exists.'.format(self.version)])
        if base_ver == self.version:
            error(['Version \'{0}\' and Base Version \'{1}\' are the same.'.format(base_ver,
                                                                                   self.version)])
        print('\n+------------------+')
        print('|  Release Create  |')
        print('+------------------+\n')
        print('App      : {0}'.format(self.application))
        print('New Ver  : {0}'.format(self.version))
        print('Base Ver : {0}\n'.format(base_ver))

        if base_ver == 'N/A':
            uri = '{0}/{1}/{2}/{3}/'.format(
                self._BASE_ARTIFACTORY_URI,
                self._RELEASE_REPO,
                self.application,
                self.version)
            self._put(uri)
        else:
            uri = '{0}/{1}/{2}/{3}?to=/{4}/{5}/{6}'.format(
                self._BASE_ARTIFACTORY_COPY_API_URI,
                self._RELEASE_REPO,
                self.application,
                base_ver,
                self._RELEASE_REPO,
                self.application,
                self.version)
            response = self._post(uri)

        uri = '{0}/{1}/{2}/{3}/?properties=status=unlocked;freeze=off&recursive=0'.format(
            self._BASE_ARTIFACTORY_STORAGE_API_URI,
            self._RELEASE_REPO,
            self.application,
            self.version)
        self._put(uri)
        print('Successfully Created\n')

    def ciadd(self):
        self._check_rel_version_exists(self.application, self.version)
        self._check_if_release_locked(self.application, self.version)
        self._check_if_release_freezed(self.application, self.version)

        print('\n+------------------+')
        print('|  Release CI Add  |')
        print('+------------------+\n')
        print('App     : {0}'.format(self.application))
        print('Rel Ver : {0}\n'.format(self.version))

        uri = '{0}/{1}/{2}/{3}?list=&listFolders=1'.format(
            self._BASE_ARTIFACTORY_STORAGE_API_URI,
            self._RELEASE_REPO,
            self.application,
            self.version)
        response = self._get(uri)

        release_cis = []
        for item in response.json()['files']:
            if item['folder']:
                ci = item['uri'][:item['uri'].rfind('_')].lstrip('/')
                ci_ver = item['uri'][item['uri'].rfind('_')+1:]
                release_cis.append((ci, ci_ver))

        cis = self._get_cis(self._BUILD_REPO, self.application)
        add_cis = zip(self.cis, self.nums)
        for ci in add_cis:
            if ci[0] not in cis:
                error(['\'{0}\' is not a CI.'.format(ci[0])])
            ci_versions = self._get_ci_versions(self._BUILD_REPO,
                                                self.application,
                                                ci[0])
            if ci[1] not in ci_versions:
                error(
                    ['\'{0}\' does not have a version \'{1}\''.format(ci[0], ci[1])])

            for release_ci in release_cis:
                if release_ci[0] == ci[0]:
                    print('Release already contains version \'{0}\' of \'{1}\'.'.format(
                        release_ci[1],
                        ci[0]))
                    print(
                        'It will be replaced with version \'{0}\'.'.format(ci[1]))
                    uri = '{0}/{1}/{2}/{3}/{4}_{5}'.format(
                        self._BASE_ARTIFACTORY_URI,
                        self._RELEASE_REPO,
                        self.application,
                        self.version,
                        release_ci[0],
                        release_ci[1])
                    self._delete(uri)

            print('Adding \'{0} [{1}]\''.format(ci[0], ci[1]))
            uri = '{0}/{1}/{2}/{3}/{4}?to=/{5}/{6}/{7}/{8}_{9}&suppressLayouts=1'.format(
                self._BASE_ARTIFACTORY_COPY_API_URI,
                self._BUILD_REPO,
                self.application,
                ci[0],
                ci[1],
                self._RELEASE_REPO,
                self.application,
                self.version,
                ci[0],
                ci[1])
            self._post(uri)
            print('Successfully Added\n')

    def cidel(self):
        self._check_rel_version_exists(self.application, self.version)
        self._check_cis_exist_on_release_no_error(
            self.cis, self.application, self.version)
        self._check_if_release_locked(self.application, self.version)
        self._check_if_release_freezed(self.application, self.version)

        print('\n+------------------+')
        print('|  Release CI Del  |')
        print('+------------------+\n')
        print('App     : {0}'.format(self.application))
        print('Rel Ver : {0}\n'.format(self.version))

        for ci in self.cis:
            ##choice = raw_input(
            ##    'Are you sure you want to delete the CI \'{0}\' (Y/N)? '.format(ci))
            ##if choice.lower() != 'y' and choice.lower() != 'n':
            ##    error(['you must enter either \'y\', \'Y\', \'n\' or \'N\''])
            ##if choice.lower() == 'n':
            ##    continue

            uri = '{0}/{1}/{2}/{3}/{4}_{5}'.format(
                self._BASE_ARTIFACTORY_URI,
                self._RELEASE_REPO,
                self.application,
                self.version,
                ci,
                self._get_ci_ver_for_release(self.application,
                                             self.version,
                                             ci))
            response = self._delete(uri)
            print('Successfully Deleted\n')

    def lock(self):
        self._check_rel_version_exists(self.application, self.version)
        self._check_if_release_locked(self.application, self.version)

        print('\n+----------------+')
        print('|  Release Lock  |')
        print('+----------------+\n')
        print('App     : {0}'.format(self.application))
        print('Rel Ver : {0}\n'.format(self.version))

        self._lock_release(self.application, self.version)
        print('Successfully Locked\n')

    def unlock(self):
        self._check_rel_version_exists(self.application, self.version)
        ##self._check_if_release_locked(self.application, self.version)
        ##self._check_if_release_freezed(self.application, self.version)

        print('\n+----------------+')
        print('|  Release UnLock  |')
        print('+----------------+\n')
        print('App     : {0}'.format(self.application))
        print('Rel Ver : {0}\n'.format(self.version))

        self._unlock_release(self.application, self.version)
        print('Successfully Unlocked\n')

    def freeze(self):
        self._check_rel_version_exists(self.application, self.version)
        ##self._check_if_release_locked(self.application, self.version)
        self._check_if_release_freezed(self.application, self.version)

        print('\n+----------------+')
        print('|  Release Freeze  |')
        print('+----------------+\n')
        print('App     : {0}'.format(self.application))
        print('Rel Ver : {0}\n'.format(self.version))

        self._freeze_release(self.application, self.version)
        print('Successfully Freezed\n')

if __name__ == '__main__':
    arguments = docopt(
        __doc__, version='IAC - release command - version {{VERSION}}')

    artifactory = ReleaseArtifactory(arguments)
    artifactory.validate()

    if arguments['list']:
        artifactory.list()
    elif arguments['show']:
        artifactory.show()
    elif arguments['show_json']:
        artifactory.show_json()        
    elif arguments['create']:
        artifactory.create()
    elif arguments['ciadd']:
        artifactory.ciadd()
    elif arguments['cidel']:
        artifactory.cidel()
    elif arguments['lock']:
        artifactory.lock()
    elif arguments['unlock']:
        artifactory.unlock()
    elif arguments['freeze']:
        artifactory.freeze()

