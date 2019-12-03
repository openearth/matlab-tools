# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares
#       Joan Sala
#
#       joan.salacalero@deltares.nl
#
#   This library is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this library.  If not, see <http://www.gnu.org/licenses/>.
#   --------------------------------------------------------------------
#
# This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
# OpenEarthTools is an online collaboration to share and manage data and
# programming tools in an open source, version controlled environment.
# Sign up to recieve regular updates of this function, and to contribute
# your own tools.

# $Id: geomodelTransectSimple.py 14127 2018-01-30 07:21:10Z hendrik_gt $
# $Date: 2018-01-29 23:21:10 -0800 (Mon, 29 Jan 2018) $
# $Author: hendrik_gt $
# $Revision: 14127 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/emisk/geomodelTransectSimple.py $
# $Keywords: $

# core
import os
import operator
import math
import tempfile
import logging
import ConfigParser
import time

# modules
import types
import simplejson as json
import StringIO
from pywps.Process import WPSProcess
from geojson import LineString, Feature, FeatureCollection

# Self libraries
from emisk_utils import *
from emisk_sql import *
from bokeh_plots import *
from lineSlice import lineSlice

"""
This is a redesigned WPS for the emisk application
"""

class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="geomodeltransectsimple",
                            title="GeoModel Transect",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Plot-XY of a transect in the GeoModel data. Please select two points within the limits of the available geomodel layers.""",
                            grassLocation=False)

        self.loc0 = self.addLiteralInput(identifier="loc0",
                                              title="Please select a start location for the transect",
                                              abstract="input=mapselection",
                                              type=type(""),
                                              uoms=["point"])

        self.loc1 = self.addLiteralInput(identifier="loc1",
                                              title="Please select an end location for the transect",
                                              abstract="input=mapselection",
                                              type=type(""),
                                              uoms=["point"])

        self.json = self.addComplexOutput(identifier="json",
                                          title="Returns list of values for specified xy",
                                          abstract="""Returns list of values for specified xy""",
                                          formats=[{"mimeType": "text/plain"},  # 1st is default
                                                   {'mimeType': "application/json"}]) 

    def execute(self):
        # Outputs prepare
        outdata = StringIO.StringIO()
        values = {}

        # Read config
        PLOTS_DIR, APACHE_DIR, GEOSERVER_URL, SQLSERVER_DB, SQLSERVER_HOST, SQLSERVER_USER, SQLSERVER_PASS = readConfig()

        # Inputs check
        location_st = self.loc0.getValue()
        location_end = self.loc1.getValue()
        logging.info('''INPUT [geomodeltransect]: location_st={}'''.format(str(location_st)))      
        logging.info('''INPUT [geomodeltransect]: location_end={}'''.format(str(location_end)))      

        # Error messaging
        okparams_st, msg, x_st, y_st = check_location(location_st)
        okparams_end, msg, x_end, y_end = check_location(location_end)
        if not(okparams_st) or not(okparams_end):            
            logging.info(msg)            
            values['error_html'] = msg
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return

        # Create geometry   
        f = Feature(geometry=LineString([(x_st, y_st), (x_end, y_end)]))
        fc = FeatureCollection([f])        
        ls=lineSlice(fc, [], 100)
        logging.info('''INPUT [geomodeltransect]: location={}'''.format(str(location_st)))
        logging.info('''INPUT [geomodeltransect]: location={}'''.format(str(location_end)))
                
        # Layers to intersect [pre-defined]
        layersgeomodel = ['Geological_Model:DEM90_0_utm38n', 
                          'Geological_Model:KGdry_1_utm38n', 
                          'Geological_Model:UKG_2_utm38n', 
                          'Geological_Model:LKG_3_utm38n', 
                          'Geological_Model:DM3_4_utm38n',
                          'Geological_Model:DM2_5_utm38n']

        # Get values for selected xy in fixed epsg
        epsgout = 'epsg:32638'
        epsgin = 'epsg:3857'
        wcs_totals = []
                
        for xin,yin in ls.coordsfinal: 
            # Point
            (xk,yk) = change_coords(xin, yin, epsgin=epsgin, epsgout=epsgout)
            wcs_vals = []        
            for l in layersgeomodel:            
                d = getPointfromWCS(l, xk, yk)
                if d != None:
                    d=d[0] # single point
                    wcs_vals.append(d)                    
            # Collect point of transect
            wcs_totals.append(wcs_vals)          

        # Generate plot borehole       
        if wcs_totals != []:
            # Prepare plot
            dist = math.sqrt((x_st - x_end)*(x_st - x_end) + (y_st - y_end)*(y_st - y_end))
            tmpfile = emiskTempFile(PLOTS_DIR)
            bokeh=bokeh_Plot(wcs_totals, {'x':'Transect', 'y':'Transect', 'locationke':'Selected by user'}, tmpfile, distance=dist)
            bokeh.plot_Transect()

            # Send back result JSON     
            values['url_plot'] = APACHE_DIR + os.path.basename(tmpfile)
            json_str = json.dumps(values)
            logging.info('''OUTPUT [geomodeltransect]: {}'''.format(json_str))
            outdata.write(json_str)
            self.json.setValue(outdata)    
        else:
            msg = 'No data available for the selected location'
            logging.info(msg)            
            values['error_html'] = msg
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)

        return