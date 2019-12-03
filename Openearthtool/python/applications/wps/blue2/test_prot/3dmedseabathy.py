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

# $Id: 3dmedseabathy.py 14134 2018-01-31 07:01:10Z sala $
# $Date: 2018-01-31 08:01:10 +0100 (Wed, 31 Jan 2018) $
# $Author: sala $
# $Revision: 14134 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/emisk/3dmedseabathy.py $
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

# Local imports
from coords import *
from utils_wcs import *

"""
This is a redesigned WPS for the emisk application
"""

class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="3dmedseabathy",
                            title="MMF model bathymetry",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Select a bounding box and click Execute to get an interactive bathymetry plot of the MMF model data""",
                            grassLocation=False)

        self.location = self.addLiteralInput(identifier="loc",
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

        # Inputs check
        location = self.location.getValue()     
        GEOSERVER_URL = 'http://localhost:8080/geoserver/ows'
        layer = 'BLUE2_DATA_MMF:bathymetry_merged' 
        logging.info('''INPUT [3dmedseabathy]: layer={}, location={}'''.format(layer, str(location)))

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
        epsgout = 'epsg:4326'
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
        resx = 1
        resy = 1
        zarray = np.negative(np.asarray(data)).astype(int).tolist() # int list for performance on the response size
        

        # Send back result JSON        
        values['title'] = '3D medsea bathymetry plot'
        
        # 3d values for VisJs [fixed resolution of 100meters]
        if (nx*ny < 25000):
            values['z'] = zarray
            values['xstep'] = resx
            values['ystep'] = resy
            values['nx'] = nx
            values['ny'] = ny
            values['legendlabel'] = 'Height [m]'
        else:
            values['error_html'] = 'Too many values selected. Please narrow down your bounding box'

        json_str = json.dumps(values)
        outdata.write(json_str)
        self.json.setValue(outdata)       

        return

