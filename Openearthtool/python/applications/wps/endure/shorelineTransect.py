# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
#      Joan Sala
#
#     joan.salacalero@deltares.nl
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

# $Id: info_regis.py 14191 2018-02-26 11:05:25Z sala $
# $Date: 2018-02-26 12:05:25 +0100 (Mon, 26 Feb 2018) $
# $Author: sala $
# $Revision: 14191 $
# $Keywords: $

# core
import os
import math
import tempfile
import logging
import time as tt
import ConfigParser

# modules
import types
import simplejson as json
import StringIO
from pywps.Process import WPSProcess
from sqlalchemy import create_engine

# relative
from utils import *
from coords import *
from bokeh_plots import bokeh_Plot

# Default config file (relative path)
CONFIG_FILE=os.path.join(os.path.dirname(os.path.realpath(__file__)), 'config.txt')

class Process(WPSProcess):

    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="shorelineTransect",
                            title="Extract information from predefined shore profiles",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Select a transect to display long-term shoreline changes [1984-2016]""",
                            grassLocation=False)

                                      
        self.location = self.addLiteralInput(identifier="location",
                                              title="Click to select a location on the coast (NL,UK,FR).",
                                              abstract="input=mapselection",
                                              type=type(""),
                                              uoms=["point"],
                                              default="Select a location on the map")
                                             
        self.json = self.addComplexOutput(identifier="json",
                                          title="Returns list of values for specified xy",
                                          abstract="""Returns list of values for specified xy""",
                                          formats=[{"mimeType": "text/plain"},  # 1st is default
                                                  {'mimeType': "application/json"}])
    def execute(self):
        # Read configuration file
        PLOTS_DIR, APACHE_DIR, ENGINE = readConfig(CONFIG_FILE)

        # Output prepare
        json_output = StringIO.StringIO()
        values = {}
        data_error = False
        
        try:
            # Input (coordinates) - OpenLayers 3857
            epsg = 3857
            epsgin = 'epsg:'+str(epsg)
            location_info = json.loads(self.location.getValue())
            (xin,yin) = location_info['x'], location_info['y']
                
            # convert coordinates to latlon
            logging.info('''Input Coordinates {} {} in epsg={}'''.format(xin,yin,epsgin))             
            (lon,lat) = change_coords(xin, yin, epsgin=epsgin, epsgout='epsg:4326')
              
            # Query DB, get transect, make plot
            # Select transect [closest]
            fields = 'transect_id, initial_lon, final_lon, initial_lat, final_lat, distance, change_rate, change_rate_unc, outliers, flag_sandy, country, intercept, time, b_unc'
            table = 'endure_transects_interreg'    
            where = None
            transect_id, lon1, lon2, lat1, lat2, distance, change_rate, change_rate_unc, outliers, flag_sandy, country, intercept, time, b_unc, distclick = queryPostGISClosestPoint(ENGINE, lon, lat, fields, table, where)
            logging.info('INFO: selected transect with id={}'.format(transect_id))
            dirname = str(tt.time()).replace('.','')
            temp_html = os.path.join(PLOTS_DIR, dirname+'.html')   

            # Plot
            p = bokeh_Plot(temp_html)
            p.generate_plot(transect_id, distance, change_rate, change_rate_unc, outliers, flag_sandy, country, intercept, time, b_unc)

        except Exception, e:
            data_error = True
            logging.info(e)    
            pass
   
        # Output prepare
        if data_error:
            values['error_html'] = "<p>No transect found near the selected location. Please click on the Select on map button.</p>"
        else:
            values['title'] = """Shoreline transect with id={}""".format(transect_id)         
            values['url_plot'] = APACHE_DIR + dirname +'.html'
            values['title'] = 'Shoreline transect plot'
            values['plot_xsize'] = 650
            values['plot_ysize'] = 370            
            values['wkt_linestr'] = 'LINESTRING ({x0} {y0}, {x1} {y1})'.format(x0=lon1, x1=lon2, y0=lat1, y1=lat2)

        # Output finalize        
        json_str = json.dumps(values, use_decimal=True)
        logging.info('''OUTPUT [info_regis]: {}'''.format(json_str))
        json_output.write(json_str)
        self.json.setValue(json_output)

        return