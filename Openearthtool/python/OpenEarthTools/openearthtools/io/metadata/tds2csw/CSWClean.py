#!/usr/bin/env python

""" Python class clean all harvested products from a tds instance """

__author__ = "Joan Sala Calero"
__version__ = "0.1"
__email__ = "joan.salacalero@deltares.nl"
__status__ = "Prototype"

import os
import logging
from owslib.csw import CatalogueServiceWeb
from owslib import fes

class cswClean:
    # Class init, gmd namespace and input file
    def __init__(self, geonetwork_in):
        # Geonetwork instance
        self.geonetwork = geonetwork_in

    def clean(self, key='tds2csw'):
        csw = CatalogueServiceWeb(self.geonetwork['host'], username=self.geonetwork['user'], password=self.geonetwork['pass'])
        keywords = fes.PropertyIsLike(propertyname='apiso:AnyText', literal=('*%s*' % key))

        try:
            while (True):
                csw.getrecords2(constraints=[keywords], maxrecords=100)
                records = csw.records
                if len(records) > 0:
                    i = 0
                    for rec in records:
                        logging.info('Deleting: ' + str(rec))
                        csw.transaction(ttype='delete', identifier=str(rec))
                        logging.debug(csw.response)
                        i += 1
                    print('Deleted '+str(i)+' records')
                else:
                    break # no more records to delete
        except:
            return

if __name__ == '__main__':
    # GeoNetwork CSW endpoint and credentials
    geonetwork = {
        'host': 'http://---/dataportaal/srv/eng/csw-publication',
        'user': '---',
        'pass': '---'
    }
    cl = cswClean(geonetwork)
    cl.clean()





