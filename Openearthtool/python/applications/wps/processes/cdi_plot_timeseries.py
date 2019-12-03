# cdi_plot_timeseries: returns a timeseries plot of one parameter from a remote ODV file as png
# https://publicwiki.deltares.nl/display/OET/pyWPSodv

# This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
# OpenEarthTools is an online collaboration to share and manage data and 
# programming tools in an open source, version controlled environment.
# Sign up to recieve regular updates of this function, and to contribute 
# your own tools.

# $Id: cdi_plot_timeseries.py 10666 2014-05-08 15:17:18Z boer_g $
# $Date: 2014-05-08 17:17:18 +0200 (Thu, 08 May 2014) $
# $Author: boer_g $
# $Revision: 10666 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/processes/cdi_plot_timeseries.py $
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
                            identifier="cdi_plot_timeseries", # must be same, as filename
                            title="OceanDataView web processing service: cdi_get_metadata > odv_get_parameters > [cdi_plot_map, cdi_plot_profile, cdi_plot_timeseries]",
                            version="$Id: cdi_plot_timeseries.py 10666 2014-05-08 15:17:18Z boer_g $",
                            storeSupported=True,
                            statusSupported=True,
                            abstract="returns a timeseries plot of 1 parameter from a remote cdi as png",
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
        self.parameter = self.addLiteralInput(identifier =  "parameter", # does not accept the backslash (\), but slash(/)
                                           title      = "ODV column name, html encoding of special characters may be used but not required (e.g. replacing space with by %20)",
                                           type       = type("salinity[psu]"),
                                           default    = "WSALIN_[PSU]")
        self.clim0     = self.addLiteralInput(identifier = "clim0",
                                           title      = "lower y-axis limit for plot, skip keyword for autoscale",
                                           type       = type(0.0),
                                           default    = float(np.finfo('single').max)) # realmax, does not accept [] as default for type(0.0)
        self.clim1     = self.addLiteralInput(identifier = "clim1",
                                           title      = "upper y-axis limit for plot, skip keyword for autoscale",
                                           type       = type(100.0),
                                           default    = float(np.finfo('single').min)) # realmin, does not accept [] as default for type(0.0)
        self.zlim0 = self.addLiteralInput(identifier = "zlim0",
                                           title      = "lower y-axis limit for plot, skip keyword for autoscale",
                                           type       = type(0.0),
                                           default    = float(np.finfo('single').min))  # realmin, does not accept [] as default for type(0.0)
        self.zlim1 = self.addLiteralInput(identifier = "zlim1",
                                           title      = "upper y-axis limit for plot, skip keyword for autoscale",
                                           type       = type(100.0),
                                           default    = float(np.finfo('single').max)) # realmax, does not accept [] as default for type(0.0)
        self.starttime = self.addLiteralInput(identifier = "starttime",
                                           title      = "start time limit for plot",
                                           type       = type("123abc"),
                                           default    = "1970-01-01T00:00:00Z") # iso datetime 8601
        self.endtime = self.addLiteralInput(identifier = "endtime",
                                           title      = "end time limit for plot",
                                           type       = type("123abc"),
                                           default    = "2020-01-01T00:00:00Z") # iso datetime 8601
        self.colormap  = self.addLiteralInput(identifier = "colormap",
                                           title      = "colormap from matplotlib dictionary: http://wiki.scipy.org/Cookbook/Matplotlib/Show_colormaps, http://www.physics.ox.ac.uk/Users/msshin/science/code/matplotlib_cm/",
                                           type       = type("jet"), # that's a string
                                           default    = "jet") # if it is null, no colormap
        self.log10     = self.addLiteralInput(identifier = "log10",
                                           title      = "whether to plot data in log scale (1) or not (0, default)",
                                           type       = type(11),
                                           default    = 0)        
        self.z     = self.addLiteralInput(identifier =  "z", # does not accept the backslash (\), but slash(/)
                                           title      = "ODV column name, html encoding of special characters may be used but not required (e.g. replacing space with by %20)",
                                           type       = type("PRESSURE [dbar]"),
                                           default    = "PRESSURE [dbar]")
        self.color  = self.addLiteralInput(identifier = "color",
                                           title      = "color from matplotlib dictionary: http://matplotlib.org/api/pyplot_api.html?highlight=plot#matplotlib.pyplot.plot",
                                           type       = type("red"), # that's a string
                                           default    = "blue")
        self.marker  = self.addLiteralInput(identifier = "marker",
                                           title      = "marker from matplotlib dictionary: http://matplotlib.org/api/pyplot_api.html?highlight=plot_date#matplotlib.pyplot.plot_date",
                                           type       = type("o"), # that's a string
                                           default    = "o")
        self.markersize = self.addLiteralInput(identifier = "markersize",
                                           title      = "markersize from matplotlib dictionary: http://matplotlib.org/api/pyplot_api.html?highlight=plot_date#matplotlib.pyplot.plot_date",
                                           type       = type(1.0),
                                           default    = 6.0)
        self.alpha  = self.addLiteralInput(identifier = "alpha",
                                           title      = "alpha from matplotlib dictionary: http://matplotlib.org/api/pyplot_api.html?highlight=plot_date#matplotlib.pyplot.plot_date",
                                           type       = type(0.0),
                                           default    = 1)
        

