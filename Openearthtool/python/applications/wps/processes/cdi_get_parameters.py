# Inquire on Parameters of 1 ODV file
# https://publicwiki.deltares.nl/display/OET/pyWPSodv

# This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
# OpenEarthTools is an online collaboration to share and manage data and 
# programming tools in an open source, version controlled environment.
# Sign up to recieve regular updates of this function, and to contribute 
# your own tools.

# $Id: cdi_get_parameters.py 11429 2014-11-24 18:13:50Z santinel $
# $Date: 2014-11-24 10:13:50 -0800 (Mon, 24 Nov 2014) $
# $Author: santinel $
# $Revision: 11429 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/processes/cdi_get_parameters.py $
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
                            identifier="cdi_get_parameters", # must be same, as filename
                            title="OceanDataView web processing service: cdi_get_metadata > cdi_get_parameters > [odv_plot_map, odv_plot_profile, odv_plot_timeseries]",
                            version="$Id: cdi_get_parameters.py 11429 2014-11-24 18:13:50Z santinel $",
                            storeSupported=True,
                            statusSupported=True,
                            abstract="cdi_get_parameters returns the Parameters of a remote ODV file as html",
                            grassLocation=False)
        
        self.EDMO_code = self.addLiteralInput(identifier = "EDMO_code",
                                           title      = "EDMO_code of datacenter",
                                           type       = type("000"),
                                           default    = "486")
        self.LOCAL_CDI_ID = self.addLiteralInput(identifier = "LOCAL_CDI_ID",
                                           title      = "Unique local identifier of dataset in datacenter",
                                           type       = type("123abc"),
                                           default    = "18037204_PCh_Surf")
        self.filename  = self.addLiteralInput(identifier = "filename",
                                           title      = "filename (without *.txt extension)",
                                           type       = type("123abc"),
                                           default    = "")

## choose between different mimeType by padding to url (outside DataInputs=[]): &responsedocument=Parameters=@mimetype=text/html
        self.Output1 = self.addComplexOutput(identifier  = "Parameters",
                                             title       = "table of Parameters of ODV file",
                                             formats    = [{"mimeType":"text/json"}, # 1st is default
                                                           {'mimeType':"text/html"}])


    def execute(self):
        
        # logging.info(self.EDMO_code.getValue() + ':' + self.filename.getValue())
        
        if dataPath[0:13]=='postgresql://':
        
            rows = pyodv.odv2orm_query.orm_cdi_get_parameters(dataPath,
                                                   self.EDMO_code.getValue(), self.LOCAL_CDI_ID.getValue())
            
            logging.info("cdi_get_parameters: ODV read from PostgreSQL with n=" + str(len(rows)))
        
            if len(rows)==0:
                return 'no data found'
            
            
            df = pandas.DataFrame(rows)


            
        #else:
        
        #    url = os.path.join(dataPath,self.EDMO_code.getValue(),self.filename.getValue()  + '.txt')
            
        #    ODV       = pyodv.pyodv.Odv.fromfile(url)
        #    logging.info("cdi_get_parameters: ODV read from file")        
            
            # LOAD ODV once (cache?)

# HTML: return as JSON ?

        if self.Output1.format['mimetype'] == 'text/json':
            tempname = os.path.join(tempPath, self.EDMO_code.getValue() + '_' + self.LOCAL_CDI_ID.getValue() + '.json')
            
            # df.to_json(tempname,orient='index')
            # # include in CDATA to avoid problems with special chars, like < or >.
            df_json = "<![CDATA["+ df.to_json(orient='index') +"]]>"
            f = open(tempname, 'wb')
            f.write(df_json)
            f.close()    
            
        #elif self.Output1.format['mimetype'] == 'text/html':
        #    tempname = os.path.join(tempPath, os.path.splitext(os.path.basename(url))[0] + '.html')
        #    f = open(tempname, 'wb')
        #    f.write(ODV.meta2html())
        #    f.close()
        
        self.Output1.setValue(tempname) # if Output2 is WPS addComplexOutput(...,asReference=False), this file will actually be written, mapped to mime and inserted into xml
        logging.info("Output1 written")
