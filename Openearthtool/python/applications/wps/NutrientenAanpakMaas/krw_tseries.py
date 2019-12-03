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

# $Id: krw_tseries.py 14275 2018-04-06 06:30:55Z sala $
# $Date: 2018-04-05 23:30:55 -0700 (Thu, 05 Apr 2018) $
# $Author: sala $
# $Revision: 14275 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/NutrientenAanpakMaas/krw_tseries.py $
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
from meetlocaties_plot import *
from utils import *

"""
This is a redesigned WPS for the NutrientenAanpakMaas application
"""

class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="krw_tseries",
                            title="Toon meetreeks op locaties van de Kaderrichtlijn Water",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Deze functie maakt het mogelijk om per KRW-meetlocatie een meetreeks weer te geven van nitraat of fosfaat""",
                            grassLocation=False)

        self.location = self.addLiteralInput(identifier="location",
                                              title="Selecteer een locatie en druk op execute",
                                              abstract="input=mapselection",
                                              type=type(""),
                                              uoms=["point"])
        self.type = self.addLiteralInput(
                    identifier="type",
                    title="Kies parameter",
                    abstract="input=dropdownmenu",
                    type=type(""),
                    allowedValues=["N-totaal", "P-totaal"],
                    default="N-totaal")

        self.json = self.addComplexOutput(identifier="json",
                                          title="Returns list of values for specified xy",
                                          abstract="""Returns list of values for specified xy""",
                                          formats=[{"mimeType": "text/plain"},  # 1st is default
                                                   {'mimeType': "application/json"}]) 

    # Execute wps service to get tseries
    def execute(self):
        # Outputs prepare
        outdata = StringIO.StringIO()
        values = {}

        # Read config
        PLOTS_DIR, APACHE_DIR = readConfig()

        # Inputs check
        location = self.location.getValue()     
        param = self.type.getValue()
        logging.info('''INPUT [krw_tseries]: location={}'''.format(str(location)))

        # Error messaging
        okparams, msg, x, y = check_location(location)
        if not(okparams):            
            logging.info(msg)            
            values['error_html'] = msg
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return

        # change to epsg of database        
        (xk,yk) = change_coords(x, y, epsgin='epsg:3857', epsgout='epsg:28992')
        
        # Query Database by location
        locinfo = queryPostGISClosestPointKRW(xk, yk)    
        # Get Fews identifier
        try:
            fewsid = locinfo[0][1]
            xfind = locinfo[0][3]
            yfind = locinfo[0][4]
        except:                     
            values['error_html'] = 'Er is een fout opgetreden tijdens het ondervragen van de database [search closest]'
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return

        # Send back result JSON [pre-cooked plot]
        values['url_png'] = 'https://nutrientenmaas.openearth.nl/nutrientenMaas/krwnutrend/Trend-{}%20-%20{}tot.jpg'.format(fewsid, param[:1]) # N or P
        values['plot_xsize'] = 500
        values['plot_ysize'] = 350

        # Zoom and window title
        (xzoom,yzoom) = change_coords(xfind, yfind, epsgin='epsg:28992', epsgout='epsg:3857')
        values['zoomx'] = xzoom
        values['zoomy'] = yzoom
        #values['dist'] = dist
        values['title'] = 'Geselecteerde tijdreeksen / KRW ' + param        

        json_str = json.dumps(values)
        logging.info('''OUTPUT [krw_tseries]: {}'''.format(json_str))
        outdata.write(json_str)
        self.json.setValue(outdata)       

        return

