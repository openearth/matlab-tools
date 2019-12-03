#!/usr/bin/python3

"""
$Id: subversion.py 14676 2018-10-09 08:05:50Z heijer $
$Date: 2018-10-09 01:05:50 -0700 (Tue, 09 Oct 2018) $
$Author: heijer $
$Revision: 14676 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/datarepositoryreporter/subversion.py $

@authors:
    - Kees den Heijer (Deltares)
    - Jochem Boersma (Witteveen+Bos)
"""

import os
import xml.etree.ElementTree as ET
import subprocess
import datetime
import logging
import re


class Subversion:
    """communicator/wrapper for interactions with SVN repository"""
    
    # Fixed keywords for calling / using svn from console
    SUB_COMMANDS = ('info', 'update', 'list', 'log', 'status', 'add')
    DEPTHS = ('infinity', 'immediates', 'files', 'empty')
    KINDS = ('dir', 'file')
    fmt = '%Y-%m-%dT%H:%M:%S.%fZ'
    binary = 'svn' # Installation of svn with command line tools are necessary
    
    # Attributes
    target = None          # string, reference to file path (local) or url (remote))
    is_working_copy = None # bool
    wc_root = None         # highest folder of the working copy (local)
    wc_root_url = None     # 
    repos_root = None      # highest folder (checkout reference) of the repository, remote
    repos_root_url = None  # 
    
    url = None
    revision = None
    
    def __init__(self, target='.', *args, **kwargs):
        self.is_working_copy = self._is_working_copy(target)

    def _is_working_copy(self, target):
        path_exists = os.path.exists(target)
        status, info = self.svn_info(target)
        is_working_copy = False
        if status:
            if isinstance(info, dict):
                if 'wcroot-abspath' in info:
                    self.wc_root = info['wcroot-abspath']
                    is_working_copy = True
                    _, wc_root_info = self.svn_info(self.wc_root)
                    self.wc_root_url = wc_root_info['url']
                self.url = info['url']
                self.revision = info['revision']
                self.repos_root_url = info['repository-root']
            else:
                logging.info('%i entries found, no working copy could be identified' % len(info))

        return path_exists and is_working_copy

    def _command(self, target='.', sub_command='info', xml=True, **kwargs):
        if target is None:
            raise Exception('target "None" is not allowed')
        if sub_command not in self.SUB_COMMANDS:
            logging.error('sub_command "%s" is not recognised' % sub_command)
            return False, None
        cmd_list = [self.binary, sub_command]
        
        if xml:
            cmd_list.append('--xml')
        
        cmd_list.append(target)
        
        if 'optional' in kwargs:
            cmd_list = cmd_list + list(kwargs['optional'])
        
        # Add double quotes towards each element of the command list, to handle spaces.
        cmd = " ".join(['"{}"'.format(mycmd) for mycmd in cmd_list])
        sp = subprocess.run(cmd, shell=True, check=False, stdout=subprocess.PIPE, encoding='utf-8')
        try:
            status = sp.returncode == 0
            output = sp.stdout.strip()
        except:
            status = False
            output = None
        return status, output

    def svn_info(self, target='.', **kwargs):
        status, response = self._command(target=target, sub_command='info', xml=True, **kwargs)
        if status:
            # svn info call was successful
            tree = ET.fromstring(response)
            # return dictionary with svn information
            # find all entries in xml tree
            entries = tree.findall('.//entry')
            info = []
            for entry in entries:
                # populate info list
                info_dict = self._parse_svn_info(entry)
                info.append(info_dict)
            if isinstance(target, str):
                info = info[0]
            return status, info
        else: # status == False
            #svn info call was NOT succesfull
            return status, response

    def _strptime(self, date_string):
        return datetime.datetime.strptime(date_string, self.fmt)

    def _parse_svn_info(self, entry):
        """
        Parse xml entry to dictionary
        :param entry:
        :return:
        """
        info_dict = {'kind': entry.attrib['kind'],
                     'url': entry.find('.//url').text.replace('%20', ' '),
                     'relative-url': entry.find('.//relative-url').text.replace('%20', ' '),
                     'repository-root': entry.find('.//repository/root').text,
                     'revision': int(entry.find('.//commit').attrib['revision']),
                     'author': entry.find('.//commit/author').text,
                     'date': self._strptime(entry.find('.//commit/date').text)}
        wc_info = entry.find('.//wc-info')
        if wc_info:
            info_dict['wcroot-abspath'] = wc_info.find('.//wcroot-abspath').text
        return info_dict

    def svn_update(self, target=None, depth=None):
        """
        Perform svn update on local working copy
        :param target:
        :param depth:
        :return:
        """
        if not self.is_working_copy:
            logging.error('svn update is only possible when working copy exists')
            return False, None
        kwargs = {}
        if target is None:
            target = self.wc_root
        if depth in self.DEPTHS:
            kwargs['optional'] = ['--set-depth', depth]
        elif depth is not None:
            logging.error('depth argument "%s" not recognised' % depth)
            raise
        
        regex_url = re.compile(r'^https?://')  # http:// or https://
        if regex_url.search(target): # working on a remote
            if target.startswith(self.wc_root_url):
                # distinguish working copy root url from relative url
                pattern = r"(?P<wc_root_url>{wc_root_url})/(?P<relative_url>.*)".format(wc_root_url=self.wc_root_url)
                match = re.match(pattern, target)
                if match:
                    logging.debug('match')
                    target_split = match.groupdict()
                    relative_url = target_split['relative_url']
                    # define final target
                    target = os.path.join(self.wc_root, relative_url)
                    # strip last part from relative url
                    relative_url = os.path.dirname(relative_url)
                    dir_splits = relative_url.split(os.path.sep)
                    # loop over intermediate paths
                    for i, d in enumerate(dir_splits):
                        p = os.path.join(self.wc_root, os.path.sep.join(dir_splits[:(i + 1)]))
                        logging.debug('iterate over paths {}'.format(p))
                        # If particular sub folder does not exist, build this tree empty
                        if not os.path.exists(p):
                            logging.debug("didn't exists: generating {}".format(p))
                            self.svn_update(target=p, depth='empty')
                else: # No relative url (possibly trunk, continue)
                    pass
            else:
                logging.error('target "{target}" cannot be matched with working copy root "{wc_root}"'
                              .format(target=target, wc_root=self.wc_root))
                return False, None
        
        # At last (remote or not): adding the deepest (original) target. All 
        # intermediate folders are generated, or exist by definition
        logging.debug('svn update final target')
        status, response = self._command(target=target, sub_command='update', xml=False, **kwargs)
        return status, response

    def svn_list(self, target='.', kind=None, recursive=False, output=None, **kwargs):
        if recursive:
            # include recursive flag to optional arguments
            if 'optional' in kwargs:
                kwargs['optional'].append('--recursive')
            else:
                kwargs['optional'] = ['--recursive',]
        status, response = self._command(target=target, sub_command='list', xml=True, **kwargs)
        if status:
            # svn info call was successful
            tree = ET.fromstring(response)
            kind_filter = ''
            if kind:
                if kind in self.KINDS:
                    kind_filter = '[@kind="{}"]'.format(kind)
                else:
                    logging.debug('kind "%s" not recognised' % kind)
                    # fall back to all entries
            entries = tree.findall('.//entry{}'.format(kind_filter))
            # return list of dictionaries
            return status, [self._parse_svn_list(entry, output=output) for entry in entries]
        else:
            # fall back to raw response
            return status, response

    def _parse_svn_list(self, entry, output=None):
        """
        parse xml entry to dictionary
        :param entry:
        :return:
        """
        if output is None:
            # return all available fields as dictionary
            lst = {'kind': entry.attrib['kind'],
                   'name': entry.find('.//name').text,
                   'revision': int(entry.find('.//commit').attrib['revision']),
                   'author': entry.find('.//author').text,
                   'date': self._strptime(entry.find('.//commit/date').text)}
            size = entry.find('.//size')
            if size is not None:
                lst['size'] = int(size.text)
        elif output == 'name':
            # return only name as string
            lst = entry.find('.//name').text
        else:
            logging.error('output {} not recognized'.format(output))
            lst = None

        return lst


    def svn_status(self, target='.'):
        status, response = self._command(target=target, sub_command='status', xml=True)
        if status:
            # svn info call was successful
            tree = ET.fromstring(response)
            entries = tree.findall('.//entry')
            # return dictionary
            result = {}
            for d in [self._parse_svn_status(entry) for entry in entries]:
                result.update(d)
            return status, result
        else:
            # fall back to raw response
            return status, response

    def _parse_svn_status(self, entry):
        st = {entry.attrib['path']: entry.find('.//wc-status').attrib['item']}
        return st

    def svn_add(self, target='.'):
        status, response = self._command(target=target, sub_command='add', xml=False)
        return status, response

    def svn_version(self, target='.'):
        cmd = "svnversion -n {}".format(target)
        sp = subprocess.run(cmd, shell=True, check=False, stdout=subprocess.PIPE, encoding='utf-8')
        try:
            status = sp.returncode == 0
            output = sp.stdout
            warning_dict = {":": "mixed revision working copy", "S": "switched working copy", "M": "modified working copy"}
            warning_list = []
            for w in warning_dict.keys():
                if w in output:
                    warning_list.append(warning_dict[w])
            warning_msg = ", ".join(warning_list)
        except:
            status = False
            output = None
        return status, output, warning_msg

    def svn_log(self, target='.', search=None):
        """
        Retrieve subversion log information
        :param target:
        :param search:
        :param args:
        :return:
        """
        kwargs = {}
        if search:
            kwargs = {'optional': ['--search', search]}
        status, response = self._command(target=target, sub_command='log', xml=True, **kwargs)
        if status:
            # svn log call was successful
            tree = ET.fromstring(response)
            entries = tree.findall('.//logentry')
            return status, [self._parse_svn_log(entry) for entry in entries]
        else:
            # fall back to raw response
            return status, response

    def _parse_svn_log(self, entry):
        """
        parse xml entry to dictionary
        :param entry:
        :return:
        """
        log_dict = {'revision': int(entry.attrib['revision']),
                    'author': entry.find('.//author').text,
                    'date': self._strptime(entry.find('.//date').text),
                    'msg': entry.find('.//msg').text}
        return log_dict

    def __repr__(self):
        return '%s <%s>' % (self.wc_root, self.url)




#%% For testing purposes
if __name__ == '__main__':
    
    logging.basicConfig(level=logging.DEBUG,
                    format='[%(levelname)s] %(asctime)s\n  %(message)s',
                    )

    svn = Subversion(os.path.abspath(os.path.dirname(__file__)))
    # print(svn)
    # svn = Subversion(svn.wc_root)
    svn.svn_update(svn.url)
