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

# $Id: 3dlayers.py 14132 2018-01-30 19:06:23Z sala $
# $Date: 2018-01-30 11:06:23 -0800 (Tue, 30 Jan 2018) $
# $Author: sala $
# $Revision: 14132 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/emisk/3dlayers.py $
# $Keywords: $

# core
import os
import operator
import math
import tempfile
import logging
import ConfigParser
import time
import shapely

# modules
import types
import simplejson as json
import StringIO
from pywps.Process import WPSProcess

# Self libraries
from emisk_utils import *
from emisk_sql import *
from matplotlib_plots import *
import emisk_geology as eg

"""
This is a redesigned WPS for the emisk application
"""

class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="3dlayers",
                            title="3D Geological model [multi-layer, comparison]",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Select a bounding box, 1 or all layers and click Execute to get the available data for the location. The result is a 3D representation (non interactive) of the chosen layers.""",
                            grassLocation=False)

        self.location = self.addLiteralInput(identifier="location",
                                              title="Click here to start drawing. Get results by clicking on Execute",
                                              abstract="input=bbox",
                                              type=type(""),
                                              uoms=["Bbox"])

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
        location = self.location.getValue()     
        logging.info('''INPUT [3dlayers]: location={}'''.format(str(location)))

        # Check bbox
        try:
            geom = shapely.wkt.loads(location)
        except:
            msg = 'Did not provide a location in wkt format [Polygon]'
            logging.info(msg)            
            values['error_html'] = msg
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return

        # Bounds in UTM coord system
        (minx, miny, maxx, maxy) = geom.bounds
        epsgout = 'epsg:32638'
        epsgin = 'epsg:3857'
        (xmink, ymink) = change_coords(minx, miny, epsgin=epsgin, epsgout=epsgout)
        (xmaxk, ymaxk) = change_coords(maxx, maxy, epsgin=epsgin, epsgout=epsgout)

        # WCS query to get selected layer or for ALL layers
        data_layers={}
        incomplete = False
    	for l in eg.orderedtitles:
    		data=getDatafromWCS(GEOSERVER_URL, l, xmink, ymink, xmaxk, ymaxk, all_box=True)	        
	        if data is None or data.min() < -9999:
	        	incomplete = True
	        	continue
	        else: # no-nonsense
	        	data_layers[l]=data
               
        # Generate PNG plot file        
        if not(incomplete):
            tmpfile = emiskTempFile(PLOTS_DIR, typen='3D_Borehole', extension='.png')
            plot=matplotlib_Plot(data_layers, '3D Borehole interpolated plot', tmpfile)
            nx, ny, zarray = plot.plot_3dsurface()
        else:
            msg = 'No data for the selected bounding box. Please draw inside the available area.'
            logging.info(msg)            
            values['error_html'] = msg
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return

        # Send back result JSON        
        values['url_png'] = APACHE_DIR + os.path.basename(tmpfile)
        values['plot_xsize'] = 850
        values['plot_ysize'] = 600
        values['title'] = '3D Borehole layers comparison'

        json_str = json.dumps(values)
        outdata.write(json_str)
        self.json.setValue(outdata)       

        return

