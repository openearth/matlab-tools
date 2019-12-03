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

# $Id: sptvsdepth.py 14128 2018-01-30 07:30:36Z sala $
# $Date: 2018-01-29 23:30:36 -0800 (Mon, 29 Jan 2018) $
# $Author: sala $
# $Revision: 14128 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/emisk/sptvsdepth.py $
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

# Self libraries
from emisk_utils import *
from emisk_sql import *
from bokeh_plots import *

"""
This is a redesigned WPS for the emisk application
"""

class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="sptvsdepth",
                            title="Standard Penetration Test vs Depth",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Plot SPT versus Depth for available locations. Select a location and the closest available location will be selected.""",
                            grassLocation=False)
                
        self.location = self.addLiteralInput(identifier="locdepth",
                                              title="Please select a location and click Execute",
                                              abstract="input=mapselection",
                                              type=type(""),
                                              uoms=["point"]
                                              )

        self.json = self.addComplexOutput(identifier="json",
                                          title="Returns list of values for specified xy",
                                          abstract="""Returns list of values for specified xy""",
                                          formats=[{"mimeType": "text/plain"},  # 1st is default
                                                   {'mimeType': "application/json"}]) 

    # Parameters check
    def check_inputs(self, location, epsgin='epsg:3857'):        
        # Valid JSON
        try:
            # Input (coordinates)  
            location_info = json.loads(location)            
            (xin,yin) = location_info['x'], location_info['y']
            (x,y) = change_coords(xin, yin, epsgin=epsgin, epsgout='epsg:4326')
            logging.info('''Input Coordinates {} {}'''.format(xin,yin))  
        except:
            return False, '''<p>Please select a location first with the 'Select on map' button</p>''', -1, -1
        
        # Check inside Europe
        if not inside_kuwait(x,y):
            return False, '''<p>Please select a location inside the Kuwait borders</p>''', -1, -1

        # Parameters check OK 
        return True, '', x, y

    def execute(self):
        # Outputs prepare
        outdata = StringIO.StringIO()
        values = {}

        # Read config
        PLOTS_DIR, APACHE_DIR, GEOSERVER_URL, SQLSERVER_DB, SQLSERVER_HOST, SQLSERVER_USER, SQLSERVER_PASS = readConfig()

        # Inputs check
        location = self.location.getValue()     
        logging.info('''INPUT [sptvsdepth]: location={}'''.format(str(location)))

        # Error messaging
        okparams, msg, x, y = check_location(location)
        if not(okparams):            
            logging.info(msg)            
            values['error_html'] = msg
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return

        # Check if well nearby via WFS
        layerWFS = 'Emisk_Locations:Locationkeys_SPT_values'
        (xk,yk) = change_coords(x, y, epsgin='epsg:3857', epsgout='epsg:32638')
        (properties, dist) = closestFeatureWFS(GEOSERVER_URL, layerWFS, xk, yk)
        if properties == None:      
            errmsg = 'Please select another location, there is no data nearby.'
            logging.info(errmsg)            
            values['error_html'] = errmsg
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return

        # Query Database by location
        res=sql_sptvalues_vs_depth(SQLSERVER_DB, SQLSERVER_HOST, SQLSERVER_USER, SQLSERVER_PASS, properties['locationke'])

        # Generate plot GW vs time        
        tmpfile = emiskTempFile(PLOTS_DIR)
        bokeh=bokeh_Plot(res, properties, tmpfile)
        bokeh.plot_SPT()

        # Send back result JSON
        (xzoom,yzoom) = change_coords(properties['x'], properties['y'], epsgin='epsg:32638', epsgout='epsg:3857')
        values['url_plot'] = APACHE_DIR + os.path.basename(tmpfile)
        values['plot_xsize'] = 450
        values['plot_ysize'] = 650
        values['title'] = 'SPT vs Depth'
        values['zoomx'] = xzoom
        values['zoomy'] = yzoom
        values['dist'] = dist
        json_str = json.dumps(values)
        logging.info('''OUTPUT [sptvsdepth]: {}'''.format(json_str))
        outdata.write(json_str)
        self.json.setValue(outdata)          

        return
