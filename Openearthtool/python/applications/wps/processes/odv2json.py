# odv2json: turn parameter from ODV file(s) into JSON object for interactive client-side srendering

# working url calls:
# file:
# http://localhost/cgi-bin/pywps.cgi?service=wps&request=Execute&Identifier=odvPlotParameter&DataInputs=[url=d:/checkouts/OpenEarthRawData/SeaDataNet/userkc30e50-data_centre632-090210_result/world_N50W10N40E0_20060101_20070101.txt;parameter=Wind_direction%28dd%29%20[deg];clim0=0;clim1=360;]&version=1.0.0
# folder:
# http://localhost/cgi-bin/pywps.cgi?service=wps&request=Execute&Identifier=odvPlotParameter&DataInputs=[url=d:/checkouts/OpenEarthRawData/SeaDataNet/userkc30e50-data_centre632-090210_result;parameter=Wind_direction%28dd%29%20[deg];clim0=0;clim1=360;]&version=1.0.0

## WPS wrapping

from pywps.Process import WPSProcess
from pywps import config
import os, sys
import numpy as np
import pandas
from StringIO import StringIO
import json, logging
import openearthtools.io.pyodv as pyodv

tempDir = config.getConfigValue("server","tempPath") # default.cfg in pywps_processes
dataDir = config.getConfigValue("server","dataPath") # default.cfg in pywps_processes

class odvProcess(WPSProcess):
    def __init__(self):
        WPSProcess.__init__(self,
                            identifier="odv2json", # must be same, as filename
                            title="OceanDataView web processing service",
                            version="0.1",
                            storeSupported=True,
                            statusSupported=True,
                            abstract="The OceanDataView process is used to obtain ODV data via a url and printplot it in different formats, chosen by the user. The process will accept fnames, output, clim",
                            grassLocation=False)
        
        self.EDMO_code = self.addLiteralInput(identifier = "EDMO_code",
                                           title      = "EDMO_code of datacenter",
                                           type       = type("000"),
                                           default    = "486")
        self.LOCAL_CDI_ID = self.addLiteralInput(identifier = "LOCAL_CDI_ID",
                                           title      = "Unique local identifier of dataset in datacenter",
                                           type       = type("123abc"),
                                           default    = "18037204_PCh_Surf")
        self.suffix    = self.addLiteralInput(identifier = "suffix",
                                           title      = "suffix to LOCAL_CDI_ID",
                                           type       = type("123abc"),
                                           default    = "")
        self.parameter = self.addLiteralInput(identifier =  "parameter", # does not accept the backslash (\), but slash(/)
                                           title      = "ODV column name, html encoding of special characters may be used but not required (e.g. replacing space with by %20)",
                                           type       = type("salinity[psu]"),
                                           default    = "WSALIN_[PSU]")

        self.Output1 = self.addComplexOutput(identifier = "jsonOutput",
                                             title      = "json stream",
                                             formats    = [{"mimeType": 'text/json'}])

    def execute(self):

# LOAD ODV once (cache?)

        url = pyodv.odvdir.odvids2filename(dataDir, self.Input1.getValue(),self.Input2.getValue(),self.Input3.getValue())

        ODV       = pyodv.odvspar2df(url, self.parameter.getValue())
        logging.info("ODV read")

# JSON
        tempname_jsn = tempDir + '/' + os.path.splitext(os.path.basename(self.Input1.getValue()))[0] + '.json'
        JSON  = pyodv.df2json(ODV, tempname_jsn)
        logging.info("JSON written")
        self.Output1.setValue(JSON)
        
        return