# Crashes when creating same file twice:
# Process executed. Failed to build final response for output [identifier]: [Error 183] Cannot create a file when that file already exists
# so either do a prior clean-up, or add a unique code and schedule a cleanup batch

        returntype = 2

        if returntype==1: # OK: local file
           self.Output1 = self.addLiteralOutput(identifier = "pngname",
                                                title      = "local path of the temporary png file created",
                                                type       = type("url"), # that's a string
                                                default    = "file.png")
        elif returntype==2: # OK: mime, unless file already exist: error [183]
           self.Output1 = self.addComplexOutput(identifier  = "pngname",
                                                title       = "mime png file created",
                                                formats     = [{"mimeType":"image/png"}])
        elif returntype==3: ## Does not work yet: crash
           self.Output1 = self.addComplexOutput(identifier  = "pngname",
                                                title       = "url of png file created",
                                                asReference = True,
                                                formats     = [{"mimeType":None}])

        self.Output2 = self.addLiteralOutput(identifier  = "urlmapname",
                                             title       = "url of png file created",
                                             type       = type("url"), # that's a string
                                             default    = "")

    def execute(self):
    
        # logging.info("cdi_plot_timeseries: tempPath: " + tempPath)
        # logging.info("cdi_plot_timeseries: dataPath: " + dataPath)
        # logging.info(self.EDMO_code.getValue() + ':' + self.filename.getValue())

        if dataPath[0:13]=='postgresql://':
        
            ODV = pyodv.odv2orm_query.orm_from_cdi(dataPath,
                                                   self.parameter.getValue(),
                                                   self.EDMO_code.getValue(), self.LOCAL_CDI_ID.getValue())
                                                   
            logging.info("cdi_plot_timeseries: ODV read from PostgreSQL with n=" + str(len(ODV.data)))
            
            if len(ODV.data)==0:
                return 'no data found'
            	
            # zname = '' # not implemented yet for ORM
            zname = self.z.getValue()
            
        else:

            url = os.path.join(dataPath,self.EDMO_code.getValue(),self.filename.getValue()  + '.txt')
            
            ODV       = pyodv.pyodv.Odv.fromfile(url)
            logging.info("cdi_plot_timeseries: ODV read from file")

# PNG: (clean-up if needed)

        tempname_png = os.path.join(tempPath,self.EDMO_code.getValue() + '_' +
                                            self.filename.getValue()  + '_' +
                                            self.parameter.getValue() + '_timeseries.png')
                                            
        if os.path.isfile(tempname_png):
           os.remove     (tempname_png)
        if os.path.isfile(tempname_png + ".binary"):
           os.remove     (tempname_png + ".binary")
           logging.info("trying to remove " + tempname_png)
        if os.path.isfile(tempname_png):
           logging.info("failed to remove " + tempname_png)
        
        clims   = [self.clim0.getValue(),self.clim1.getValue()]
        times   = [self.starttime.getValue(),self.endtime.getValue()]
        zlims   = [self.zlim0.getValue(),self.zlim1.getValue()]
        
        cmapstr         = self.colormap.getValue()
        colorvalue      = self.color.getValue()
        markertype      = self.marker.getValue()
        markersizevalue = self.markersize.getValue()
        alphavalue      = self.alpha.getValue()

        pyodv.odv2timeseries(tempname_png,ODV,self.parameter.getValue(),clims,zlims,times,cmapstr,self.log10.getValue(),zname,colorvalue,markertype,markersizevalue,alphavalue)
        
        logging.info("PNG written")
        self.Output1.setValue(tempname_png) # if Output1 is WPS addComplexOutput(...,asReference=False), this file will actually be written, mapped to mime and inserted into xml
        self.Output2.setValue(tempname_png + '.binary')
        
# Cleanup temp files: do not clean-up here, pyWPS packages them as MIME only <after> return

        return

