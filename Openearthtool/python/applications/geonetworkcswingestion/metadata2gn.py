import glob
import logging
import os
import sys

import argparse
import configparser
import json
import requests
import datetime
import collections
import posixpath

from mako.template import Template
from pathlib import Path
from xml.etree import ElementTree

from subversion import Subversion

CFG_FILENAME = 'dataset_details.cfg'

# Logging settings
log = logging.getLogger(__name__)
out_hdlr = logging.StreamHandler(sys.stdout)
out_hdlr.setFormatter(logging.Formatter('%(asctime)s %(message)s'))
out_hdlr.setLevel(logging.DEBUG)
log.addHandler(out_hdlr)
log.setLevel(logging.DEBUG)


class cfg2CSW:
    cfg = configparser.RawConfigParser(dict_type=collections.OrderedDict)
    cfg_file = None
    cfg_url = None

    # XML template to push to geonetwork
    xml_template = os.path.join(os.path.dirname(__file__), "gn_template.xml")

    repos_details_url = ""
    repos_details_cfg = ""

    date_fmt = "%Y-%m-%dT%H:%M:%SZ"
    """
    Add metadata to Geonetwork
    """

    def __init__(self, svn_root, svn_data, gn_url, gn_user, gn_password):
        """
        Set paths, and userdata to publish metadata to geonetwork
        """

        # location of subversion root and dataset_details.cfg file
        self.svn_root = svn_root
        self.data = svn_data

        # make sure dataset_details.cfg is availabe and up-to-date
        self.svn = Subversion(target=svn_root)
        _, info = self.svn.svn_info(target=svn_root)
        dataset_url = posixpath.join(info['url'], svn_data.lstrip('/'))
        self.cfg_url = posixpath.join(dataset_url, CFG_FILENAME)
        self.svn.svn_update(target=self.cfg_url, depth='empty')

        self.cfg_file = os.path.join(self.svn_root, self.data, CFG_FILENAME)
        self.read_cfg()

        self.find_repos_details()

        # Add information of the Geonetwork instance
        self.gn_url = gn_url
        self.gn_login_j = self.gn_url + '/j_spring_security_check'
        self.gn_logout_j = self.gn_url + '/j_spring_security_logout'
        self.gn_insert_url = self.gn_url + '/srv/eng/csw-publication'
        self.gn_user = gn_user
        self.gn_pass = gn_password

        # Metadata dictionary. This dictionary will be filled with information
        # from dataset_details.cfg and repos_details.cfg
        self.metadata = {
            "general": {}, "datasets": {}
        }
        # Geonetwork uuid of the dataset
        self.uuid = ""

    def geonetwork_login(self):
        """
        Login Geonetwork. Session is used to push metadata
        """
        session = requests.Session()
        params = {'username': self.gn_user, 'password': self.gn_pass}
        response_login = session.post(self.gn_login_j, data=params)

        assert response_login.status_code == 200, 'Cannot connect to geonetwork'
        assert not b'signin.html' in response_login.content, 'Login to geonetwork failed'

        return session

    def check_uuid(self):
        """
        Check if dataset is already in geonetwork by checking uuid in dataset_details.cfg
        If uuid doesn't exist, the dataset will be inserted en the uuid created for the
        dataset will be stored in this file.
        The dataset will be updated if uuid does exist.
        """

        if self.cfg.has_option('general', 'geonetwork_uuid') and len(self.cfg.get('general', 'geonetwork_uuid')):
            self.uuid = self.cfg.get('general', 'geonetwork_uuid')
            log.info(
                'Dataset uuid available in {}. uuid={}'.format(CFG_FILENAME, self.uuid))
        else:
            log.info(
                'Dataset uuid not found')
            self.uuid = ""

        return self.uuid

    def find_repos_details(self):
        """
        find repos_details.cfg file and update it to the latest revision
        :return:
        """
        _, lst = self.svn.svn_list(self.svn.url, recursive=False, kind='file', output='name')
        if "repos_details.cfg" in lst:
            self.repos_details_url = posixpath.join(self.svn.url, "repos_details.cfg")
            self.repos_details_cfg = os.path.join(self.svn_root, "repos_details.cfg")
        else:
            _, lst0 = self.svn.svn_list(self.svn.url, recursive=False, kind='dir', output='name')
            _, info = self.svn.svn_info(target=self.svn_root)
            for item in lst0:
                url = posixpath.join(info['url'], item.lstrip('/'))
                log.debug('svn ls {}'.format(url))
                _, lst1 = self.svn.svn_list(url, recursive=False, kind='file', output='name')
                if "repos_details.cfg" in lst1:
                    self.repos_details_url = posixpath.join(self.svn.url, item, "repos_details.cfg")
                    self.repos_details_cfg = os.path.join(self.svn_root, item, "repos_details.cfg")
                    break
        if not self.repos_details_url == "":
            self.svn.svn_update(target=self.repos_details_url, depth='empty')
            log.info("{} found".format(self.repos_details_url))
        else:
            self.repos_details_cfg = ""

    def read_metadata(self):
        """
        - Read general metadata from repos_details.cfg from the trunk
        - Read data specific metadata dataset_details.cfg from the data directory
        This data will be added to the metadata dictionary.
        """

        # Define keys allowed to contain a list as value
        value_list = ["tags", "md_topiccategorycode"]

        # Read repository configuration:
        if not self.repos_details_cfg == "":
            repos_path = self.repos_details_cfg
            self.metadata = self.cfg2dict(self.metadata, repos_path, value_list)
        else:
            log.info('repos_details.cfg not available')

        # Read dataset configuration
        dataset_path = self.cfg_file
        self.metadata = self.cfg2dict(self.metadata, dataset_path, value_list)

        # create dataset from general information is no dataset is available
        if not self.metadata["datasets"]:
            self.metadata["datasets"].update(
                {"repos":
                    {"url": self.metadata["general"]["dataset_url"]}
                 })

        log.debug(self.metadata)

        # Add uuid to metadata
        self.metadata["general"].update({"uuid": self.uuid})

        return (self.metadata)

    def cfg2dict(self, dictionary, file, valuelist):
        """
        Convert cfg file to dictionary en return dictionary.
        Dictionary has the following structure:
        {
            "general": {key, value}
            , "datasets": {section
                {key, value}
            }
        }

        All items from the general section will be stored {key, value}.
        All other sections will be added to the datasets.

        valuelist should be a list with keys containing multiple items.
        Those items will be stored in a list.
        """

        data = configparser.RawConfigParser()
        data.read(file)

        exclude_sections = ["scripts"]

        for section in data.sections():
            for key, value in data.items(section):
                if key in valuelist:
                    # check if tags are already available in section
                    if key in dictionary[section]:
                        # expand list, only include new elements that are new
                        value = [v.strip() for v in value.split(',') if v.strip() not in dictionary[section][key]
                                 ] + dictionary[section][key]
                    else:
                        value = [v.strip() for v in value.split(',')]
                if section == "general":
                    if key == "title" and not value.strip() == "":
                        # title key in general section can override the dataset_name
                        dictionary[section].update({'dataset_name': value})
                    elif key == "abstract":
                        # abstract should only override if it is not empty
                        if not value.strip() == "":
                            dictionary[section].update({key: value})
                    elif key == "date":
                        # adjust the date format
                        date = datetime.datetime.strptime(value, "%Y-%m-%dT%H:%M:%S.%fZ")
                        dictionary[section].update({key: date.strftime("%Y-%m-%d")})
                    else:
                        dictionary[section].update({key: value})
                elif section not in exclude_sections:
                    if section not in dictionary["datasets"]:
                        dictionary["datasets"].update({section: {}})
                    # TODO: allow custom title (overriding the section header)
                    # TODO: allow a "geonetwork = False" item, preventing the section to show in Geonetwork
                    dictionary["datasets"][section].update({key: value})
        dictionary["general"].update({"record_date": datetime.datetime.utcnow().strftime(self.date_fmt)})
        if data.has_option("general", "owner"):
            log.debug("add owner to keywords")
            dictionary["general"].update({"tags": [v.strip() for v in data.get("general", "owner").split(',')] +
                                              dictionary["general"]["tags"]})
        return dictionary

    def create_xml(self):
        """
        Create xml file from template with metadata dictionary
        """
        template = Template(filename=self.xml_template)
        xml_payload = template.render(**self.metadata)

        return (xml_payload)

    def push_xml(self):
        """
        If uuid is empty insert xml in Geonetwork
        If uuid is present, update xml in Geonetwork
        """

        uuid = self.check_uuid()
        metadata = self.read_metadata()
        xml = self.create_xml()
        log.debug(xml)

        session = self.geonetwork_login()
        xml_payload = self.create_xml()
        # update or insert:
        if self.uuid:
            method = "Update"
        else:
            method = "Insert"

        xml_insert = '''<?xml version="1.0" encoding="UTF-8"?>
        <csw:Transaction service="CSW" version="2.0.2" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2">
           <csw:{1}>
           {0}
           </csw:{1}>
        </csw:Transaction>'''.format(xml_payload, method)

        headers = {'Content-Type': 'application/xml'}
        response_insert = session.post(
            self.gn_insert_url, data=xml_insert, headers=headers)  # insert metadata

        session.post(url=self.gn_logout_j, headers={
                     'Connection': 'close'})  # close your session

        # log.debug(response_insert.content)

        if method == "Insert":
            self.update_uuid(response_insert)

        if 200 <= response_insert.status_code < 300:
            log.info(response_insert.text)
        else:
            log.info("ERROR status code: %i" % response_insert.status_code)
            error_report_file = os.path.join(os.path.dirname(__file__), 'error%ireport.html' % response_insert.status_code)
            with open(error_report_file, 'w') as fobj:
                fobj.write(response_insert.text)

            xml_file = os.path.join(os.path.dirname(__file__), 'error%i.xml' % response_insert.status_code)
            with open(xml_file, 'w') as fobj:
                fobj.write(xml)

        # return(response_insert.status_code, response_insert.text)
        return (response_insert.text)

    def update_uuid(self, xml_response):
        """
        Add the new uuid to the existing dataset_details.cfg file.
        """

        tree = ElementTree.fromstring(xml_response.content)

        for child in tree.iter():
            if child.tag == "identifier":
                self.uuid = child.text

        # update cfg file
        self.update_cfg()
        self.write_cfg()

    def read_cfg(self):
        """
        read .cfg file as ConfigParser object
        :return:
        """
        # clear possibly remaining cfg data from the object before reading
        self.cfg.clear()
        if os.path.exists(self.cfg_file):
            self.cfg.read(self.cfg_file)

    def update_cfg(self):
        """
        update ConfigParser object with actual dataset version information
        :return:
        """
        self.cfg.set('general', 'geonetwork_uuid', self.uuid)

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

    def cfg_modified(self):
        _, svn_status = self.svn.svn_status(self.cfg_file)
        if self.cfg_file in svn_status and svn_status[self.cfg_file] == 'modified':
            return True
        else:
            return False


