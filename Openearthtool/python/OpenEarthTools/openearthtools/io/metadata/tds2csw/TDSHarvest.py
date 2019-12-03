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

from StringIO import StringIO
from thredds_crawler.crawl import Crawl
from siphon.catalog import TDSCatalog

class tdsHarvest:

    # Class init, gmd namespace and input file
    def __init__(self, inurl, indir='./iso'):
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
    def harvest(self, skips,fl = None):
        # Loop over servers
        for server, thredds_url in self.catalogs.items():
            # Iniate crawler and filter
            crawler = Crawl(thredds_url, skip=skips, debug=True, workers=4)
            logging.info('Catalog: ' + server + ' -> ' + str(len(crawler.datasets)) + ' found')

            # Loop over each ISO service
            for d in crawler.datasets:
                if fl is not None:
                    fl.write(str(d.id)+'\r')
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

if __name__ == '__main__':
    # Unit Test
    t = tdsHarvest('http://al-tc067.xtr.deltares.nl/thredds/catalog/opendap/models/nhi3_2/25m/catalog.xml', './test')
    afl = r".test\content_thredds.txt"
    fl = open(afl,'w+')
    t.harvest([],fl)
    fl.close()
    
    