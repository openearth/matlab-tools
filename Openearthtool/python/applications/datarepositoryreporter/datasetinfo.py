#!/usr/bin/python3

"""
$Id: datasetinfo.py 16027 2019-11-22 15:58:07Z c.denheijer $
$Date: 2019-11-22 07:58:07 -0800 (Fri, 22 Nov 2019) $
$Author: c.denheijer $
$Revision: 16027 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/datarepositoryreporter/datasetinfo.py $

@authors:
    - Kees den Heijer (Deltares)
    - Jochem Boersma (Witteveen+Bos)
"""

# External modules
import os
import re
import collections
import logging
from configparser import ConfigParser
import posixpath


# Own modules
from subversion import Subversion
import utilsRepo as utl


class DataSetInfo:
    """
    A class which contains all (repository) information of particular DataSet 
    (most of the time a subfolder)
        
    Class contains methods writeToCFG, a fromCFG and a reportToTEX (not yet)
    """
    
    # All attributes initialized
    url = None
    name = None
    
    main_url = None  # in case of a data subset, this is the url of the main dataset (otherwise equal to url)
    main_name = None  # in case of a data subset, this is the name of the main dataset (otherwise equal to name)
    
    domain_name = None
    domain_url = None
    
    root_url = None
    
    total_size = None
    raw_size = 0.
    raw_exts = None
    raw_url = None
    scripts_size = 0.
    script_exts = None
    scripts_url = None
    
    author = None
    date = None
    revision = None
    logs = None
    fmt = Subversion().fmt # Default formatting of Subversion class

    cfg = ConfigParser(dict_type=collections.OrderedDict)
    cfg_file = None
    cfg_url = None
    
    
    #%% INITIALIZING ATTRIBUTES ===============================================
    def __init__(self, path, report_root_url=None):
        logging.debug('starting __init__ path="{}", report_root_url="{}"'.format(path, report_root_url))
        
        # Check whether the path is a .cfg-file or the particular data folder
        #path = os.path.abspath(path)
        # Bovenstaande gaat enorm fout: in plaats van dat het pad wordt gechecked 
        # op goede file-seps, wordt de working dir ervoor gezet.
        path = utl.convertPath(path)

        if os.path.isdir(path):
            # set cfg_file and cfg_url attributes
            self.cfg_file = os.path.join(path, utl.CFG_FILENAME)
            # check if cfg_file exists on remote repository
            _, status = Subversion().svn_status(self.cfg_file)
            if self.cfg_file in status and status[self.cfg_file] in ('unversioned', 'added'):
                # file not yet in repository, so url not available
                self.cfg_url = None
            else:
                # get remote url
                self.cfg_url = self.path2url(self.cfg_file)

            url = self.path2url(path)
            root_url = self.url2root(url)
            if report_root_url is not None:
                if report_root_url.startswith(root_url):
                    # full url provided
                    root_url = report_root_url
                else:
                    # relative url with respect to repository root expected
                    root_url = posixpath.join(root_url, report_root_url.lstrip('/'))

            self.set_url(url)  # of dataset
            self.set_root_url(root_url)  # TODO: check whether this is really needed
            self.set_name()
            self.set_subset()
            self.set_main()
            self.set_domain()
            self.set_details()
            self.set_raw_url()
            self.set_scripts_url()
        elif path.endswith(utl.CFG_FILENAME):
            # set cfg_file and cfg_url attributes
            self.cfg_file = os.path.abspath(path)
            # check if cfg_file exists on remote repository
            _, status = Subversion().svn_status(self.cfg_file)
            if self.cfg_file in status and status[self.cfg_file] in ('unversioned', 'added'):
                # file not yet in repository, so url not available
                self.cfg_url = None
            else:
                # get remote url
                self.cfg_url = self.path2url(self.cfg_file)
            logging.info('reading information from {} ({})'.format(self.cfg_file, self.cfg_url))
            self.from_cfg(self.cfg_file)
        else:
            logging.error('input argument path={} is NOT VALID'.format(path))

    def from_cfg(self, cfg_file):
        """construct an instance, based on a cfg-file"""
        self.cfg_file = cfg_file
        self.read_cfg()
        url = self.cfg['general']['dataset_url']
        self.set_url(url)
        # self.set_root_url(root_url)
        self.name = self.cfg['general']['dataset_name']
        self.set_subset()
        self.set_main()
        # set_domain
        self.domain_name = self.cfg['general']['domain_name']
        self.domain_url = self.cfg['general']['domain_url']
        report_root_url = self.get_report_root_url()
        self.set_root_url(report_root_url)
        # set_details
        if self.cfg['general']['raw'] == 'True':
            self.raw_size = utl.hr2size(self.cfg['raw']['size'])
            self.raw_exts = self.cfg['raw']['extensions'].split(', ')
        # set_raw_url
        if self.cfg['general']['raw'] == 'True':
            self.raw_url = self.cfg['raw']['url']
        else:
            self.raw_url = None
        # set_scripts_url
        if self.cfg['general']['scripts'] == 'True':
            self.scripts_url = self.cfg['scripts']['url']

    def path2url(self, path):
        svn = Subversion(target=path)
        return svn.url

    def url2root(self, url):
        svn = Subversion(target=url)
        return svn.repos_root_url

    def read_cfg(self):
        """
        read .cfg file as ConfigParser object
        :return:
        """
        # clear possibly remaining cfg data from the object before reading
        self.cfg.clear()
        if os.path.exists(self.cfg_file):
            self.cfg.read(self.cfg_file)

    def cfg_is_complete(self):
        """
        check if cfg object contains required sections and fields
        :param cfg:
        :return:
        """
        required_fields = {'general': ['authors', 'dataset_name', 'dataset_url', 'date', 'domain_name', 'domain_url',
                                       'raw', 'readme', 'revision', 'scripts', 'size', 'contact', 'owner']}
        result = False
        for section in required_fields.keys():
            logging.debug('checking section {}'.format(section))
            if self.cfg.has_section(section):
                for field in required_fields[section]:
                    logging.debug('checking field {}'.format(field))
                    if self.cfg.has_option(section, field):
                        result = True
                        print(self.cfg[section][field])
                    else:
                        result = False
                        logging.debug('field {} not found'.format(field))
                        break
            else:
                result = False
                logging.debug('section {} not found'.format(section))
                break
        return result
    
    def update_cfg(self):
        """
        update ConfigParser object with actual dataset version information
        :return:
        """
        # Setting all
        if not self.cfg.has_section('general'):
            self.cfg.add_section('general')
        if not self.is_subset:
            self.cfg.set('general', 'dataset_name', self.name)
            self.cfg.set('general', 'dataset_url', self.url)
            self.cfg.set('general', 'subset', 'False')
        else:
            self.cfg.set('general', 'dataset_name', ' - '.join([self.main_name, self.name]))
            self.cfg.set('general', 'dataset_url', self.url)
            self.cfg.set('general', 'subset', 'True')

        self.cfg.set('general', 'domain_name', self.domain_name)
        self.cfg.set('general', 'domain_url', self.domain_url)
        self.cfg.set('general', 'date', self.date.strftime(self.fmt))
        self.cfg.set('general', 'revision', str(self.revision))
        self.cfg.set('general', 'readme', str(self.has_readme()))
        self.cfg.set('general', 'raw', str(self.has_raw()))
        self.cfg.set('general', 'scripts', str(self.has_scripts()))
        self.cfg.set('general', 'authors', ", ".join(self.authors(unique=True, order_by='name')))
        self.cfg.set('general', 'size', utl.size2hr(self.total_size))

        # Add empty manual field if not available
        manual_fields = ('abstract', 'contact', 'date_begin', 'date_end',
                         'lat_max', 'lat_min', 'lon_max', 'lon_min', 'owner', 'tags', 'title')
        for m_field in manual_fields:
            if m_field not in self.cfg['general']:
                self.cfg.set('general', m_field, '')

        if self.has_raw():
            if not self.cfg.has_section('raw'):
                self.cfg.add_section('raw')
            print(self.url, self.main_url, self.raw_url)
            _, raw_logs = Subversion().svn_log(target=self.raw_url)
            authors = [item['author'] for item in raw_logs]
            last_revision = raw_logs[0]
            print(last_revision)
            self.cfg.set('raw', 'date', last_revision['date'].strftime(self.fmt))
            self.cfg.set('raw', 'revision', str(last_revision['revision']))
            self.cfg.set('raw', 'authors', ", ".join(sorted(list(set(authors)))))
            self.cfg.set('raw', 'size', utl.size2hr(self.raw_size))
            self.cfg.set('raw', 'extensions', ", ".join(sorted(list(set(self.raw_exts)))))
            self.cfg.set('raw', 'url', self.raw_url)
        else:
            if self.cfg.has_section('raw'):
                # if raw data is not available, the section should not be there either
                self.cfg.remove_section('raw')

        if self.has_scripts():
            if not self.cfg.has_section('scripts'):
                self.cfg.add_section('scripts')
            _, script_logs = Subversion().svn_log(target=self.raw_url)
            authors = [item['author'] for item in script_logs]
            last_revision = script_logs[0]
            self.cfg.set('scripts', 'date', last_revision['date'].strftime(self.fmt))
            self.cfg.set('scripts', 'revision', str(last_revision['revision']))
            self.cfg.set('scripts', 'authors', ", ".join(sorted(list(set(authors)))))
            self.cfg.set('scripts', 'extensions', ", ".join(sorted(list(set(self.script_exts)))))
            self.cfg.set('scripts', 'url', self.scripts_url)
        else:
            if self.cfg.has_section('scripts'):
                # if scripts are not available, the section should not be there either
                self.cfg.remove_section('scripts')

    def _sort_cfg(self):
        # Order the content of each section alphabetically
        for section in self.cfg._sections:
            self.cfg._sections[section] = collections.OrderedDict(
                sorted(self.cfg._sections[section].items(), key=lambda t: t[0]))
        
    def write_cfg(self):
        """
        write ConfigParser object to .cfg file
        :return:
        """
        self._sort_cfg()
        with open(self.cfg_file, 'w') as fobj:
            self.cfg.write(fobj)

    def set_url(self, url):
        """Enforce an ending '/'"""
        if not url.endswith('/'):
            url += '/'
        self.url = url

    def set_root_url(self, root_url):
        """Enforce an ending '/'"""
        if not root_url.endswith('/'):
            root_url += '/'
        self.root_url = root_url

    def get_report_root_url(self):
        """
        derive report_root_url based on domain_url and domain_name
        :return: report_root_url
        """
        return self.domain_url.split(self.domain_name)[0]

    def set_name(self):
        """Name is defined as the last dir of particular url"""
        # REMARK that there is always a trailing '/' in an url
        self.name = self.url.split('/')[-2]

    def set_main(self):
        """Setting both the name as the url of the main set"""
        if self.is_subset:
            # Searching for the parent folder of the folder 'raw'
            pattern = '^.*?(?=/raw/)'
            # By definition, the group is not empty, since it is a subset.
            self.main_url = '{}/'.format(re.search(pattern, self.url).group())
            
            # REMARK that there is always a trailing '/' in an url
            self.main_name = self.main_url.split('/')[-2]
        else:
            # Name and main are the same
            self.main_url = self.url
            self.main_name = self.name

    def set_domain(self):
        """Setting both the name as the url of the particular domain"""
        pattern = '^.*?(?=/%s)' % self.main_name
        self.domain_url = re.search(pattern, self.main_url).group()
        print(self.domain_url)
        print(self.root_url)
        if len(self.domain_url) > len(self.root_url):
            pattern = '(?<=%s).*?$' % self.root_url
            #print(pattern)
            self.domain_name = re.search(pattern, self.domain_url).group()
            #print(self.domain_name)
        else:
            self.domain_name = '-'

    def set_raw_url(self):
        _, lst = Subversion().svn_list(self.url, kind='dir', output='name')
        if self.is_subset:
            # If we have a subset, then 
            self.raw_url = self.url
        elif 'raw' in lst:
            self.raw_url = '%sraw/' % self.url
        else:
            # no raw directory found
            pass
    
    def set_subset(self):
        self.is_subset = ('/raw/' in self.url)  # Bool

    # Methods =======
    def has_raw(self):
        return (self.raw_size > 0)  # Bool

    def has_scripts(self):
        return (self.scripts_size > 0) # Bool

    def has_readme(self):
        _, lst = Subversion().svn_list(self.url, kind='file', output='name')
        return 'readme.txt' in lst # Bool

    def set_scripts_url(self):
        _, lst = Subversion().svn_list(self.main_url, kind='dir', output='name')
        if 'scripts' in lst:
            self.scripts_url = '%sscripts/' % self.main_url
        else:
            # no scripts directory found
            logging.debug('no scripts directory found')
            pass

    def set_details(self):
        """"""
        raw_suffix = 'raw/'
        scripts_suffix = 'scripts/'
        if self.is_subset:
            raw_suffix = self.url.replace(self.main_url, '')
        _, files = Subversion().svn_list(self.main_url, kind='file', recursive=True)
        raw_files = [item for item in files if item['name'].startswith(raw_suffix)]
        self.raw_size = 0.
        self.raw_exts = []
        for f in raw_files:
            self.raw_size += f['size']
            self.raw_exts.append(os.path.splitext(f['name'])[-1])
        scripts = [item for item in files if item['name'].startswith(scripts_suffix)]
        self.scripts_size = 0.
        self.script_exts = []
        for f in scripts:
            self.scripts_size += f['size']
            self.script_exts.append(os.path.splitext(f['name'])[-1])
        self.total_size = self.raw_size + self.scripts_size
        _, lst = Subversion().svn_list(target=self.url, output='name')
        lst = [item for item in lst if not item == utl.CFG_FILENAME]
        logging.debug('lst: %s' % lst)
        if lst == []:
            _, info = Subversion().svn_info(target=self.url)
            self.author = info['author']
            self.date = info['date']
            self.revision = info['revision']
        else:
            maxrev = 0
            for item in lst:
                logging.debug(self.url)
                logging.debug(item)
                _, info = Subversion().svn_info('%s%s' % (self.url, item))
                logging.debug(info)
                if info['revision'] > maxrev:
                    self.author = info['author']
                    self.date = info['date']
                    self.revision = info['revision']
                    maxrev = info['revision']
        _, self.logs = Subversion().svn_log(self.url)

    def authors(self, unique=False, order_by=None):
        """returns a tuple with all (optionally unique) authors"""
        authors = [entry['author'] for entry in self.logs]

        def _order(authors_list, order_by=None):
            if order_by is None:
                return authors_list
            elif order_by == 'name':
                return sorted(authors_list)

        if unique:
            authors = tuple(set(authors))

        return _order(authors, order_by=order_by)

    def is_modified(self):
        """
        check if cfg file needs update (dataset revision is newer than cfg revision or cfg is absent)
        :return: Boolean
        """
        # Initialize: 
        is_modified = False

        print('os.path.exists({})={}, cfg_url={}'.format(self.cfg_file, str(os.path.exists(self.cfg_file)),
                                                                 str(self.cfg_url)))
        if not os.path.exists(self.cfg_file) or self.cfg_url is None:
            is_modified = True
        else:
            svn_cfg = Subversion(target=self.cfg_file)
            _, lst = svn_cfg.svn_list(target=os.path.dirname(self.cfg_file), output='name')
            if utl.CFG_FILENAME in lst:
                # only perform svn update if cfg file is available in the remote repository
                svn_cfg.svn_update(target=self.cfg_url, depth='empty')  # or should we assume that this is already up to date?
            svn_dataset = Subversion(target=self.url)
            # TODO: filter out possible commits to .cfg files of subsets (somewhere on a lower level in the tree)
            print(svn_dataset.revision, svn_cfg.revision)
            if svn_cfg.revision is None or svn_dataset.revision > svn_cfg.revision:
                is_modified = True
            else:
                self.read_cfg()
                logging.debug('cfg read {}'.format(self.cfg_file))
                if not self.cfg_is_complete():
                    logging.debug('sections or fields missing in cfg file')
                    is_modified = True
        return is_modified  # bool

    def as_tablerow(self, cfg=None, script_extensions=('.py', '.m')):
        """Return the information of the data as a row for the report table"""
        
        # If no cfg found, build it, based on the current directory
        if cfg is None:
            self.update_cfg()
            cfg = self.cfg

        # Determine all information parts which should be set into the TeX-table
        url = cfg['general']['dataset_url']
        name = cfg['general']['dataset_name']
        contact = cfg['general']['contact']
        domain_url = cfg['general']['domain_url']
        domain_name = cfg['general']['domain_name']
        date = Subversion()._strptime(cfg['general']['date']).strftime('%Y-%m-%d')

        readme = utl.href(url + 'readme.txt', r'\checkmark') if (cfg['general']['readme'] == 'True') else ''
        raw_size = cfg['raw']['size'] if (cfg['general']['raw'] == 'True') else '0'
        scripts = ''
        if (cfg['general']['scripts'] == 'True'):
            scripts = ', '.join([ext for ext in cfg['scripts']['extensions'].split(', ') if ext in script_extensions])
        thredds = ''
        if cfg.has_section('netCDF'):
            thredds = utl.href(cfg['netCDF']['url'], r'\checkmark')

        logging.debug('{} written to row'.format(self.name))

        # Construct the row (with TeX-column separators) and return as string
        return '{dataset} & {domain} & {date} & {contact} & {volume} & {readme} & {scripts} & {thredds} \\\\'.format(
            dataset=utl.href(url, name.replace('_', '\_')),
            domain=utl.href(domain_url, domain_name.replace('_', '\_')),
            date=date,
            contact=contact,
            volume=raw_size,
            readme=readme,
            scripts=scripts,
            thredds=thredds)

    def __repr__(self):
        return '%s %s %s %s %s' % (self.name, self.domain_name, self.url, utl.size2hr(self.raw_size), self.date)


#%% ===========================================================================
def main():
    """for testing purposes"""
        
    logging.basicConfig(level=logging.DEBUG,
                    format='[%(levelname)s] %(asctime)s\n  %(message)s',
                    )
    
    cfg_file = '../../../ecology/ctd/dataset_details.cfg'
    DSI = DataSetInfo(os.path.dirname(cfg_file), report_root_url='trunk/')
    DSI.read_cfg()
    if DSI.is_modified():
        logging.debug('Dataset is modified: update {}'.format(utl.CFG_FILENAME))
        DSI.update_cfg()
        DSI.write_cfg()
    else:
        logging.debug('Dataset is not changed: {} up-to-date'.format(utl.CFG_FILENAME))

    logging.info(DSI.as_tablerow())


if __name__ == '__main__':
   main() # To test particular class