class Crawler:

    def __init__(self, wc_root, gn_url, gn_user, gn_password):
        self.wc_root = wc_root
        self.svn = Subversion(target=self.wc_root)

        # Add information of the Geonetwork instance
        self.gn_url = gn_url
        self.gn_user = gn_user
        self.gn_password = gn_password

    def crawl_repository(self):
        """
        perform recursive svn list
        :return:
        """
        # Generating svn object with root of the working copy as
        # Repository should be checked out sparse, since the report should be made for the whole repo

        _, lst = self.svn.svn_list(self.svn.url, recursive=True)

        modified_cfg_list = []

        for item in lst:
            if item['name'].endswith(CFG_FILENAME):
                log.info('Processing cfg: {}'.format(item['name']))
                cfg_url = posixpath.join(self.svn.url, item['name'])
                self.svn.svn_update(target=cfg_url, depth='empty')
                t = cfg2CSW(
                    svn_root=self.wc_root,
                    svn_data=os.path.split(item['name'])[0],
                    gn_url=self.gn_url,
                    gn_user=self.gn_user,
                    gn_password=self.gn_password,
                )
                response = t.push_xml()
                if t.cfg_modified():
                    modified_cfg_list.append(t.cfg_file)
        return modified_cfg_list


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Push dataset to Geonetwork')
    parser.add_argument("-w", "--svn-root", help="subversion repository working copy root")
    parser.add_argument("-d",
        "--svn-data", help="folder with data to push within de subversion repository")
    parser.add_argument("-u", "--gn-url", help="geonetwork url")
    parser.add_argument("-n", "--gn-user", help="geonetwork username")
    parser.add_argument("-p", "--gn-password", help="geonetwork password")
    parser.add_argument("-c", "--crawl", action="store_true", help="crawl whole repository")
    args = parser.parse_args()

    modified_cfg_list = []

    if args.crawl:
        c = Crawler(
            wc_root=args.svn_root,
            gn_url=args.gn_url,
            gn_user=args.gn_user,
            gn_password=args.gn_password,
        )
        modified_cfg_list = c.crawl_repository()
    else:
        t = cfg2CSW(
            svn_root=args.svn_root,
            svn_data=args.svn_data,
            gn_url=args.gn_url,
            gn_user=args.gn_user,
            gn_password=args.gn_password,
        )
        response = t.push_xml()
        if t.cfg_modified():
            modified_cfg_list = [t.cfg_file, ]

    print(modified_cfg_list)
