# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
#       Gerrit Hendriksen, Joan Sala
#
#       gerrit.hendriksen@deltares.nl, joan.salacalero@deltares.nl
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

# $Id: info_nhiflux.py 13706 2017-09-13 09:29:46Z sala $
# $Date: 2017-09-13 11:29:46 +0200 (Wed, 13 Sep 2017) $
# $Author: sala $
# $Revision: 13706 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/blue2/getmmftseries.py $
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

# Relative
from coords import *
from utils import *
from utils_netcdf import *
from bokeh_plots import *

"""
This is a redesigned WPS for the Blue2 application

if it runs on localhost then:
getcapabilities:  http://localhost/cgi-bin/pywps.cgi?request=GetCapabilities&service=wps&version=1.0.0
describe process: http://localhost/cgi-bin/pywps.cgi?request=DescribeProcess&service=wps&version=1.0.0&identifier=info_nhiflux
execute:          http://localhost/cgi-bin/pywps.cgi?&service=wps&request=Execute&version=1.0.0&identifier=info_nhiflux&datainputs=[geom={%20%22type%22:%20%22FeatureCollection%22,%20%22features%22:%20[%20{%20%22type%22:%20%22Feature%22,%20%22properties%22:%20{},%20%22geometry%22:%20{%20%22type%22:%20%22Point%22,%20%22coordinates%22:%20[%204.3689751625061035,%2052.01105825338195%20]%20}%20}%20]%20}]
"""

class Process(WPSProcess):
    
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="getmmftseries",
                            title="MMF model time-series plot",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Get all the time-series information, providing a location inside the model output [yellow bounds] and a variable name""",
                            grassLocation=False)

        # Pre-load
        fname = r"D:\NETCDF_DATA\MMF\medsea_5x5_fabm_1989_04.3d.nc"
        variables = getAllVariableNameswithTime(fname)  
        self.varnames = self.addLiteralInput(
                    identifier="layertitle",
                    title="Select mmf variable name",
                    abstract="input=dropdownmenu",
                    type=type(""),
                    allowedValues=variables,
                    default=variables[0])    

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
            (lon,lat) = change_coords(xin, yin, epsgin=epsgin, epsgout='epsg:4326')
            logging.info('''Input Coordinates, latlon= {}, {}'''.format(lat,lon))  
        except:
            return False, '''<p>Please select a location first with the 'Select on map' button</p>''', -1, -1, -1, -1
 
        # Parameters check OK 
        return True, '', xin, yin, lon, lat

    def execute(self):
        # Outputs prepare
        outdata = StringIO.StringIO()
        values = {}

        # Read config
        PLOTS_DIR, APACHE_DIR, GEOSERVER_URL = readConfig()

        # Inputs check
        location = self.location.getValue() 
        varname = self.varnames.getValue()    
        logging.info('''INPUT [getmmftseries]: location={}'''.format(str(self.location.getValue)))

        # Error messaging
        okparams, msg, x, y, lon, lat = self.check_inputs(location)
        if not(okparams):            
            logging.info(msg)            
            values['error_html'] = msg
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return

        # Get time-series data        
        fname = r"D:\NETCDF_DATA\MMF\medsea_5x5_fabm_1989_04.3d.nc"
        varinfo = getAllVariables(fname)
        try:
            data = getTseriesLatLonV(lat, lon, varname, fname)
        except:
            msg = 'Error: no data found for the current selection [location, variable]'
            logging.info(msg)            
            values['error_html'] = msg
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return

        time = getTimeSteps(fname)
        logging.info('''OUTPUT [getmmftimeseries]: {}'''.format(data))

        # Generate plot GW vs time        
        tmpfile = TempFile(PLOTS_DIR)
        bokeh=bokeh_Plot(data, time, tmpfile, varname, varinfo[varname].units)
        bokeh.plot_Tseries()

        # Send back result JSON
        values['url_plot'] = APACHE_DIR + os.path.basename(tmpfile)
        values['plot_xsize'] = 800
        values['plot_ysize'] = 400
        values['title'] = 'MMF time-series'        
        json_str = json.dumps(values)        
        outdata.write(json_str)
        self.json.setValue(outdata)      
    

        return
