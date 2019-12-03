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

# $Id: meetlocaties_nitraat.py 14274 2018-04-06 06:27:05Z hendrik_gt $
# $Date: 2018-04-05 23:27:05 -0700 (Thu, 05 Apr 2018) $
# $Author: hendrik_gt $
# $Revision: 14274 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/NutrientenAanpakMaas/meetlocaties_nitraat.py $
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
                            identifier="meetlocaties_nitraat",
                            title="Toon Nitraat app metingen",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Deze functie maakt het mogelijk om Nitraat app metingen weer te geven. Meerdere metingen op dezelfde locatie worden samengevoegd in 1 meetreeks.
                            Betekenis van de kleuren:
                            - groen vierkant   = NO3 meting grondwater
                            - rode cirkel      = NO3 meting drainwater
                            - blauwgrijze ster = NO3 meting plaswater 
                            - grijze cirkel    = NO3 meting overig
                            - blauwe driehoek  = NO3 meting oppervlaktewater
                            """,
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
                    allowedValues=["Nitraat meting grondwater",
                                   "Nitraat meting drainwater",
                                   "Nitraat meting plaswater",
                                   "Nitraat meting overig", 
                                   "Nitraat meting oppervlaktewater"],
                    default="Nitraat meting oppervlaktewater")

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
        logging.info('''INPUT [meetlocaties]: location={}'''.format(str(location)))
        logging.info("""INPUT [parameter]: paramter = {}""".format(param))

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
        locinfo = queryPostGISClosestPointNitrate(xk, yk)
        if not(locinfo):            
            logging.info(msg)            
            values['error_html'] = 'Er is een fout opgetreden tijdens het ondervragen van de database [search closest]'
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return

        logging.info(locinfo)
        locid = locinfo[0][1]
        locname = locinfo[0][2]
        xfind = locinfo[0][10]
        yfind = locinfo[0][11]
        dist = locinfo[0][-1]

        # Title of plot
        if locinfo[0][2] == None:   tit0 = ''
        else:                       tit0 = locinfo[0][2]      
        if locinfo[0][3] == None:   tit1 = ''
        else:                       tit1 = locinfo[0][3]
        if locinfo[0][4] == None:   tit2 = ''
        else:                       tit2 = locinfo[0][4]
        title = '{} // {} // {}'.format(tit0, tit1, tit2)
        
        # Query database by Identifier
        res=queryPostGISLocIDTseriesNitrate(locid, param)
        if not(res):            
            logging.info(msg)            
            values['error_html'] = 'Er is een fout opgetreden tijdens het ondervragen van de database [by location]'
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return

        # Generate plot GW vs time        
        tmpfile = getTempFile(PLOTS_DIR)
        bokeh = bokeh_Plot(res, xk, yk, locid, tmpfile, locname, title)
        bokeh.plot_Tseries()

        # Send back result JSON
        values['url_plot'] = APACHE_DIR + os.path.basename(tmpfile)
        (xzoom,yzoom) = change_coords(xfind, yfind, epsgin='epsg:4326', epsgout='epsg:3857')
        values['zoomx'] = xzoom
        values['zoomy'] = yzoom
        values['dist'] = dist
        values['title'] = 'Geselecteerde tijdreeksen'

        json_str = json.dumps(values)
        logging.info('''OUTPUT [meetlocaties]: {}'''.format(json_str))
        outdata.write(json_str)
        self.json.setValue(outdata)       

        return

