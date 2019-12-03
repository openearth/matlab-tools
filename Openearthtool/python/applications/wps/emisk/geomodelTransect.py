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

# $Id: geomodelTransect.py 14128 2018-01-30 07:30:36Z sala $
# $Date: 2018-01-29 23:30:36 -0800 (Mon, 29 Jan 2018) $
# $Author: sala $
# $Revision: 14128 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/emisk/geomodelTransect.py $
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
from shapely import wkt

# Self libraries
from emisk_utils import *
from emisk_sql import *
from bokeh_plots import *
from lineSlice import lineSlice
import emisk_geology as eg

"""
This is a redesigned WPS for the emisk application
"""

class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="geomodeltransect",
                            title="Geological model - Transect",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Plot of a transect in the interpreted geological model. The result is a 2D plot of a profile of the geological model layers.""",
                            grassLocation=False)

        self.transect = self.addLiteralInput(identifier="transect",
                                              title="Please draw a transect [double-click to finish] and click Execute",
                                              abstract="input=mapselection",
                                              type=type(""),
                                              uoms=["linestring"])

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
        linestr_str = self.transect.getValue()
        logging.info('''INPUT [geomodeltransect]: location={}'''.format(str(linestr_str)))      
        lwkt = wkt.loads(linestr_str)   

        if len(lwkt.coords) < 2:
            msg = 'Type must be LineString and has to have at least two points'
            logging.info(msg)            
            values['error_html'] = msg
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return            
                
        # Get values for selected xy in fixed epsg
        epsgout = 'epsg:32638'
        epsgin = 'epsg:3857'
        wcs_totals = {}
        wcs_distances = {}

        # For every layer
        err = False
        for l in eg.orderedtitles:
            # For every subline of the transect
            x0, y0 = change_coords(lwkt.coords[0][0], lwkt.coords[0][1], epsgin=epsgin, epsgout=epsgout)
            wcs_vals = []
            first = True
            total_dist = 0
            # Go line by line
            for xin,yin in lwkt.coords: 
                # First point is useless
                if first: 
                    first = False
                    continue
                # Point
                (xk,yk) = change_coords(xin, yin, epsgin=epsgin, epsgout=epsgout)
                total_dist += math.sqrt((xk-x0)*(xk-x0) + (yk-y0)*(yk-y0))

                # Retrieve and parse data
                d=getDatafromWCS(GEOSERVER_URL, l, x0, y0, xk, yk)   
                if not(d is None):
                    # concatenate values                    
                    for val in d: 
                        if not(val is None) and val > -9999.0: #no-nonsense
                            wcs_vals.append(val) 
                                                    
                # Next transect subline
                x0 = xk
                y0 = yk         

            # Add to hash results for layer l
            if len(wcs_vals):                 
                wcs_totals[l] = wcs_vals
                wcs_distances[l] = total_dist
                   
        # Generate plot borehole       
        if len(wcs_totals) or err:
            # Prepare plot            
            tmpfile = emiskTempFile(PLOTS_DIR)
            bokeh=bokeh_Plot(wcs_totals, {'x':'Transect', 'y':'Transect', 'locationke':'Selected by user'}, tmpfile)
            bokeh.plot_Transect(wcs_distances)

            # Send back result JSON     
            values['url_plot'] = APACHE_DIR + os.path.basename(tmpfile)
            values['plot_xsize'] = 700
            values['plot_ysize'] = 500
            values['title'] = 'Transect GeoModel'
            json_str = json.dumps(values)
            logging.info('''OUTPUT [geomodeltransect]: {}'''.format(json_str))
            outdata.write(json_str)
            self.json.setValue(outdata)    
        else:
            msg = 'No data for the selected bounding box. Please draw inside the available area.'
            logging.info(msg)            
            values['error_html'] = msg
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)

        return