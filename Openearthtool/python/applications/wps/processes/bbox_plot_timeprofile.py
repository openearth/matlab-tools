# bbox_plot_timeprofile: returns a timeseries plot of profiles from a remote ODV file as png
# https://publicwiki.deltares.nl/display/OET/pyWPSodv

# This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
# OpenEarthTools is an online collaboration to share and manage data and 
# programming tools in an open source, version controlled environment.
# Sign up to recieve regular updates of this function, and to contribute 
# your own tools.

# $Id$
# $Date$
# $Author$
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
import pyodv as pyodv

tempPath = config.getConfigValue("server","tempPath") # default.cfg in pywps_processes
dataPath = config.getConfigValue("server","dataPath") # default.cfg in pywps_processes

class odvProcess(WPSProcess):
    def __init__(self):
        WPSProcess.__init__(self,
                            identifier="bbox_plot_timeprofile", # must be same, as filename
                            title="OceanDataView web processing service: cdi_get_metadata > odv_get_parameters > [bbox_plot_map, bbox_plot_profile, bbox_plot_timeseries, bbox_plot_timeprofile]",
                            version="$Id$",
                            storeSupported=True,
                            statusSupported=True,
                            abstract="returns a timeseries plot of profiles from a bounding box as png",
                            grassLocation=False)
        
        self.bbox      = self.addBBoxInput(identifier = "bbox",
                                           title      = "bounding box [minx, maxx, miny, maxy]")
        self.parameter = self.addLiteralInput(identifier =  "parameter", # does not accept the backslash (\), but slash(/)
                                           title      = "ODV column name, html encoding of special characters may be used but not required (e.g. replacing space with by %20)",
                                           type       = type("salinity[psu]"),
                                           default    = "WSALIN_[PSU]")
        self.clim0     = self.addLiteralInput(identifier = "clim0",
                                           title      = "lower y-axis limit for plot, skip keyword for autoscale",
                                           type       = type(0.0),
                                           default    = float(np.finfo('single').min)) # realmin, does not accept [] as default for type(0.0)
        self.clim1     = self.addLiteralInput(identifier = "clim1",
                                           title      = "upper y-axis limit for plot, skip keyword for autoscale",
                                           type       = type(100.0),
                                           default    = float(np.finfo('single').max)) # realmax, does not accept [] as default for type(0.0)
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
        self.allinrange  = self.addLiteralInput(identifier = "allinrange",
                                           title      = "allinrange option to limit data visualization to colorbar range",
                                           type       = type(10),
                                           default    = 1)
                                           
# Crashes when creating same file twice:
# Process executed. Failed to build final response for output [identifier]: [Error 183] Cannot create a file when that file already exists
# so either do a prior clean-up, or add a unique code and schedule a cleanup batch

