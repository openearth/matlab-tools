#!/usr/bin/env python

""" Python class to harvest all csw info from server into one directory """

__author__ = "Joan Sala Calero"
__version__ = "0.1"
__email__ = "joan.salacalero@deltares.nl"
__status__ = "Prototype"

import os
import logging
from owslib.csw import CatalogueServiceWeb
from owslib import fes
from owslib.ows import ExceptionReport
from lxml.etree import XMLSyntaxError

class cswHarvest:
    # Class init, gmd namespace and input file
    def __init__(self, geonetwork_in, geonetwork_out, outdir_in, tag='csw-harvested'):
        # Geonetwork instance
        self.geonetwork_in = geonetwork_in
        self.geonetwork_out = geonetwork_out
        # Output directory
        self.outdir = outdir_in

    # Overwrite directory
    def reset_outdir(self):
        if not(os.path.exists(self.outdir)):
            os.mkdir(self.outdir)
        else:
            for f in os.listdir(self.outdir):
                file_path = os.path.join(self.outdir, f)
                if os.path.isfile(file_path):
                    os.unlink(file_path)

    # Harvest catalogue into directory
    def harvest(self, keyw=None, recN=100, overwrite=True):
        if overwrite: self.reset_outdir()
        csw_in = CatalogueServiceWeb(self.geonetwork_in['host'], username=self.geonetwork_in['user'], password=self.geonetwork_in['pass'])
        if keyw != None:    keywords = fes.PropertyIsLike(propertyname='apiso:AnyText', literal=('*%s*' % keyw))

        start = 0
        while (True):
            if keyw != None:
                csw_in.getrecords2(constraints=[keywords], maxrecords=recN, startposition=start)
            else:
                csw_in.getrecords2(outputschema="http://www.isotc211.org/2005/gmd",typenames='gmd:MD_Metadata', maxrecords=recN, startposition=start, esn="full")
            records = csw_in.records
            start += len(records)

            if len(records) > 0:
                i = 0
                for key,value in csw_in.records.items():
                    path=os.path.join(self.outdir, key + '.xml').replace(':','')
                    # Save content
                    with open(path, 'w') as fname:
                        fname.write(value.xml)
                    i += 1
            else:
                break # no more records to delete

    def transfer(self, keyw=None, recN=100):
        csw_out = CatalogueServiceWeb(self.geonetwork_out['host'], username=self.geonetwork_out['user'], password=self.geonetwork_out['pass'])

        for f in os.listdir(self.outdir):
            file_path = os.path.join(self.outdir, f)
            with open(file_path, "r") as myfile:
                xmldata = myfile.read()

            # Replace resources by links (avoid uploading actual files)
            xmldata = xmldata.replace('WWW:DOWNLOAD-1.0-http--download', 'WWW:LINK - 1.0 - http - -link')

            try:
                # Update if exists
                csw_out.transaction(ttype='delete', identifier=str(f.replace('.xml','')))
                csw_out.transaction(ttype='insert', typename='gmd:MD_Metadata', record=xmldata)
            except ExceptionReport:
                print('Uploading [EXIST] -> ' + f)
            except IOError:
                print('Uploading [FILEMISS] -> ' + f)
            except XMLSyntaxError:
                print('Uploading [XMLERR] -> ' + f)
            except AttributeError:
                print('Uploading [ATTERR] -> ' + f)

if __name__ == '__main__':
    # GeoNetwork CSW endpoint and credentials
    geonetwork_read = {
        'host': 'http://tl-243.xtr.deltares.nl/csw',
        'user': '-',
        'pass': '-'
    }
    geonetwork_write = {
        'host': 'http://tl-tc091.xtr.deltares.nl:8080/dataportaal/srv/eng/csw-publication',
        'user': 'admin',
        'pass': 'admin'
    }
    out_dir = './switchon'

    # Prepare
    cl = cswHarvest(geonetwork_read, geonetwork_write, out_dir)

    # Harvest
    #cl.harvest()

    # Push2Catalog
    cl.transfer()





