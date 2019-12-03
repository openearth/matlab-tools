# Inquire on Parameters of 1 ODV file
# https://publicwiki.deltares.nl/display/OET/pyWPSodv

# This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
# OpenEarthTools is an online collaboration to share and manage data and 
# programming tools in an open source, version controlled environment.
# Sign up to recieve regular updates of this function, and to contribute 
# your own tools.

# $Id: bbox_get_parameters.py 10991 2014-07-25 09:15:55Z boer_g $
# $Date: 2014-07-25 11:15:55 +0200 (Fri, 25 Jul 2014) $
# $Author: santinel $
# $Revision: 10991 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/processes/bbox_get_parameters.py $
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
                            identifier="bbox_get_parameters", # must be same, as filename
                            title="OceanDataView web processing service: bbox_get_metadata > bbox_get_parameters > [odv_plot_map, odv_plot_profile, odv_plot_timeseries]",
                            version="$Id: bbox_get_parameters.py 10991 2014-07-25 09:15:55Z santinel $",
                            storeSupported=True,
                            statusSupported=True,
                            abstract="bbox_get_parameters returns the Parameters of a remote ODV file as html",
                            grassLocation=False)
        
        self.bbox      = self.addBBoxInput(identifier = "bbox",
                                           title      = "bounding box [minx, maxx, miny, maxy]")
        self.filename  = self.addLiteralInput(identifier = "filename",
                                           title      = "filename (without *.txt extension)",
                                           type       = type("123abc"),
                                           default    = "")

## choose between different mimeType by padding to url (outside DataInputs=[]): &responsedocument=Parameters=@mimetype=text/html
        self.Output1 = self.addComplexOutput(identifier  = "time_series",
                                             title       = "table of Parameters of ODV file - time_series",
                                             formats    = [{"mimeType":"text/json"}, # 1st is default
                                                           {'mimeType':"text/html"}])

        self.Output2 = self.addComplexOutput(identifier  = "all_observations",
                                             title       = "table of Parameters of ODV file - all_observations",
                                             formats    = [{"mimeType":"text/json"}, # 1st is default
                                                           {'mimeType':"text/html"}])
                                                           
    def execute(self):
        
        # logging.info(self.EDMO_code.getValue() + ':' + self.filename.getValue())
        
        if dataPath[0:13]=='postgresql://':
            
            bbox = self.bbox.getValue()
            logging.info(bbox.coords)
            W = bbox.coords[0][0] # minx
            S = bbox.coords[0][1] # miny, mind order
            E = bbox.coords[1][0] # maxx, mind order
            N = bbox.coords[1][1] # maxy
            
            logging.info('bbox: W:'+str(W)+' S:'+str(S)+' E:'+str(E)+' N:'+str(N))
            logging.info(S)
            rows = pyodv.odv2orm_query.orm_from_bbox_get_parameters(dataPath,W,E,S,N)
            
            logging.info("bbox_get_parameters: ODV read from PostgreSQL with n=" + str(len(rows)))
        
            if len(rows)==0:
                return 'no data found'
            
            # df = pandas.DataFrame(rows)
            odvdict1 = rows[0]
            odvdict2 = rows[1]
            
        #else:
        
        #    url = os.path.join(dataPath,self.EDMO_code.getValue(),self.filename.getValue()  + '.txt')
            
        #    ODV       = pyodv.pyodv.Odv.fromfile(url)
        #    logging.info("cdi_get_parameters: ODV read from file")        
            
            # LOAD ODV once (cache?)

# HTML: return as JSON ?

        if np.logical_and(self.Output1.format['mimetype'] == 'text/json', self.Output2.format['mimetype'] == 'text/json'):
            tempname1 = os.path.join(tempPath,str(W) + '_' + str(E) + '_' + str(S) +'_' + str(N) + '_1.json')
            tempname2 = os.path.join(tempPath,str(W) + '_' + str(E) + '_' + str(S) +'_' + str(N) + '_2.json')
            
            # df.to_json(tempname,orient='index')
            # # include in CDATA to avoid problems with special chars, like < or >.
            df_json = "<![CDATA["+ json.dumps(odvdict1) +"]]>"
            f = open(tempname1, 'wb')
            f.write(df_json)
            f.close()
            
            df_json = "<![CDATA["+ json.dumps(odvdict2) +"]]>"
            f = open(tempname2, 'wb')
            f.write(df_json)
            f.close()    
            
        self.Output1.setValue(tempname1) # if Output2 is WPS addComplexOutput(...,asReference=False), this file will actually be written, mapped to mime and inserted into xml
        self.Output2.setValue(tempname2)
        logging.info("Output1 and Output2 written")