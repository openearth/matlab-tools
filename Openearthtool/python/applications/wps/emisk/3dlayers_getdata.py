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

# $Id: 3dlayers_getdata.py 14129 2018-01-30 08:13:05Z sala $
# $Date: 2018-01-30 00:13:05 -0800 (Tue, 30 Jan 2018) $
# $Author: sala $
# $Revision: 14129 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/emisk/3dlayers_getdata.py $
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

# Geology legends
import emisk_geology as eg

"""
This is a redesigned WPS for the emisk application
"""

class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="3dlayers_getdata",
                            title="3D Geological model [single-layer, interactive]",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Select a bounding box, layer and click Execute to get an interactive plot of the subsurface interpolated data. The result is a 3D interactive representation of the chosen layer.""",
                            grassLocation=False)

        self.layertitle = self.addLiteralInput(
                    identifier="layertitle",
                    title="Select information source",
                    abstract="input=dropdownmenu",
                    type=type(""),
                    allowedValues=eg.orderednames,
                    default=eg.orderednames[0])

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
        layertitle = self.layertitle.getValue() 
        layer = eg.titlescheme_inv[layertitle]
        logging.info('''INPUT [3dlayers_getdata]: layer={}, location={}'''.format(layertitle, str(location)))

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

        # Layer to intersect [pre-defined]
        data=getDatafromWCS(GEOSERVER_URL, layer, xmink, ymink, xmaxk, ymaxk, all_box=True)
    
        if data is None:
            msg = 'No data for the selected bounding box. Please draw inside the available area.'
            logging.info(msg)            
            values['error_html'] = msg
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return

        nx = data.shape[0]
        ny = data.shape[1]
        resx = 100
        resy = 100
        zarray = np.asarray(data).astype(int).tolist() # int list for performance on the response size

        # Send back result JSON        
        values['title'] = '3D interactive Borehole'
        
        # 3d values for VisJs [fixed resolution of 100meters]
        if (nx*ny < 5000):
            values['z'] = zarray
            values['xstep'] = resx
            values['ystep'] = resy
            values['nx'] = nx
            values['ny'] = ny
        else:
            values['error_html'] = 'Too many values selected. Please narrow down your bounding box'

        json_str = json.dumps(values)
        outdata.write(json_str)
        self.json.setValue(outdata)       

        return

