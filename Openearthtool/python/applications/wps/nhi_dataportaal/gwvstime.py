# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
#       Joan Sala
#       joan.salacalero@deltares.nl
#       Gerrit Hendriksen
#	gerrit.hendriksen@deltares.nl
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
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/emisk/GWvsTime.py $
# $Keywords: $

"""
http://localhost/cgi-bin/pywps.cgi?service=wps&request=GetCapabilities&version=1.0.0

http://localhost/cgi-bin/pywps.cgi?service=wps&request=DescribeProcess&Identifier=gwvstime&version=1.0.0

http://localhost/cgi-bin/pywps.cgi?request=Execute&service=wps&version=1.0.0&identifier=gwvstime&datainputs=[location=(5.88251988130295,51.4379275403273)]
"""


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
from gmdb_utils import *
from gmdb_sql import *
from bokeh_plots import *

"""
This is a redesigned WPS for the emisk application
"""

class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="gwvstime",
                            title="Grondwateronttrekking tijdreeksen",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Maak een tijdreeks van grondwater onttrekkingen. Het dichtsbijzijnde punt wordt geselecteerd. Indien meerdere filters aanwezig, dan worden twee plots in 1 grafiek gemaakt.""",
                            grassLocation=False)

        self.location = self.addLiteralInput(identifier="location",
                                              title="Selecteer een locatie en klik op execute",
                                              abstract="input=mapselection",
                                              type=type(""),
                                              uoms=["point"],
                                              default="Selecteer een locatie op de kaart")

        self.sdate = self.addLiteralInput(identifier="sdate",
                                            title="Selecteer begingdatum (YYYY-MM-DD)",
                                            type=types.StringType, default='1993-01-01')

        self.edate = self.addLiteralInput(identifier="edate",
                                             title="Selecteer einddatum (YYYY-MM-DD)",
                                             type=types.StringType, default='1995-12-31')                                              

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
        PLOTS_DIR, APACHE_DIR = readConfig()
        logging.info('''Plost_dir''')

        # Inputs check
        location = self.location.getValue()     
        logging.info('''INPUT [gwvstime]: location={}'''.format(str(location)))
        startdate = self.sdate.getValue()     
        enddate = self.edate.getValue()
        logging.info('''INPUT [gwvstime]: start datum={}'''.format(startdate))
        logging.info('''INPUT [gwvstime]: eind datum={}'''.format(enddate))

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
        properties = {}
        (xk,yk) = change_coords(x, y, epsgin='epsg:3857', epsgout='epsg:28992')
        if properties == None:      
            errmsg = 'Please select another location, there is no data nearby.'    
            logging.info(errmsg)            
            values['error_html'] = errmsg
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return

        # Query Database by location
        res,properties=sql_gwlevels_vs_time(xk,yk,startdate,enddate,properties)
        if len(res):
            # Generate plot GW vs time        
            tmpfile = TempFile(PLOTS_DIR)
            logging.info(len(res))
            logging.info(tmpfile)
            logging.info(properties['x'], properties['y'])
            bokeh=bokeh_Plot(res, properties, tmpfile)
            bokeh.plot_Tseries()                  
            values['url_plot'] = APACHE_DIR + os.path.basename(tmpfile)
        else:
            values['error_html'] = 'Geen data gevonden voor de gegeven locatie'
            
        # Send back result JSON          
        json_str = json.dumps(values)
        logging.info('''OUTPUT [gwvstime]: {}'''.format(json_str))
        outdata.write(json_str)
        self.json.setValue(outdata)       

        return