# choose between different mimeType by padding to url (outside DataInputs=[]): &responsedocument=mapname=@mimetype=application/vnd.google-earth.kmz
        
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
                                             
        self.Output3 = self.addComplexOutput(identifier  = "cdiname",
                                             title       = "list of cdi's created",
                                             formats    = [{"mimeType":"text/json"}, # 1st is default
                                                           {'mimeType':"text/html"}])

    def execute(self):
    
        # logging.info("bbox_plot_timeseries: tempPath: " + tempPath)
        # logging.info("bbox_plot_timeseries: dataPath: " + dataPath)

        if dataPath[0:13]=='postgresql://':
        
            bbox = self.bbox.getValue()
            
            W = bbox.coords[0][0] # minx
            S = bbox.coords[0][1] # miny, mind order
            E = bbox.coords[1][0] # maxx, mind order
            N = bbox.coords[1][1] # maxy
            
            logging.info('bbox: W:'+str(W)+' E:'+str(E)+' S:'+str(S)+' N:'+str(N))
            
            ODV = pyodv.odv2orm_query.orm_from_bbox(dataPath,self.parameter.getValue(),W,E,S,N,self.z.getValue()) # z is required now
                        
            # Check if it is a contaminant
            iscont = len(pyodv.odv2orm_query.is_contaminant(dataPath, self.parameter.getValue())) # 0 or 1

            # exclude mytilus
            #logging.info('parameter is '+self.parameter.getValue())
            mytilist = ["EPC00140","EPC00219","EPC00192","EPC00184","EPC00205","EPC00165",
                        "EPC00137","EPC00169","EPC00143","EPC00191","EPC00229","EPC00228",
                        "EPC00203","EPC00182","EPC00161","EPC00202","EPC00149","EPC00204",
                        "EPC00215","EPC00188","EPC00155","EPC00189","EPC00230","EPC00207",
                        "EPC00176"]
                        
            
            if len(ODV.data)==0 or self.parameter.getValue() in mytilist: # in case the query returns empty result or it is mytilus
                import matplotlib.pyplot as plt
                temp = os.path.join(tempPath,'temp.png')
                tempNoData = os.path.join(tempPath,'NoData.json')
                if os.path.isfile(temp):
                    os.remove(temp)
                if os.path.isfile(temp + ".binary"):
                    os.remove(temp + ".binary")
                
                fig = plt.figure()
                fig.savefig(temp)
                f = open(tempNoData, 'wb')
                f.write("<![CDATA["+ '[]' +"]]>")
                f.close()
                
                self.Output1.setValue(temp)
                self.Output2.setValue(temp+'.binary')
                self.Output3.setValue(tempNoData)
                return
            
            logging.info("bbox_plot_timeprofile: ODV read from PostgreSQL with n=" + str(len(ODV.data)))
            
            # zname = '' # not implemented yet for ORM
            zname = self.z.getValue()
            	
        else:

            return "ERROR odv file backend has no bbox request implemented"

# PNG: (clean-up if needed)

        tempname_png = os.path.join(tempPath,str(W) + '_' + str(E) + '_' + str(S) +'_' + str(N) + '_' +
                                             self.parameter.getValue() + '_timeprofile.png')
                                            
        
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
        
        allinrange      = self.allinrange.getValue()
        
        if allinrange == 0:
            edmocdi = pyodv.odv2edmocdi(ODV,self.parameter.getValue(),zname,clims,zlims,times,plot_type='timeprofile') # arg plot_type sucks a bit but no time now.
            pyodv.odv2timeprofile(tempname_png,ODV,self.parameter.getValue(),zname,clims,zlims,times,cmapstr,self.log10.getValue(),colorvalue,markertype,markersizevalue,alphavalue)
        else:
            edmocdi = pyodv.odv2edmocdi_allinrange(ODV,self.parameter.getValue(),zname,clims,zlims,times,plot_type='timeprofile') # arg plot_type sucks a bit but no time now.
            pyodv.odv2timeprofile_allinrange(tempname_png,ODV,self.parameter.getValue(),zname,clims,zlims,times,cmapstr,self.log10.getValue(),colorvalue,markertype,markersizevalue,alphavalue)
        
        tempname = os.path.join(tempPath,str(W) + '_' + str(E) + '_' + str(S) +'_' + str(N) + '_profile_edmocdi.json')
        df_json = "<![CDATA["+ edmocdi +"]]>"
        f = open(tempname, 'wb')
        f.write(df_json)
        f.close()  
        
        logging.info("PNG written")
        self.Output1.setValue(tempname_png) # if Output1 is WPS addComplexOutput(...,asReference=False), this file will actually be written, mapped to mime and inserted into xml
        self.Output2.setValue(tempname_png + '.binary')
        self.Output3.setValue(tempname)
        
        ## request for piwik [matomo] count. See https://developer.matomo.org/api-reference/tracking-api
        import requests
        logging.info(self.identifier)
        idsite = 23
        rec = 1
        action_name = self.identifier
        e_c = 'timeprofile' # event category
        e_a = 'show' # event action
        e_n = self.parameter.getValue() # event name
        e_v = 1 # event value
        rurl = 'http://piwik.vliz.be/piwik.php?idsite={}&rec={}&action_name={}&e_c={}&e_a={}&e_n={}&e_v={}'.format(idsite, rec, action_name, e_c, e_a, e_n.upper(), e_v)
        r = requests.get(rurl)
        #logging.info(rurl)
        #logging.info(r)

        return

