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

# $Id: kust_3dplot.py 14134 2018-01-31 07:01:10Z sala $
# $Date: 2018-01-31 08:01:10 +0100 (Wed, 31 Jan 2018) $
# $Author: sala $
# $Revision: 14134 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/mepduinen/kust_3dplot.py $
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
from scipy import ndimage

# Self libraries
from utils import *

"""
This is a redesigned WPS for the mepduinen application
"""

START_YEAR = 1997
END_YEAR = 2015

class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="kust_3dplot",
                            title="Kust - 3D plot",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Selecteer een selectiekader en klik op Execute om een interactieve grafiek van de hoogtegegevens te krijgen.""",
                            grassLocation=False)

        self.location = self.addLiteralInput(identifier="location",
                                              title="Click here to start drawing. Get results by clicking on Execute",
                                              abstract="input=bbox",
                                              type=type(""),
                                              uoms=["Bbox"])

        self.year = self.addLiteralInput(
                    identifier="year",
                    title="Kies start",
                    abstract="input=dropdownmenu",
                    type=type(""),
                    allowedValues=range(START_YEAR, END_YEAR+1),
                    default=END_YEAR)        

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
        PLOTS_DIR, APACHE_DIR, GEOSERVER_URL,_,_,_,_,_ = readConfig()

        # Inputs check
        location = self.location.getValue()
        year = self.year.getValue()     
        layer = 'Kust:{}'.format(year) 
        logging.info('''INPUT [kust_3dplot]: layer={}, location={}'''.format(layer, str(location)))

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
        epsgout = 'epsg:28992'
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
        #data = ndimage.zoom(data, 0.5, order=0) # nearest neighbour [0.5 means from 5m to 20m res]
        resx = 5
        resy = 5
        zarray = np.asarray(data)
        zarray[np.logical_or(zarray<-999.0, zarray>999.0)] = 0.0 # msl
        #zarray = ndimage.zoom(zarray, 0.5, order=0) # nearest neighbour [0.5 means from 5m to 20m res]
        zarray = zarray.tolist() 

        # Send back result JSON        
        values['title'] = '3D Hoogte plot'
        
        # 3d values for VisJs [fixed resolution of 100meters]
        logging.info('3D-data size {} x {}'.format(nx,ny))
        if (nx*ny < 50000):
            values['z'] = zarray
            values['xstep'] = resx
            values['ystep'] = resy
            values['nx'] = nx
            values['ny'] = ny
            values['legendlabel'] = 'Hoogte [m-NAP]'
        else:
            values['error_html'] = 'Te veel waarden geselecteerd. Gelieve uw selectiekader te beperken'

        json_str = json.dumps(values)
        outdata.write(json_str)
        self.json.setValue(outdata)       

        return

