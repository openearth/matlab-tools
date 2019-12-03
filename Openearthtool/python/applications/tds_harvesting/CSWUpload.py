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
    def getfiles2push(self, dir, files2push, max_files_per_dir=1000):
        # ISo files (xml)
        files = [f for f in os.listdir(dir) if f.endswith('.xml')]

        # Small directory (all files will be pushed)
        if len(files) < max_files_per_dir:
            for f in files:
                files2push.append(os.path.join(dir, f))
                print 'Found: '+f

        # Big directory (only one of the files will be uploaded, probably timesteps per nc)
        else:
            # Get a sample timestep (from the middle)
            print 'Found [bigdir]: ' + f
            files2push.append(os.path.join(dir,files[max_files_per_dir-1]))

    # Upload xml file to CSW instance
    def push2csw(self, convert=True):
        # Recursive TDS iso xml tree
        files2push = []
        self.getfiles2push(self.iso_dir, files2push) # Local dir
        for root, directories, filenames in os.walk(self.iso_dir): # Subdirectories
            for dir in directories:
                self.getfiles2push(os.path.join(root, dir), files2push)

        # Push the selected files
        for isoxml in files2push:
            self.upload_csw_iso(isoxml, convert)

        print '''Found : {} datasets'''.format(len(files2push))

    # Format adaptation and upload to CSW server
    def upload_csw_iso(self, infile, convert):
        global namespaces_gmd
        try:
            # Just in case
            idname = os.path.basename(infile).replace('.xml', '')

            # Convert from GMI iso to GMD metadata
            if convert:
                c = gmi2gmd(self.url_logo, self.url_godiva)
                xmlcontent = c.convert(infile, generateID=True).replace('\n', '')
            else:
                with open(infile, "r") as f:
                    xmlcontent = f.read().replace('\n', '')

            # Insert metadata (POST request)
            csw = CatalogueServiceWeb(self.geonetwork['host'], username=self.geonetwork['user'], password=self.geonetwork['pass'])
            csw.transaction(ttype='insert', typename='gmd:MD_Metadata', record=xmlcontent)

            # Everything went well... hopefully
            logging.info('Uploading [OK] -> ' + infile)
            print('Uploading [OK] -> ' + infile)

        except ExceptionReport:
            logging.warn('Uploading [SYNTAX-ISO] -> ' + infile)
            print('Uploading [SYNTAX-ISO] -> ' + infile)
            #print csw.response
            #print xmlcontent
            pass
        except IOError:
            logging.error('Uploading [FILEMISS] -> ' + infile)
            print('Uploading [FILEMISS] -> ' + infile)
            pass
        except XMLSyntaxError:
            logging.error('Uploading [XMLERR] -> ' + infile)
            print('Uploading [XMLERR] -> ' + infile)
            #print csw.response
            pass
        except AttributeError:
            logging.error('Uploading [ATTERR] -> ' + infile)
            print('Uploading [ATTERR] -> ' + infile)
            #print csw.response
            pass
