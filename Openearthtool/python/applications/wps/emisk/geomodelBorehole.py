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

# $Id: geomodelBorehole.py 14128 2018-01-30 07:30:36Z sala $
# $Date: 2018-01-29 23:30:36 -0800 (Mon, 29 Jan 2018) $
# $Author: sala $
# $Revision: 14128 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/emisk/geomodelBorehole.py $
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
import emisk_geology as eg

"""
This is a redesigned WPS for the emisk application
"""
class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="geomodelborehole",
                            title="Geological model - Borehole",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Plot of a virtual borehole in the interpreted geological layers. Select a location within the limits of the geomodel a virtual borehole will be presented in a graph.""",
                            grassLocation=False)
                
        self.location = self.addLiteralInput(identifier="location",
                                              title="Please select a location and click Execute",
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
        location = self.location.getValue()     
        logging.info('''INPUT [geomodelborehole]: location={}'''.format(str(location)))

        # Error messaging
        okparams, msg, x, y = check_location(location)
        if not(okparams):            
            logging.info(msg)            
            values['error_html'] = msg
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return

        # Get values for selected xy in fixed epsg
        epsgout = 'epsg:32638'
        epsgin = 'epsg:3857'
        (xk,yk) = change_coords(x, y, epsgin=epsgin, epsgout=epsgout)
        wcsvals = []        
        for l in eg.orderedtitles:            
            d=getDatafromWCS(GEOSERVER_URL, l, xk, yk, xk, yk)
            if d != None:
                d=d[0] # single point
                wcsvals.append(d)
                logging.info('Query layer={} with coordinates=({}, {}) and crs={} ==> value={}'.format(l,int(xk),int(yk),epsgout,d))            

        # Generate plot borehole       
        if wcsvals != []:
            tmpfile = emiskTempFile(PLOTS_DIR)
            bokeh=bokeh_Plot(wcsvals, {'x':x, 'y':y, 'locationke':'Selected by user'}, tmpfile)
            bokeh.plot_Borehole(eg.orderedtitles)

            # Send back result JSON     
            values['url_plot'] = APACHE_DIR + os.path.basename(tmpfile)
            values['plot_xsize'] = 500
            values['plot_ysize'] = 550
            values['title'] = 'GeoModel Borehole'
            json_str = json.dumps(values)
            logging.info('''OUTPUT [geomodelborehole]: {}'''.format(json_str))
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
