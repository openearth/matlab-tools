# bbox_plot_map: returns a planview plot of a remote ODV file or folder as png and kmz
# https://publicwiki.deltares.nl/display/OET/pyWPSodv

# This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
# OpenEarthTools is an online collaboration to share and manage data and 
# programming tools in an open source, version controlled environment.
# Sign up to recieve regular updates of this function, and to contribute 
# your own tools.

# $Id: bbox_plot_map.py 10971 2014-07-18 09:39:38Z boer_g $
# $Date: 2014-07-18 11:39:38 +0200 (Fri, 18 Jul 2014) $
# $Author: boer_g $
# $Revision: 10971 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/processes/bbox_plot_map.py $
# $Keywords: $

# TODO: include cname in odv2map and odv2mapkmz call

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
returntype = 2

class odvProcess(WPSProcess):
    def __init__(self):
        WPSProcess.__init__(self,
                            identifier="bbox_plot_map",     # must be same, as filename
                            title="OceanDataView web processing service: cdi_get_metadata > odv_get_parameters > [bbox_plot_map, bbox_plot_profile, bbox_plot_timeseries]",
                            version="$Id: bbox_plot_map.py 10971 2014-07-18 09:39:38Z boer_g $",
                            storeSupported=True,
                            statusSupported=True,
                            abstract="returns a planview plot of 1 parameter from a bounding box as png image or kmz Google Earth file.",
                            grassLocation=False)
        
        self.bbox      = self.addBBoxInput(identifier = "bbox",
                                           title      = "bounding box [minx, maxx, miny, maxy]")
        self.parameter = self.addLiteralInput(identifier =  "parameter", # does not accept the backslash (\), but slash(/)
                                           title      = "ODV column name, html encoding of special characters may be used but not required (e.g. replacing space with by %20)",
                                           type       = type("Bot. Depth [m]"), #this parameter always present duo to ODV definition
                                           default    = "Bot. Depth [m]")
        self.clim0     = self.addLiteralInput(identifier = "clim0",
                                           title      = "lower colorbar limit for plot, skip keyword for autoscale",
                                           type       = type(0.0),
                                           default    = float(np.finfo('single').max)) # realmax, does not accept [] as default for type(0.0)
        self.clim1     = self.addLiteralInput(identifier = "clim1",
                                           title      = "upper colorbar limit for plot, skip keyword for autoscale",
                                           type       = type(100.0),
                                           default    = float(np.finfo('single').min)) # realmin, does not accept [] as default for type(0.0)
        self.log10     = self.addLiteralInput(identifier = "log10",
                                           title      = "whether to plot data in log scale (1) or not (0, default)",
                                           type       = type(11),
                                           default    = 0)
        self.kmzcolumns     = self.addLiteralInput(identifier = "kmzcolumns",
                                           title      = "whether to plot data as column (1) or not (0, default)",
                                           type       = type(11),
                                           default    = 0)                                           
        self.colormap  = self.addLiteralInput(identifier = "colormap",
                                           title      = "colormap from matplotlib dictionary: http://wiki.scipy.org/Cookbook/Matplotlib/Show_colormaps, http://www.physics.ox.ac.uk/Users/msshin/science/code/matplotlib_cm/",
                                           type       = type("jet"), # that's a string
                                           default    = "jet")

        self.marker  = self.addLiteralInput(identifier = "marker",
                                           title      = "marker from matplotlib dictionary: http://matplotlib.org/api/markers_api.html?highlight=marker#module-matplotlib.markers",
                                           type       = type("o"), # that's a string
                                           default    = "o")
                                           
        self.alpha  = self.addLiteralInput(identifier = "alpha",
                                           title      = "alpha from matplotlib dictionary: http://matplotlib.org/api/pyplot_api.html?highlight=scatter#matplotlib.pyplot.scatter",
                                           type       = type(0.0),
                                           default    = 1)
        
# Crashes when creating same file twice:
# Process executed. Failed to build final response for output [identifier]: [Error 183] Cannot create a file when that file already exists
# so either do a prior clean-up, or add a unique code and schedule a cleanup batch

