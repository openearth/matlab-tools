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
import logging

def setup_logging():
    logging.basicConfig(
        filename=os.path.join(os.getcwd(),'tds2geoserver.log'),
        format='%(asctime)s %(levelname)s: %(message)s',
        datefmt='%d/%m/%Y %H:%M:%S',
        level=logging.INFO
    )
    logging.info('------------------------------------------------------------------------------------------')
    logging.info('----------------------------- NEW RUN ----------------------------------------------------')
    logging.info('------------------------------------------------------------------------------------------')

if __name__ == '__main__':

    # Thredds Catalog XML(subcatalogs)
    url_tds='http://opendap-nhi-data.deltares.nl/thredds/catalog/opendap/Modellen/NHI/modelinvoer/catalog.html'

    # Output directory
    iso_dir=os.path.join('.', 'iso_modellen')

    # Setup logging
    setup_logging()

    # Download all ncISO information of TDS servers
    t = tdsHarvest(url_tds, iso_dir)

    # Download all ncISO information of TDS servers
    t.harvest([])
    t.toCSV(os.path.join(iso_dir, 'NHI_modellen.csv'))

    # Download all netcdf's files of TDS servers
    t.collectData([])

    print 'FINISH'
