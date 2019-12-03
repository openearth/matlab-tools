#!/usr/bin/env python

""" Python script to harvest TDS iso xml information and upload it to GeoNetwork via OGC:CSW

- Clean CSW harvested products
- Gather all TDS/ISO/xml information
- Convert and push to Geonetwork/Dataportal

"""

__author__ = "Joan Sala Calero"
__version__ = "0.1"
__email__ = "joan.salacalero@deltares.nl"
__status__ = "Prototype"

import os

# Classes
from TDSHarvest import tdsHarvest
from owslib.csw import CatalogueServiceWeb
import logging

def setup_logging():
    logging.basicConfig(
        filename=os.path.join(os.getcwd(),'csw2csw.log'),
        format='%(asctime)s %(levelname)s: %(message)s',
        datefmt='%d/%m/%Y %H:%M:%S',
        level=logging.INFO
    )
    logging.info('------------------------------------------------------------------------------------------')
    logging.info('----------------------------- NEW RUN ----------------------------------------------------')
    logging.info('------------------------------------------------------------------------------------------')

if __name__ == '__main__':

    # Geonetwork input csw
    geonetwork_read = {
        'host': 'http://---/geonetwork/srv/eng/csw-publication',
        'user': '---',
        'pass': '---'
    }

    # ncWMS godiva viewer
    url_godiva='http://---/ncWMS-1.2/godiva2.html'

    # GeoNetwork CSW endpoint and credentials
    geonetwork_test = {
        'host': 'http://---/dataportaal/srv/eng/csw-publication',
        'user': '---',
        'pass': '---'
    }

    # Default logo url
    url_logo = 'http://---.gif'

    # Output directory
    out_dir=os.path.join('.', 'csw')

    # Setup logging
    setup_logging()

    # Put the csw xml to dataportal/geonetwork (update information)
    #t = cswUpload(geonetwork_stable, url_logo, url_godiva, './iso_nhi')
    #t.push2csw()
