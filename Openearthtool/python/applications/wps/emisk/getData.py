# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
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

# $Id: getData.py 14127 2018-01-30 07:21:10Z hendrik_gt $
# $Date: 2018-01-29 23:21:10 -0800 (Mon, 29 Jan 2018) $
# $Author: hendrik_gt $
# $Revision: 14127 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/emisk/getData.py $
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
from bokeh_plots import *

"""
This is a redesigned WPS for the emisk application
"""

class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="getdata",
                            title="Download data",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Select a bounding box, select data type from the dropdown box and click Execute to get the available data for the selected location.""",
                            grassLocation=False)

        self.typed = self.addLiteralInput(
                    identifier="typed",
                    title="Select information source",
                    abstract="input=dropdownmenu",
                    type=type(""),
                    allowedValues=["Groundwater levels", "Lithology information"],
                    default="Groundwater levels")

        self.location = self.addLiteralInput(identifier="location",
                                              title="Please select a location and click Execute",
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
        typed = self.typed.getValue() 
        logging.info('''INPUT [getData]: type={}, location={}'''.format(typed, str(location)))

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

        # Bounds in SQL coord system
        (minx, miny, maxx, maxy) = geom.bounds
        epsgout = 'epsg:32638'
        epsgin = 'epsg:3857'
        (xmink, ymink) = change_coords(minx, miny, epsgin=epsgin, epsgout=epsgout)
        (xmaxk, ymaxk) = change_coords(maxx, maxy, epsgin=epsgin, epsgout=epsgout)

        # Query Database by location
        if typed == "Groundwater levels":
            res, head = sql_get_groudwaterRows_bbox(SQLSERVER_DB, SQLSERVER_HOST, SQLSERVER_USER, SQLSERVER_PASS, xmink, xmaxk, ymink, ymaxk)
        else:
            res, head = sql_get_lithologyRows_bbox(SQLSERVER_DB, SQLSERVER_HOST, SQLSERVER_USER, SQLSERVER_PASS, xmink, xmaxk, ymink, ymaxk)

        # Generate CSV file        
        if len(res):
            tmpfile = emiskTempFile(PLOTS_DIR, typen=typed.replace(' ','_'), extension='.csv')
            with open(tmpfile, 'w') as f: 
                line = ';'.join(map(str, head))
                f.write(line+'\n')       
                for row in res:
                    l = [x for x in row]
                    line = ';'.join(map(str, l))
                    f.write(line+'\n')                
                f.close()
        else:
            msg = 'No data found for the selected bounding box. Please try again by clicking the drawing button'
            logging.info(msg)            
            values['error_html'] = msg
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return

        # Send back result JSON        
        values['url_data'] = APACHE_DIR + os.path.basename(tmpfile)
        json_str = json.dumps(values)
        logging.info('''OUTPUT [getData]: {}'''.format(json_str))
        outdata.write(json_str)
        self.json.setValue(outdata)       

        return

