# -*- coding: utf-8 -*-
"""
Created on Mon Sep 29 16:44:03 2014

@author: hendrik_gt

Repository information:
Date of last commit:     $Date: 2015-04-01 09:36:12 +0200 (Wed, 01 Apr 2015) $
Revision of last commit: $Revision: 11846 $
Author of last commit:   $Author: hendrik_gt $
URL of source:           $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/naivasha/fews_getparameters.py $
CodeID:                  $ID$


http://localhost/cgi-bin/pywps.cgi?service=wps&request=GetCapabilities&version=1.0.0

http://localhost/cgi-bin/pywps.cgi?service=wps&request=DescribeProcess&Identifier=fews_getparameters&version=1.0.0

http://localhost/cgi-bin/pywps.cgi?request=Execute&service=wps&version=1.0.0&identifier=fews_getparameters&datainputs=[wellid=iets]

"""

from pywps.Process import WPSProcess
from pywps import config
import logging
import netCDF4
# from opendap import opendap
import openearthtools.io.opendap.catalog as catalog

tempDir = config.getConfigValue("server","tempPath")
class Process(WPSProcess):
    def __init__(self):

        ##
        # Process initialization
        WPSProcess.__init__(self,
            identifier = "fews_getparameters",
            title="Return available time series parameters",
            abstract="""Get available parameters with timeseries""",
            version = "1.0",
            storeSupported = True,
            statusSupported = True)

        self.textIn = self.addLiteralInput(identifier="empty",
                                           title     ="Parameter ID",
                                           type      =type(""),
                                           default   ="A.obs")


        ##
        # Adding process outputs
        self.Output1 = self.addComplexOutput(identifier  = "Parameters",
                                             title       = "List of available Parameters with timeseries",
                                             formats    = [{"mimeType":"text/plain"}, # 1st is default
                                                           ])

    ##
    # Execution part of the process
    def execute(self):
    #    self.Output1.setValue(self.test.getValue())
     #   return

        # just copy the input values to output values


        catalogurl = 'http://opendap-nhi-data.deltares.nl/thredds/catalog/opendap/nhi3_2/catalog.xml'
        urls = list(catalog.getchildren(catalogurl))
        
        dictnc = {}
        for url in urls:
            lst = list(catalog.getchildren(url))
            for d in lst:
                dl = list(catalog.getchildren(d))
                ncs = [nc for nc in dl if '.nc' in nc]
                for i in ncs:
                    ds = netCDF4.Dataset(i)
                    s = i.split('/')
                    dictnc[s[len(s)-1]] = [s[len(s)-4],s[len(s)-3],s[len(s)-2],i,ds.variables['Band1'].long_name]
                    ds.close()
        logging.info('fews_getparameters started')
        io = waterinformation.getparameters()
        self.Output1.setValue(io)
        io.close()
        return