# cdi_get_observations: returns a timeseries plot of one parameter from a remote ODV file as png
# https://publicwiki.deltares.nl/display/OET/pyWPSodv

# This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
# OpenEarthTools is an online collaboration to share and manage data and 
# programming tools in an open source, version controlled environment.
# Sign up to recieve regular updates of this function, and to contribute 
# your own tools.

# $Id: cdi_get_observations.py 10666 2014-05-08 15:17:18Z boer_g $
# $Date: 2014-05-08 17:17:18 +0200 (Thu, 08 May 2014) $
# $Author: boer_g $
# $Revision: 10666 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/processes/cdi_get_observations.py $
# $Keywords: $

from pywps.Process import WPSProcess
from pywps import config
import os, sys
import numpy as np
import pandas
from StringIO import StringIO
import json, logging
import pyodv as pyodv

tempPath = config.getConfigValue("server","tempPath") # default.cfg in pywps_processes
dataPath = config.getConfigValue("server","dataPath") # default.cfg in pywps_processes

class odvProcess(WPSProcess):
    def __init__(self):
        WPSProcess.__init__(self,
                            identifier="cdi_get_observations", # must be same, as filename
                            title="OceanDataView web processing service: cdi_get_metadata > odv_get_parameters > [bbox_plot_map, bbox_plot_profile, cdi_get_observations]",
                            version="$Id: cdi_get_observations.py 10666 2014-05-08 15:17:18Z boer_g $",
                            storeSupported=True,
                            statusSupported=True,
                            abstract="returns a timeseries plot of 1 parameter from a bounding box as png",
                            grassLocation=False)
        


        # Entry data of the data
        self.entrydate = self.addLiteralInput(identifier = "entrydate",
                                           title      = "entry date (database)",
                                           type       = type("123abc"),
                                           default    = "2020-01-01T00:00:00Z") # iso datetime 8601

        # Version of the CDI
        self.cdi = self.addLiteralInput(identifier = "cdi",
                                           title      = "cdi indentifier",
                                           type       = type("123abc"),
                                           default    = "") 

        # Version of the CDI
        self.edmo = self.addLiteralInput(identifier = "edmo",
                                           title      = "edmo indentifier",
                                           type       = type("123abc"),
                                           default    = "") 
        # Version of the CDI
        self.cdiversion = self.addLiteralInput(identifier = "cdiversion",
                                           title      = "cdi entry version",
                                           type       = type("123abc"),
                                           default    = "") 
        # Version of the Database
        self.dbversion = self.addLiteralInput(identifier = "dbversion",
                                           title      = "db entry version (database)",
                                           type       = type("123abc"),
                                           default    = "") 

        # DOI
        self.doi = self.addLiteralInput(identifier = "doi",
                                           title      = "Digital object identifier (DOI)",
                                           type       = type("123abc"),
                                           default    = "doi") 

        # Output                                            
        self.output = self.addLiteralOutput(identifier  = "result",
                                             title       = "list of cdi's created",
                                             type       = type("123abc"))
                                             

    def execute(self):
    
        # Query          
        edate=self.entrydate.getValue()
        cdi=self.cdi.getValue()
        edmo=self.cdi.getValue()
        cdiv=self.cdiversion.getValue()
        db=self.dbversion.getValue()
        d=self.doi.getValue()            
        res = pyodv.odv2orm_query.cdi_get_observations(dataPath, edate, cdi, edmo, cdiv, db, d)
        
        # Return JSON result
        self.output.setValue(json.dumps(res, default=str))
                      	
        return
