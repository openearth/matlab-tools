# -*- coding: utf-8 -*-
"""
Created on Fri Feb 16 13:30:34 2018
SCRIPT which builds a report, based on the changes in the repository

The idea of this script is to:
    1) update all repository-conf files ('dataset_details.cfg')
    2) check whether data has been changed (and build new .cfg if necessary)
    3) collect all .cfg-files to build a report of it

$Id: reportRepository.py 15868 2019-10-25 07:15:35Z c.denheijer $
$Date: 2019-10-25 00:15:35 -0700 (Fri, 25 Oct 2019) $
$Author: c.denheijer $
$Revision: 15868 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/datarepositoryreporter/reportRepository.py $

@authors: 
    - Jochem Boersma (Witteveen+Bos)
    - Kees den Heijer (Deltares)
"""


# External modules
import os
import subprocess
import logging
import argparse
import posixpath

# Own modules / classes
from subversion import Subversion
from datasetinfo import DataSetInfo
import utilsRepo as utl

""" REMARK / TODO:
    For now: Dont use spaces in working copy location
"""


class ReportRepository:
    destfilename = None
    flagCheck = True
    flagCollect = False
    flagSkipEmpty = False
    wc_root = None
    raw_pattern = '/raw'
    datasets = []
    lst = None
    svn = None

    excludes = ('datamanagement', 'test')

    def __init__(self):
        self._check_svn_installed()

    @staticmethod
    def _check_svn_installed():
        sp = subprocess.run('svn --version --quiet',
                            shell=True, check=False, stdout=subprocess.PIPE, encoding='utf-8')
        if sp.returncode != 0:
            raise SystemError('Not able to run SVN in command line. '
                              'Please install SVN correctly (including command line client tools)')

    def _check_spaces_in_path(self, path=None):
        if path is None:
            path = self.wc_root

        if path.count(' ') > 0:
            raise NotImplementedError(
                'spaces in filepath, check-out of repository should be made in directory without spaces')

    def set_wc_root(self, path=None):
        if path is None:
            wc_current_location = os.path.abspath(os.path.dirname(__file__))
        else:
            wc_current_location = path
        self._check_spaces_in_path(wc_current_location)
        svn = Subversion(target=wc_current_location)
        self.wc_root = svn.wc_root

    def crawl_repository(self, subtree=None):
        """
        perform recursive svn list
        :return:
        """
        # Generating svn object with root of the working copy as
        # Repository should be checked out sparse, since the report should be made for the whole repo
        self.svn = Subversion(target=self.wc_root)
        if subtree:
            url = posixpath.join(self.svn.url, subtree)
        else:
            url = self.svn.url
        _, self.lst = self.svn.svn_list(url, recursive=True)

    def check_data_updates(self):
        """
        crawl repository, detect data updates and create/update dataset_details.cfg files
        :return:
        """
        self.crawl_repository()
        for item in self.lst:
            # A list of all files in current revision

            # All raw datafolders without config, should be filed
            # add cfg if datasets matches pattern
            # TODO pattern should be added with either argparse or a .conf with multiple input params
            pattern = self.raw_pattern  # TO CHECK: the file-separator should be placed IN FRONT of raw.

            # construct url
            item["url"] = posixpath.join(self.svn.url, item['name'])

            # Listing all config-files, existing datasets (identified by existence of cfg))
            if item['url'].endswith(pattern) or item['name'].endswith(utl.CFG_FILENAME):
                skip = False
                for excl in self.excludes:
                    if excl in item['name']:
                        skip = True
                if skip:
                    continue

                tail = os.path.dirname(item['name'][:-1])

                dataset_url = os.path.join(self.svn.url, tail)
                dataset_url = utl.convertPath(dataset_url)  # for windows support
                dataset_path = os.path.join(self.svn.wc_root, tail)

                cfg_url = os.path.join(dataset_url, utl.CFG_FILENAME)
                cfg_url = utl.convertPath(cfg_url)  # for windows support
                cfg_path = os.path.join(dataset_path, utl.CFG_FILENAME)

                # If particular dataset is already summed, then skip this one
                if cfg_path in self.datasets:
                    continue

                _, svn_lst = self.svn.svn_list(target=dataset_url, output='name')
                if utl.CFG_FILENAME in svn_lst:
                    # only perform svn update if cfg file is available in the remote repository
                    self.svn.svn_update(target=cfg_url, depth='empty')
                else:
                    # otherwise make sure the directory is locally available
                    self.svn.svn_update(target=dataset_url, depth='empty')

                logging.info('adding {} to repo'.format(cfg_path))
                self.datasets.append(cfg_path)

                # Some info
                logging.debug('{} added to datasets'.format(dataset_url))

                # Check whether dataset is modified
                DSI = DataSetInfo(dataset_path, report_root_url=self.svn.wc_root_url)
                DSI.read_cfg()
                if DSI.is_modified():
                    logging.debug('Dataset is modified: update {}'.format(utl.CFG_FILENAME))
                    DSI.update_cfg()
                    DSI.write_cfg()
                    # check status and perform svn add if necessary
                    _, status = self.svn.svn_status(cfg_path)
                    if cfg_path in status and status[cfg_path] == 'unversioned':
                        self.svn.svn_add(cfg_path)
                else:
                    logging.debug('Dataset is NOT modified')

        logging.info('All {}-files are updated'.format(utl.CFG_FILENAME))

    def collect_datasets(self):
        """
        create .tex table with information about all available datasets
        :return:
        """
        logging.info('Building TEX-file [{}]'.format(os.path.basename(self.destfilename)))
        utl.createTEXoverview(self.datasets, self.destfilename)

    def run(self):
        if self.flagCheck:
            self.check_data_updates()

        if self.flagCollect:
            self.collect_datasets()


def main():
    # initiate log
    logfile = "{}.log".format(os.path.splitext(__file__)[0])
    utl.startLogging(logfile, header='LOGGING REPO REPORT')

    parser = argparse.ArgumentParser(description='Raw data repository reporter')
    parser.add_argument("-p", "--path", default=os.path.abspath(os.path.dirname(__file__)), help="path of svn checkout")
    parser.add_argument("-t", "--tex-file", default='table.tex', help="path to table.tex file")
    parser.add_argument("-o", "--overview", action="store_true", help="flag to enable overview table of datasets (.tex)")
    parser.add_argument("-s", "--skip-empty", action="store_true", help="flag to skip empty (raw) dataset in table of datasets")
    args = parser.parse_args()

    # initiate ReportRepository class and parse input
    rr = ReportRepository()
    rr.set_wc_root(args.path)
    rr.flagSkipEmpty = args.skip_empty
    rr.destfilename = args.tex_file
    rr.flagCollect = args.overview
    # run ReportRepository
    rr.run()

    # close log
    logging.shutdown()


if __name__ == '__main__':
    main()
