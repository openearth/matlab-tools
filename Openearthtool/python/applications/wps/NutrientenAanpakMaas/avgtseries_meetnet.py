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

# $Id: info_nhiflux.py 13706 2017-09-13 09:29:46Z sala $
# $Date: 2017-09-13 11:29:46 +0200 (Wed, 13 Sep 2017) $
# $Author: sala $
# $Revision: 13706 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/NutrientenAanpakMaas/avgtseries_meetnet.py $
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
                            identifier="avgtseries_meetnet",
                            title="Landelijk meetnet grondwater",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Landelijk meetnet grondwater bevat data van het landelijk meetnet grondwater. De tool maakt het het mogelijk om NO3, NH4+ en P-totaal per locaties op te vragen. De data wordt gepresenteerd per filter en in 3 grafieken (voor iedere parameter 1). 
                            De dichtstbijzijnde beschikbare locatie wordt geselecteerd.""",
                            grassLocation=False)

        self.location = self.addLiteralInput(identifier="location",
                                              title="Selecteer een locatie en klik op execute",
                                              abstract="input=mapselection",
                                              type=type(""),
                                              uoms=["point"])

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
        logging.info('''INPUT [avgtseries_meetnet]: location={}'''.format(str(location)))

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
        res = queryPostGISLandelijkMeetnetTseriesXY(xk, yk)   
        if not(res):            
            logging.info(msg)            
            values['error_html'] = 'Er is een fout opgetreden tijdens het ondervragen van de database [by location]'
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return
        else:
            xfind = res[0][0]
            yfind = res[1][1]
            (xzoom,yzoom) = change_coords(xfind, yfind, epsgin='epsg:28992', epsgout='epsg:3857')

        # Generate plot         
        tmpfile = getTempFile(PLOTS_DIR)
        bokeh = bokeh_Plot(res, xk, yk, None, tmpfile, None, None)
        bokeh.plot_3Tseries_Mean()

        # Send back result JSON
        values['url_plot'] = APACHE_DIR + os.path.basename(tmpfile)        
        values['zoomx'] = xzoom
        values['zoomy'] = yzoom
        values['plot_xsize'] = 800
        values['plot_ysize'] = 750
        values['dist'] = 3000
        values['title'] = 'Geselecteerde tijdreeksen'
        
        json_str = json.dumps(values)
        logging.info('''OUTPUT [avgtseries_meetnet]: {}'''.format(json_str))
        outdata.write(json_str)
        self.json.setValue(outdata)       

        return

