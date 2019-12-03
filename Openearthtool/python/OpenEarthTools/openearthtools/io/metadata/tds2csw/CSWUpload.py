#!/usr/bin/env python

""" Python class to upload nciso xml information into a csw catalog """

__author__ = "Joan Sala Calero"
__version__ = "0.1"
__email__ = "joan.salacalero@deltares.nl"
__status__ = "Prototype"

import os
import logging
from owslib.csw import CatalogueServiceWeb
from owslib.ows import ExceptionReport
from lxml.etree import XMLSyntaxError
from GMI2GMD import gmi2gmd

class cswUpload:
    # Class init, gmd namespace and input file
    def __init__(self, geonetwork_in, url_logo_in, url_godiva_in, indir):
        # Default logo
        self.url_logo=url_logo_in
        # Default ncWMS
        self.url_godiva = url_godiva_in
        # Geonetwork instance
        self.geonetwork = geonetwork_in
        # Directory tree
        self.iso_dir = indir

    # Look for files to push to CSW server
    def getfiles2push(self, dir, files2push):
        # ISo files (xml)
        files = [f for f in os.listdir(dir) if f.endswith('.xml')]

        # Small directory (all files will be pushed)
        if len(files) < 11:
            for f in files:
                files2push.append(os.path.join(dir, f))

        # Big directory (only one of the files will be uploaded, probably timesteps per nc)
        else:
            # Get a sample timestep (from the middle)
            files2push.append(os.path.join(dir,files[10]))

    # Upload xml file to CSW instance
    def push2csw(self):
        # Recursive TDS iso xml tree
        files2push = []
        for root, directories, filenames in os.walk(self.iso_dir):
            for f in filenames:
                files2push.append(os.path.join(root, f))
            for dir in directories:
                self.getfiles2push(os.path.join(root, dir), files2push)

        # Push the selected files
        for isoxml in files2push:
            self.upload_csw_iso(isoxml)

    # Format adaptation and upload to CSW server
    def upload_csw_iso(self, infile):
        global namespaces_gmd
        try:
            # Convert from GMI iso to GMD metadata
            c = gmi2gmd(self.url_logo, self.url_godiva)
            xmlcontent = c.convert(infile)

            # Insert metadata (POST request)
            csw = CatalogueServiceWeb(self.geonetwork['host'], username=self.geonetwork['user'], password=self.geonetwork['pass'])
            csw.transaction(ttype='insert', typename='gmd:MD_Metadata', record=xmlcontent)
            logging.info('Uploading [OK] -> ' + infile)
        except ExceptionReport:
            logging.warn('Uploading [EXIST] -> ' + infile)
        except IOError:
            logging.error('Uploading [FILEMISS] -> ' + infile)
        except XMLSyntaxError:
            logging.error('Uploading [XMLERR] -> ' + infile)
        except AttributeError:
            logging.error('Uploading [ATTERR] -> ' + infile)

if __name__ == '__main__':
    # ncWMS godiva viewer
    url_godiva='http://---/ncWMS-1.2/godiva2.html'

    # GeoNetwork CSW endpoint and credentials
    geonetwork_test = {
        'host': 'http://t---:8080/dataportaal/srv/eng/csw-publication',
        'user': '---',
        'pass': '---'
    }

    # Default logo url
    url_logo = 'http://marineproject.openearth.nl/images/logo_OET.png'

    # Unit Test
    t = cswUpload(geonetwork_test, url_logo, url_godiva, './iso')
    t.push2csw()