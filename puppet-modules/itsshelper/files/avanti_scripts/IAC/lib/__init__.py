#########################################################################################
# IAC - ITSS Artifactory Client
#
# Base IAC class and eror function
#
# Author: Des Drury     Date: 18/02/2014
#
# HISTORY
#
# 18/02/2014 DD   First Version.
#
#########################################################################################

# TODO: Add the keystore library for storing the password!
# TODO: Add proper logging library
# TODO: Freeze the code for Windows and Unix

__version__ = '{{VERSION}}'
__built_on__ = '{{BUILD_DATE}}'
__author__ = 'Des Drury'

import requests
import sys
import os
import re
from ConfigParser import ConfigParser

if hasattr(sys, "frozen") and sys.frozen in ("windows_exe", "console_exe"):
    root_path = os.path.dirname(
        unicode(sys.executable, sys.getfilesystemencoding()))
else:
    root_path = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))


class IAC(object):

    _BUILD_REPO = 'ITSS_BUILD'
    _RELEASE_REPO = 'ITSS_RELEASE'

    def _get_config(self):
        config_file = '%s/config/artificatory.ini' % root_path
        config = ConfigParser()
        config.read(config_file)
        self._BASE_ARTIFACTORY_URI = config.get(
            'common', 'BASE_ARTIFACTORY_URI')
        self._BASE_ARTIFACTORY_STORAGE_API_URI = '{0}/api/storage'.format(
            self._BASE_ARTIFACTORY_URI)
        self._BASE_ARTIFACTORY_COPY_API_URI = '{0}/api/copy'.format(
            self._BASE_ARTIFACTORY_URI)
        self._USER = config.get('common', 'USER')
        self._PASSWD = config.get('common', 'PASSWD')

    def __get_folders(self, uri):
        response = requests.get(uri, auth=(
            self._USER, self._PASSWD), headers=self._HEADERS)
        if response.status_code != requests.codes.OK:
            error([response.text])

        folders = []
        for item in response.json()['files']:
            if item['folder'] == True:
                folders.append(item['uri'][1:])

        return folders

    def __check_response(self, response):
        if not response.ok:
            error(['{0}'.format(response.reason)])
        return response

    def _get(self, uri):
        response = requests.get(uri, auth=(
            self._USER, self._PASSWD), headers=self._HEADERS)
        return self.__check_response(response)

    def _getIgnore404(self, uri):
        response = requests.get(uri, auth=(
            self._USER, self._PASSWD), headers=self._HEADERS)
        if response.status_code == 404:
            return None
        return self.__check_response(response)

    def _put(self, uri):
        response = requests.put(uri, auth=(
            self._USER, self._PASSWD), headers=self._HEADERS)
        return self.__check_response(response)

    def _post(self, uri):
        response = requests.post(uri, auth=(
            self._USER, self._PASSWD), headers=self._HEADERS)
        return self.__check_response(response)

    def _delete(self, uri):
        response = requests.delete(uri, auth=(
            self._USER, self._PASSWD), headers=self._HEADERS)
        return self.__check_response(response)

    def _get_applications(self):

        uri = '{0}/{1}?list=&listFolders=1'.format(
            self._BASE_ARTIFACTORY_STORAGE_API_URI,
            self.repo)
        return self.__get_folders(uri)

    def _get_cis(self, repo, application):

        uri = '{0}/{1}/{2}?list=&listFolders=1'.format(
            self._BASE_ARTIFACTORY_STORAGE_API_URI,
            repo,
            application)
        return self.__get_folders(uri)

    def _get_ci_versions(self, repo, application, ci):
        uri = '{0}/{1}/{2}/{3}?list=&listFolders=1'.format(
            self._BASE_ARTIFACTORY_STORAGE_API_URI,
            repo,
            application,
            ci)
        return sorted(self.__get_folders(uri))

    def _get_ci_versions_startwith(self, repo, application, ci, base_ver):
        uri = '{0}/{1}/{2}/{3}?list=&listFolders=1'.format(
            self._BASE_ARTIFACTORY_STORAGE_API_URI,
            repo,
            application,
            ci)

        elements = self.__get_folders(uri)

        if len(elements) > 0:
            elements_filtered = [
                i for i in elements if i.startswith(self.base_ver)]

        if len(elements_filtered) <= 0:
            if self.base_ver not in self._get_ci_versions(self.repo, self.application, self.ci):
                error(['Version \'{0}\' does not exist'.format(self.base_ver)])

        return sorted(elements_filtered)

    def _get_ci_ver_for_release(self, application, version, ci_name):
        uri = '{0}/{1}/{2}/{3}?list=&listFolders=1'.format(
            self._BASE_ARTIFACTORY_STORAGE_API_URI,
            self._RELEASE_REPO,
            application,
            version)
        release_cis = self.__get_folders(uri)
        print (release_cis)
        for ci in release_cis:
            if ci[:ci.rfind('_A-')] == ci_name:
                return ci[ci.rfind('_A-')+1:]

    def _check_ci_version_exists(self, ci_name, version):
        pass

    def _check_cis_exist_on_release(self, cis, application, version):
        uri = '{0}/{1}/{2}/{3}?list=&listFolders=1'.format(
            self._BASE_ARTIFACTORY_STORAGE_API_URI,
            self._RELEASE_REPO,
            application,
            version)
        release_cis = self.__get_folders(uri)
        release_ci_names = []

        for release_ci in release_cis:
            #release_ci_name = release_ci.split('_')[0]
            release_ci_name = re.split("_[AN]-", release_ci, 0)[0]
            release_ci_names.append(release_ci_name)

        # if not set(cis).issubset(release_ci_names):
        for ci in cis:
            if ci not in release_ci_names:
                error(
                    ['Cannot find CI named \'{0}\' attached to the release'.format(ci)])

    def _check_cis_exist_on_release_no_error(self, cis, application, version):
        uri = '{0}/{1}/{2}/{3}?list=&listFolders=1'.format(
            self._BASE_ARTIFACTORY_STORAGE_API_URI,
            self._RELEASE_REPO,
            application,
            version)
        release_cis = self.__get_folders(uri)
        release_ci_names = []

        for release_ci in release_cis:
            #release_ci_name = release_ci.split('_')[0]
            release_ci_name = re.split("_[AN]-", release_ci, 0)[0]
            release_ci_names.append(release_ci_name)

        # if not set(cis).issubset(release_ci_names):
        for ci in cis:
            if ci not in release_ci_names:
                warning(
                    ['Cannot find CI named \'{0}\' attached to the release'.format(ci)])

    def _get_rel_ci_names(self, application, version):
        uri = '{0}/{1}/{2}/{3}?list=&listFolders=1'.format(
            self._BASE_ARTIFACTORY_STORAGE_API_URI,
            self._RELEASE_REPO,
            application,
            version)
        release_cis = self.__get_folders(uri)
        release_ci_names = []

        for release_ci in release_cis:
            #release_ci_name = release_ci[:release_ci.rfind('_')]
            release_ci_name = re.split("_[AN]-", release_ci, 0)[0]
            release_ci_names.append(release_ci_name)

        return release_ci_names

    def _get_rel_versions(self, application):
        uri = '{0}/{1}/{2}?list=&listFolders=1'.format(
            self._BASE_ARTIFACTORY_STORAGE_API_URI,
            self._RELEASE_REPO,
            application)
        return self.__get_folders(uri)

    def _check_rel_version_exists(self, application, version):
        rel_versions = self._get_rel_versions(application)
        if version not in rel_versions:
            messages = [
                'Version \'{0}\' not available.  Options are:'.format(version)]
            messages += ['  ' + ', '.join(rel_versions)]
            error(messages)

    def _check_build_version_exists(self, application, version):
        build_versions = self._get_ci_versions(application)
        if version not in rel_versions:
            messages = [
                'Version \'{0}\' not available.  Options are:'.format(version)]
            messages += ['  ' + ', '.join(rel_versions)]
            error(messages)

    def _get_build_ci_properties(self, application, ci, version):
        uri = '{0}/{1}/{2}/{3}/{4}?properties'.format(
            self._BASE_ARTIFACTORY_STORAGE_API_URI,
            self._BUILD_REPO,
            application,
            ci,
            version)
        result = self._getIgnore404(uri)
        if result:
            return result.json()['properties']
        return result

    def _get_release_status(self, application, version):
        uri = '{0}/{1}/{2}/{3}?properties'.format(
            self._BASE_ARTIFACTORY_STORAGE_API_URI,
            self._RELEASE_REPO,
            application,
            version)
        return self._get(uri).json()['properties']['status']

    def _get_release_freeze(self, application, version):
        uri = '{0}/{1}/{2}/{3}?properties'.format(
            self._BASE_ARTIFACTORY_STORAGE_API_URI,
            self._RELEASE_REPO,
            application,
            version)
        return self._get(uri).json()['properties']['freeze']

    def _check_if_release_locked(self, application, version):
        if self._get_release_status(application, version) != ['unlocked']:
            error(['Release is locked.  Cannot modify.'])

    def _check_if_release_freezed(self, application, version):
        if self._get_release_freeze(application, version) != ['off']:
            warning(['Release is freezed.  Cannot modify.'])

    def _check_if_release_unlocked(self, application, version):
        if self._get_release_status(application, version) != ['locked']:
            error(['Release is unlocked.  Cannot download files.'])

    def _lock_release(self, application, version):
        uri = '{0}/{1}/{2}/{3}?properties=status=locked'.format(
            self._BASE_ARTIFACTORY_STORAGE_API_URI,
            self._RELEASE_REPO,
            application,
            version)
        self._put(uri)

    def _unlock_release(self, application, version):
        uri = '{0}/{1}/{2}/{3}?properties=status=unlocked'.format(
            self._BASE_ARTIFACTORY_STORAGE_API_URI,
            self._RELEASE_REPO,
            application,
            version)
        self._put(uri)

    def _freeze_release(self, application, version):
        uri = '{0}/{1}/{2}/{3}?properties=freeze=on'.format(
            self._BASE_ARTIFACTORY_STORAGE_API_URI,
            self._RELEASE_REPO,
            application,
            version)
        self._put(uri)

    def _find_longest(self, items):
        longest = 0
        for item in items:
            if len(item) > longest:
                longest = len(item)
        return longest

    def validate(self):
        applications = self._get_applications()
        if self.application not in applications:
            messages = [
                'Application \'{0}\' not available.  Options are:'.format(self.application)]
            messages += ['  ' + ' '.join(applications)]
            error(messages)


def error(messages):
    print
    for message in messages:
        print 'ERROR: {0}:'.format(message)
    sys.exit(1)


def warning(messages):
    print
    for message in messages:
        print 'WARNING: {0}:'.format(message)
    sys.exit(0)


