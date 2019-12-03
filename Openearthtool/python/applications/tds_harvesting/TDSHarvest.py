#!/usr/bin/env python

""" Python class to harvest TDS iso xml information and save it to a tree structure """

__author__ = "Joan Sala Calero"
__version__ = "0.1"
__email__ = "joan.salacalero@deltares.nl"
__status__ = "Prototype"

import os
import time
import urllib
import shutil
import logging
import wget

from StringIO import StringIO
from thredds_crawler.crawl import Crawl
from siphon.catalog import TDSCatalog

class tdsHarvest:

    # Class init, gmd namespace and input file
    def __init__(self, inurl, indir):
        # URL to harvest (provide xml TDS catalog url)
        self.tds_url = inurl
        # Output directory where store the files
        self.isodir = indir
        # Get subcatalogs
        self.catalogs = self.get_catalogs(self.tds_url)
        logging.info('---------- Catalogs ---------------')
        logging.info(self.catalogs)
        logging.info('-----------------------------------')

    # Get all subcatalogs associated with the URL
    def get_catalogs(self, url):
        # Thredds Catalog XML(subcatalogs)
        ret={}
        cat = TDSCatalog(url)
        for c in cat.catalog_refs.items():
            ret[c[0]] = c[1].href
        return ret

    # Get all the ISO information of TDS and save it in a directory tree structure
    def harvest(self, skips):
        # Loop over servers
        for server, thredds_url in self.catalogs.items():
            # Iniate crawler and filter
            crawler = Crawl(thredds_url, skip=skips, debug=True, workers=1)
            logging.info('Catalog: ' + server + ' -> ' + str(len(crawler.datasets)) + ' found')

            # Loop over each ISO service
            for d in crawler.datasets:
                for s in d.services:
                    if 'ISO' in s.get("service"):
                        # Download ISO xml
                        try:
                            temp = StringIO(urllib.urlopen(s.get('url')).read())
                            time.sleep(1)  # avoid DoS

                            # Save it in a file
                            outfname = os.path.join(self.isodir, str(d.id).replace('.nc', '.xml'))
                            path, file = os.path.split(outfname)
                            if not os.path.exists(path):   os.makedirs(path)
                            with open(outfname, 'w') as fd:
                                temp.seek(0)
                                shutil.copyfileobj(temp, fd)
                                logging.info('Downloaded: ' + outfname)
                        except:
                            logging.warn('Failed: ' + s.get("service"))
                            pass  # next url

    # Get all the netcdf files
    def collectData(self, skips):
        # Loop over servers
        for server, thredds_url in self.catalogs.items():
            # Iniate crawler and filter
            crawler = Crawl(thredds_url, skip=skips, debug=True, workers=1)
            logging.info('Catalog: ' + server + ' -> ' + str(len(crawler.datasets)) + ' found')

            # Loop over each ISO service
            cwd = os.getcwd()
            for d in crawler.datasets:
                for s in d.services:
                    if 'HTTPServer' in s.get("service"):
                        # Download from HTTP service
                        try:
                            # Save it in a file
                            outfname = os.path.join(self.isodir, str(d.id))
                            path, file = os.path.split(outfname)
                            if not os.path.exists(path):
                                os.makedirs(path)

                            # Download and restore cwd
                            os.chdir(path)
                            wget.download(s.get("url"))
                            os.chdir(cwd)
                        except:
                            logging.warn('Failed: ' + s.get("service"))
                            pass  # next url

    # Write datasets info to file
    def toCSV(self, outcsv):
        with open(outcsv, 'w') as f:
            f.write('{};{};{};{}\n'.format('DATASET', 'WORKSPACE', 'STYLE', 'PATH'))
            # Loop over servers
            for server, thredds_url in self.catalogs.items():
                # Iniate crawler
                crawler = Crawl(thredds_url, debug=True, workers=1)
                logging.info('Catalog: ' + server + ' -> ' + str(len(crawler.datasets)) + ' found')

                # Loop over each ISO service
                for d in crawler.datasets:
                    for s in d.services:
                        if 'ISO' in s.get("service"):
                            f.write('{};{};{};{}\n'.format(d.name, 'unknown workspace', 'unknown style', d.id))

if __name__ == '__main__':
    # Unit Test
    t = tdsHarvest('http://opendap-nhi-data.deltares.nl/thredds/catalog/opendap/models/nhi3_2/25m/catalog.xml', './test')
    #t.toCSV('./iso_modellen/nhi3_2.csv')
    t.collectData([])