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
from CSWUpload import cswUpload
from CSWClean import cswClean
import logging

def setup_logging():
    logging.basicConfig(
        filename=os.path.join(os.getcwd(),'tds2csw.log'),
        format='%(asctime)s %(levelname)s: %(message)s',
        datefmt='%d/%m/%Y %H:%M:%S',
        level=logging.INFO
    )
    logging.info('------------------------------------------------------------------------------------------')
    logging.info('----------------------------- NEW RUN ----------------------------------------------------')
    logging.info('------------------------------------------------------------------------------------------')

if __name__ == '__main__':

    # Thredds Catalog XML(subcatalogs)
    url_tds='http://opendap-nhi-data.deltares.nl:8080/thredds/catalog.html'
    skips = ['subgrid_alcatraz_map_15min.nc', 'vaklodingen.nc', 'upld_B62C0059-231.nc']

    # ncWMS godiva viewer
    url_godiva='http://tl-tc094.xtr.deltares.nl:8080/ncWMS/godiva2.html'

    # GeoNetwork CSW endpoint and credentials
    geonetwork_test = {
        'host': 'http://tl-tc083.xtr.deltares.nl:8080/dataportaal/srv/eng/csw-publication',
        'user': 'admin',
        'pass': '9J9*6NjN'
    }

    # Default logo url
    url_logo = 'http://nhi.nu/nl/themes/NHI2015/images/NHI_outs.png'

    # Output directory
    iso_dir=os.path.join('.', 'iso_nhi')

    # Setup logging
    setup_logging()

    # Download all ncISO information of TDS servers
    #t = tdsHarvest(url_tds, iso_dir)
    #t.harvest(skips)

    # Clean all harvested products from the CSW server (to force update)
    cl = cswClean(geonetwork_test)
    cl.clean()

    # Put the ISO1 xml to dataportal/geonetwork (update information)
    t = cswUpload(geonetwork_test, url_logo, url_godiva, iso_dir)
    t.push2csw()

    print 'FINISH'
