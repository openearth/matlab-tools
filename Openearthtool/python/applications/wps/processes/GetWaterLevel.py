# GetWaterLevel: returns a tidal level of a transect in a remote bathymetry from datetime as json for FAST project. Source is predicted astronomical tide
# https://publicwiki.deltares.nl/display/OET/ ...TODO 

# This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
# OpenEarthTools is an online collaboration to share and manage data and 
# programming tools in an open source, version controlled environment.
# Sign up to recieve regular updates of this function, and to contribute 
# your own tools.

# $Id$
# $Date$
# $Author: santinel $
# $Revision$
# $HeadURL$
# $Keywords$

from pywps.Process import WPSProcess
from pywps import config
import os, sys
import numpy as np
import pandas
from StringIO import StringIO
import json, logging
import fast as fast

# tempPath = config.getConfigValue("server","tempPath") # default.cfg in pywps_processes
# dataPath = config.getConfigValue("server","dataPath") # default.cfg in pywps_processes

tempPath = config.getConfigValue("server","tempPath") # default.cfg in pywps_processes
dataPath = r'n:\Projects\1207000\1207298\B. Measurements and calculations\WP5\data\data\giorgio_calculations\DEM2netcdf\dem_clip_wgs84.nc'
dataPath = r'http://198.51.100.4:8080/thredds/dodsC/opendap/astro_tide.nc'
dataPath = r'astro_tide.nc'

class odvProcess(WPSProcess):
    def __init__(self):
        WPSProcess.__init__(self,
                            identifier="GetWaterLevel", # must be same, as filename
                            title="FAST web processing service: GetCapabilities > [GetWaterLevel, GetProfile, GetVegetation]",
                            version="$Id$", # to be changed
                            storeSupported=True,
                            statusSupported=True,
                            abstract="returns a tidal level from the astronomical tide in .nc as json",
                            grassLocation=False)
        
        self.tidedatetime = self.addLiteralInput(identifier = "tidedatetime",
                                           title      = "datetime for water level calculation",
                                           type       = type("123abc"),
                                           default    = datetime.datetime.utcnow().isoformat()) # = "1970-01-01T00:00:00Z": iso datetime 8601

# choose between different mimeType by padding to url (outside DataInputs=[]): &responsedocument=mapname=@mimetype=application/vnd.google-earth.kmz
        self.Output1 = self.addComplexOutput(identifier  = "level",
                                             title       = "Water level",
                                             formats    = [{"mimeType":"text/json"}, # 1st is default
                                                           {'mimeType':"text/html"}]) 
    def execute(self):
        logging.info( dataPath)
        if dataPath[-3:]=='.nc':
            # TODO
            
            z = fast.datetime2tide(dataPath, self.datetime.getValue())
            
            logging.info("GetWaterLevel: netCDF successfully read")
        
            if len(z)==0:
                return 'no data found'
            
            
            # df = pandas.DataFrame(rows)

# HTML: return as JSON ?

        if self.Output1.format['mimetype'] == 'text/json':
            
            import calendar
            tidedt=datetime.datetime.strptime(tidedatetime,"%Y-%m-%dT%H:%M:%S.%f")
            tideEpoch=calendar.timegm(tidedt.utctimetuple())
            
            tempname = os.path.join(tempPath, str(tideEpoch) + '.json')
            
            # TODO: put together
            # tt=np.vstack((x,y,z))
            
            # df.to_json(tempname,orient='index') 
            # # include in CDATA to avoid problems with special chars, like < or >.
            dt_json = z
            # tr_json = "<![CDATA["+ tr_json +"]]>"
            f = open(tempname, 'wb')
            f.write(dt_json)
            f.close()    
                    
        self.Output1.setValue(tempname) # if Output2 is WPS addComplexOutput(...,asReference=False), this file will actually be written, mapped to mime and inserted into xml
        logging.info("Output1 written")

