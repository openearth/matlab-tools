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

# $Id: info_nhiflux.py 13706 2017-09-13 09:29:46Z sala $
# $Date: 2017-09-13 11:29:46 +0200 (Wed, 13 Sep 2017) $
# $Author: sala $
# $Revision: 13706 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/NutrientenAanpakMaas/krw_tseries_doelgat.py $
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
                            identifier="krw_tseries_doelgat",
                            title="KRW tijdseries",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Maak een tijdreeks. De dichtstbijzijnde beschikbare locatie wordt geselecteerd.""",
                            grassLocation=False)

        self.location = self.addLiteralInput(identifier="location",
                                              title="Please select a location and click Execute",
                                              abstract="input=mapselection",
                                              type=type(""),
                                              uoms=["point"])
        self.type = self.addLiteralInput(
                    identifier="type",
                    title="Kies parameter",
                    abstract="input=dropdownmenu",
                    type=type(""),
                    allowedValues=["Fosfaat", "Stikstof"],
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
        logging.info('''INPUT [krw_tseries_doelgat]: location={}'''.format(str(location)))

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

        
        json_str = json.dumps(values)
        logging.info('''OUTPUT [krw_tseries_doelgat]: {}'''.format(json_str))
        outdata.write(json_str)
        self.json.setValue(outdata)       

        return

