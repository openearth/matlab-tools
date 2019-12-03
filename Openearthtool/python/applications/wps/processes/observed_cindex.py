# -*- coding: utf-8 -*-
"""
First Created on Tue Sep  22 8:25:03 2015
WPS for Aggregate count on filterobserved_cindex db layer 
Project EMODNET - Chemistry
@author: Maarten Pronk

"""
# STANDARD MODULES
from os import path, remove
import types
import string
from StringIO import StringIO
import logging

# NON STANDARD MODULES
import json
import psycopg2

from pywps import config
from pywps.Process import WPSProcess

# import pyodv as pyodv

tempPath = config.getConfigValue("server","tempPath") # default.cfg in pywps_processes
dataPath = config.getConfigValue("server","dataPath") # default.cfg in pywps_processes

class Process(WPSProcess):
    def __init__(self):
        WPSProcess.__init__(self,
            identifier = "observed_cindex", # must be same, as filename
            title="ObservedCindex",
            version = "0.1",
            storeSupported = "true",
            statusSupported = "true",
            abstract="Returns GEOJSON FC with point geometry and count.")
        self.bbox      = self.addBBoxInput(identifier = "bbox",
                                           title      = "bounding box [minx, miny, maxx, maxy]")
        # self.bbox = self.addLiteralInput(identifier = "bbox",
                                            # title = "BBOX geom wkt",
                                            # type=types.StringType,
                                            # default = 'BOX(-324.51171875 -57.34375,344.51171875 142.34375)')
        self.mindate= self.addLiteralInput(identifier="mindatetime",
                                           title="MinDateTime",
                                           type=types.StringType,
                                          default='2000-01-01T00:00:00.000Z')
        self.maxdate= self.addLiteralInput(identifier="maxdatetime",
                                           title="MaxDateTime",
                                           type=types.StringType,
                                          default='2000-12-31T00:00:00.000Z')
        self.p35 = self.addLiteralInput(identifier = "p35",
                                            title = "p35_id",
                                            type=types.StringType,
                                            default="EPC00004")
        self.minz = self.addLiteralInput(identifier = "minz",
                                            title = "minz",
                                            type=type(1.0),
                                            default=0)
        self.maxz = self.addLiteralInput(identifier = "maxz",
                                            title = "maxz",
                                            type=type(1.0),
                                            default=10)
        self.width = self.addLiteralInput(identifier = "width",
                                            title = "width",
                                            type=types.IntType,
                                            default=1000)
        self.markersize = self.addLiteralInput(identifier = "markersize",
                                           title      = "markersize from matplotlib plt.scatter s parameter",
                                           type       = type(1.0),
                                           default    = 4.0)
        self.v0 = self.addLiteralInput(identifier = "vmin",
                                           title      = "min value for matplotlib plt.scatter",
                                           type       = type(1.0),
                                           default    = 1.0)
        self.v1 = self.addLiteralInput(identifier = "vmax",
                                           title      = "max value for matplotlib plt.scatter",
                                           type       = type(1.0),
                                           default    = 10000.0) # 1e5
        # output is changed cause binary mimetype is not correct under Windows 
        self.Output1 = self.addLiteralOutput(identifier  = "image",
                                                title    = "mime png image created",
                                                type     = type("url"),
                                                default  = "")
        #self.Output2 = self.addLiteralOutput(identifier  = "colorbar",
        #                                     title       = "mime png colorbar created",
        #                                     type        = type("url"), # that's a string
        #                                     default     = "")
        self.Output3 = self.addComplexOutput(identifier  = "overlaybbox",
                                             title       = "bbox for the overlay: xmin, ymin, xmax, ymax",
                                             formats     = [{"mimeType":"text/json"}, # 1st is default
                                                             {'mimeType':"text/html"}])

                                                      
    def execute(self):
        conn = psycopg2.connect("host='postgresql.pico.cineca.it'  dbname='emodnet' user='ogs' password='ogspwd'")
        cur = conn.cursor()
        
        bbox = self.bbox.getValue()
        W = bbox.coords[0][0] # minx
        S = bbox.coords[0][1] # miny, mind order
        E = bbox.coords[1][0] # maxx, mind order
        N = bbox.coords[1][1] # maxy
        bbox_coordinate_string = """BOX({} {},{} {})""".format(W,S,E,N)

        epc=self.p35.getValue().lower()
        logging.info(epc)
        sql = """SELECT DISTINCT ST_X(geom), ST_Y(geom), COUNT(id) FROM observed_cindex_{epc}
            WHERE z BETWEEN {} AND {}
            AND lower(p35_id) = '{}'
            AND geom && ST_EXPAND('{}'::box2d,0)
            AND datetime BETWEEN '{}'::timestamp AND '{}'::timestamp
            GROUP BY ST_X(geom), ST_Y(geom)
            ORDER BY COUNT(id) ASC
            """.format(self.minz.getValue(),self.maxz.getValue(),
                epc,bbox_coordinate_string,
                self.mindate.getValue(),self.maxdate.getValue(),epc=epc
                )

        cur.execute(sql)
        data = cur.fetchall()
        
        logging.info(sql)
        
        import numpy as np
        import matplotlib.pyplot as plt
        import matplotlib.colors as colors
        import base64
        # # Most commented lines refer to colorbar generation, which is not necessary.
        # import matplotlib as mpl
        
        ms = self.markersize.getValue()
        width = self.width.getValue()
        
        pad = (ms+2) * (E-W)/ width # pad is depending on markersize
        #pad = 0. # extra degree padding on all directions to avoid to cut points
        heigth = np.floor(width/(E-W+2*pad)*(N-S+2*pad))
        DPI = 300
        
        tempname_png = path.join( tempPath, '_' + str(self.width.getValue()) + 'map.png')
        logging.info(tempname_png)
        
        ## json
        tempbox = path.join(tempPath, 'json' + '_map.json')
        jsonfile = "<![CDATA["+ str(W-pad) + ',' + str(S-pad) + ',' + str(E+pad) + ',' + str(N+pad) +"]]>"
        f = open(tempbox, 'wb')
        f.write(jsonfile)
        f.close()  
        
        self.Output3.setValue(tempbox)
        
        if not data:
            # plot empty figure
            fig, ax = plt.subplots(frameon=True)
            ax.set_aspect('equal'); ax.get_clip_box(); ax.set_position((0,0,1,1))
            fig.patch.set_visible(True)
            plt.axis((W-pad,E+pad,S-pad,N+pad))
            fig.set_size_inches(width/float(DPI),heigth/float(DPI))
            ax.axis('off');
            fig.tight_layout(); fig.subplots_adjust(top = 1, bottom = 0, right = 1, left = 0, hspace = 0, wspace = 0)
            plt.savefig(tempname_png, dpi=DPI, transparent=True, pad_inches = 0, frameon=True)
            plt.close("all")
            
            fimage    = open(tempname_png, "rb")
            fimagebin = base64.b64encode(fimage.read())
            self.Output1.setValue(fimagebin)
            
            return
        
        npdata = np.array(data)
        
        ## plot
        fig, ax = plt.subplots(frameon=True)
        ax.set_aspect('equal'); ax.get_clip_box(); ax.set_position((0,0,1,1))
        fig.patch.set_visible(True)
        # min and max depending on dataset
        # sc = ax.scatter(npdata[::,0],npdata[::,1],c=npdata[::,2], s=4, norm=mpl.colors.LogNorm(), cmap=plt.cm.jet, lw = 0)
        # min and max fixed
        sc = ax.scatter(npdata[::,0],npdata[::,1],c=npdata[::,2], s=ms, norm=colors.LogNorm(), vmin=self.v0.getValue(), vmax=self.v1.getValue(), cmap=plt.cm.jet, lw = 0)
        # cbar = plt.colorbar(sc)
        # cmap = cbar.cmap
        # vmin = cbar.get_clim()[0]; vmax = cbar.get_clim()[1]
        # norm = mpl.colors.LogNorm(vmin = vmin, vmax = vmax)
        # cbar.remove() # On the server, this crashes miserably with: Colorbar instance has no attribute 'remove' 
        # ymin, ymax = plt.ylim(); xmin, xmax = plt.xlim() 
        # # Here I follow Alex's choice to define limits based on bbox
        plt.axis((W-pad,E+pad,S-pad,N+pad)) # plt.axis((W,E,S,N))
        fig.set_size_inches(width/float(DPI),heigth/float(DPI))
        ax.axis('off');
        fig.tight_layout(); fig.subplots_adjust(top = 1, bottom = 0, right = 1, left = 0, hspace = 0, wspace = 0)
        plt.savefig(tempname_png, dpi=DPI, transparent=True, pad_inches = 0, frameon=True)
        plt.close("all")
        
        ## colorbar
        #figc = plt.figure(figsize=(2,1))
        #axc = figc.add_axes([0.1, 0.5, 0.8, 0.2])
        #cb = mpl.colorbar.ColorbarBase(axc, cmap=cmap, norm=norm, orientation='horizontal')
        #plt.savefig(path.join( tempPath, 'colorbar.png'), dpi=60, transparent=True, pad_inches = 0, frameon=True)

        logging.info("PNG written")
        
        fimage    = open(tempname_png, "rb")
        fimagebin = base64.b64encode(fimage.read())
        #fcolorbar    = open(path.join( tempPath, 'colorbar.png'), "rb")
        #fcolorbarbin = base64.b64encode(fcolorbar.read())
        
        self.Output1.setValue(fimagebin)
        
        ## request for piwik [matomo] count. See https://developer.matomo.org/api-reference/tracking-api
        import requests
        logging.info(self.identifier)
        idsite = 23
        rec = 1
        action_name = self.identifier
        e_c = 'overlaymap' # event category
        e_a = 'show' # event action
        e_n = epc # event name
        e_v = 1 # event value
        rurl = 'http://piwik.vliz.be/piwik.php?idsite={}&rec={}&action_name={}&e_c={}&e_a={}&e_n={}&e_v={}'.format(idsite, rec, action_name, e_c, e_a, e_n.upper(), e_v)
        r = requests.get(rurl)
        #logging.info(rurl)
        #logging.info(r)
        
        return