# choose between different mimeType by padding to url (outside DataInputs=[]): &responsedocument=mapname=@mimetype=application/vnd.google-earth.kmz

        if returntype==1: # OK: local file
           self.Output1 = self.addLiteralOutput(identifier = "mapname",
                                                title      = "local path of the temporary kmz file created",
                                                type       = type("url"))
        elif returntype==2: # OK: mime, unless file already exist: error [183]
           self.Output1 = self.addComplexOutput(identifier  = "mapname",
                                                title       = "mime encoding of map visualisation created",
                                                formats     = [{"mimeType":"image/png"}, # 1st is default
                                                               {"mimeType": 'application/vnd.google-earth.kmz'}])
        elif returntype==3: ## Does not work yet: crash
           self.Output1 = self.addComplexOutput(identifier  = "mapname",
                                                title       = "url of png file created",
                                                asReference = True,
                                                formats     = [{"mimeType":"image/png"}, # 1st is default
                                                               {"mimeType": 'application/vnd.google-earth.kmz'}])

                                                               
    def execute(self):
    
        # logging.info("bbox_plot_map: tempPath: " + tempPath)
        # logging.info("bbox_plot_map: dataPath: " + dataPath)
    
        if dataPath[0:13]=='postgresql://':
        
            bbox = self.bbox.getValue()
            logging.info(bbox.coords)
            W = bbox.coords[0][0] # minx
            S = bbox.coords[0][1] # miny, mind order
            E = bbox.coords[1][0] # maxx, mind order
            N = bbox.coords[1][1] # maxy
            
            logging.info('bbox: W:'+str(W)+' S:'+str(S)+' E:'+str(E)+' N:'+str(N))
            
            ODV = pyodv.odv2orm_query.orm_from_bbox(dataPath,self.parameter.getValue(),W,E,S,N)
            
            logging.info("bbox_plot_map: ODV read from PostgreSQL with n=" + str(len(ODV.data)))
            
            
            if len(ODV.data)==0:
                return 'no data found'

        else:
    
            return "ERROR odv file backend has no bbox request implemented"

        clims      = [self.clim0.getValue(),self.clim1.getValue()]
        cmapstr    = self.colormap.getValue()
        markertype = self.marker.getValue()
        alphavalue = self.alpha.getValue()

# define temp file name, and clean-up any previous output

        ext = '.png'
        if returntype > 1:
            logging.info("mimetype:" + self.Output1.format['mimetype'])
            if self.Output1.format['mimetype'] == 'application/vnd.google-earth.kmz':
                ext = '.kmz'
            #elif self.Output1.format['mimetype'] == 'application/vnd.google-earth.kml':
            #    ext = '.kml'
            elif self.Output1.format['mimetype'] == 'image/png':
                ext = '.png'
        
        tempname = os.path.join(tempPath,tempPath,str(W) + '_' + str(S) + '_' + str(E) + '_' + str(N) + '_' +
                                             self.parameter.getValue() + '_map' + ext)
        if os.path.isfile(tempname):
           os.remove     (tempname)
        if os.path.isfile(tempname + ".binary"):
           os.remove     (tempname + ".binary")
           logging.info("trying to remove " + tempname)
        if os.path.isfile(tempname):
           logging.info("failed to remove " + tempname)

# actually plot now

        if ext == '.kmz':
            if self.kmzcolumns.getValue() == 1: # columns
                pyodv.odv2mapcolumnskmz(tempname,ODV,self.parameter.getValue(),clims,self.log10.getValue(),self.kmzcolumns.getValue(),cmapstr,alphavalue)
            else: # balloon style
                pyodv.odv2mapkmz(tempname,ODV,self.parameter.getValue(),clims,self.log10.getValue(),cmapstr,alphavalue)
        elif ext == '.png':
            pyodv.odv2map       (tempname,ODV,self.parameter.getValue(),clims,self.log10.getValue(),cmapstr,markertype,alphavalue)

# Return and DO NOT clean-up here, pyWPS packages them as MIME only <after> return

        logging.info(ext + " written to " + tempname)
        self.Output1.setValue(tempname) # if Output1 is WPS addComplexOutput(...,asReference=False), this file will actually be written, mapped to mime and inserted into xml

        ## request for piwik [matomo] count. See https://developer.matomo.org/api-reference/tracking-api
        import requests
        logging.info(self.identifier)
        idsite = 23
        rec = 1
        action_name = self.identifier
        e_c = 'map' # event category
        e_a = 'show' # event action
        e_n = self.parameter.getValue() # event name
        e_v = 1 # event value
        rurl = 'http://piwik.vliz.be/piwik.php?idsite={}&rec={}&action_name={}&e_c={}&e_a={}&e_n={}&e_v={}'.format(idsite, rec, action_name, e_c, e_a, e_n.upper(), e_v)
        r = requests.get(rurl)
        #logging.info(rurl)
        #logging.info(r)
        
        return

