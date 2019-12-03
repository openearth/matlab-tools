# GetProfile: returns a profile of a transect in a remote bathymetry from lat0 lon0 lat1 lon1 in .nc file as json for FAST project
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
dataPath = r'http://198.51.100.4:8080/thredds/dodsC/opendap/dem_clip_wgs84.nc'
# dataPath = config.getConfigValue("server","dataPath")
# dataPath = config.getConfigValue("server","dataPath") + '//' + 'dem_clip_wgs84.nc' # pretty bad.

class odvProcess(WPSProcess):
    def __init__(self):
        WPSProcess.__init__(self,
                            identifier="GetProfile", # must be same, as filename
                            title="FAST web processing service: GetCapabilities > [GetWaterLevels, GetProfile, GetVegetation]",
                            version="$Id$", # to be changed
                            storeSupported=True,
                            statusSupported=True,
                            abstract="returns a profile of a transect from a remote bathymetry in .nc file as json",
                            grassLocation=False)
        
        self.lat0     = self.addLiteralInput(identifier = "lat0",
                                           title      = "start latitude in DD for profile calculation",
                                           type       = type(0.0),
                                           default    = float(np.array([-90]))) # realmax, does not accept [] as default for type(0.0)
        self.lon0     = self.addLiteralInput(identifier = "lon0",
                                           title      = "start longitude in DD for profile calculation",
                                           type       = type(10.0),
                                           default    = float(np.array([-180]))) # realmin, does not accept [] as default for type(0.0)
        self.lat1     = self.addLiteralInput(identifier = "lat1",
                                           title      = "end latitude in DD for profile calculation",
                                           type       = type(0.0),
                                           default    = float(np.array([90]))) # realmax, does not accept [] as default for type(0.0)
        self.lon1     = self.addLiteralInput(identifier = "lon1",
                                           title      = "end longitude in DD for profile calculation",
                                           type       = type(10.0),
                                           default    = float(np.array([180]))) # realmin, does not accept [] as default for type(0.0)
        self.map     = self.addLiteralInput(identifier = "map",
                                           title      = "whether to plot data (1) or not (0, default)",
                                           type       = type(1),
                                           default    = 0)
                                           
# choose between different mimeType by padding to url (outside DataInputs=[]): &responsedocument=mapname=@mimetype=application/vnd.google-earth.kmz
        self.Output1 = self.addComplexOutput(identifier  = "profile",
                                             title       = "Profile coordinates",
                                             formats    = [{"mimeType":"text/json"}, # 1st is default
                                                           {'mimeType':"text/html"}]) 
    def execute(self):
        logging.info( dataPath)
        if dataPath[-3:]=='.nc':
            # TODO
            [x,y,z] = fast.transect2profile(dataPath,
                                    self.lat0.getValue(),self.lon0.getValue(),
                                    self.lat1.getValue(),self.lon1.getValue())
            
            logging.info("GetProfile: nc read from opendap Z=[" + str(np.shape(z)) + "]")
        
            if len(z)==0:
                return 'no data found'
            
            
            # df = pandas.DataFrame(rows)

# HTML: return as JSON ?

        if self.Output1.format['mimetype'] == 'text/json':
            tempname = os.path.join(tempPath, str(self.lat0.getValue()) + '_' + str(self.lon0.getValue()) + '_' + 
                                    str(self.lat1.getValue()) + '_' + str(self.lon1.getValue()) + '.json')
            
            # TODO: put together
            # tt=np.vstack((x,y,z))
            
            # df.to_json(tempname,orient='index') 
            # # include in CDATA to avoid problems with special chars, like < or >.
            tr_json = fast.profile2json(tempname,x,y,z)
            # tr_json = "<![CDATA["+ tr_json +"]]>"
            f = open(tempname, 'wb')
            f.write(tr_json)
            f.close()    
                    
        self.Output1.setValue(tempname) # if Output2 is WPS addComplexOutput(...,asReference=False), this file will actually be written, mapped to mime and inserted into xml
        logging.info("Output1 written")

