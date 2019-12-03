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

# $Id: kust_2danimation.py 14134 2018-01-31 07:01:10Z sala $
# $Date: 2018-01-31 08:01:10 +0100 (Wed, 31 Jan 2018) $
# $Author: sala $
# $Revision: 14134 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/mepduinen/kust_2danimation.py $
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
import urllib
from PIL import Image

# modules
import types
import simplejson as json
import StringIO
from pywps.Process import WPSProcess

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
                            identifier="kust_2danimation",
                            title="Kust - 2D animation",
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

        self.yrstart = self.addLiteralInput(
                    identifier="yrstart",
                    title="Kies start",
                    abstract="input=dropdownmenu",
                    type=type(""),
                    allowedValues=range(START_YEAR, END_YEAR+1),
                    default=START_YEAR)

        self.yrend = self.addLiteralInput(
                    identifier="yrend",
                    title="Kies eind",
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
        PLOTS_DIR, APACHE_DIR, GEOSERVER_URL, GEOSERVER_ANIM_URL, GEOSERVER_ANIM_LAY, _ , _ , _ = readConfig()

        # Inputs check
        location = self.location.getValue()
        yrstart = int(self.yrstart.getValue())
        yrend = int(self.yrend.getValue())
        logging.info('''INPUT [kust_2danimation]: location={}'''.format(str(location)))

        # Check bbox
        try:
            geom = shapely.wkt.loads(location)
        except:
            msg = 'Geen locatie opgegeven in WKT-indeling [Polygoon]'
            logging.info(msg)            
            values['error_html'] = msg
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return  
                
        # Get values for selected bbox
        (minx, miny, maxx, maxy) = geom.bounds
        if max(maxx-minx, maxy-miny) > 20000:
            msg = 'Selecteer een kleiner gebied en probeer het opnieuw'
            logging.info(msg)            
            values['error_html'] = msg
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return

        epsgout = 'epsg:28992'
        epsgin = 'epsg:3857'
        epsglatlon = 'epsg:4326'
        (xmink, ymink) = change_coords(minx, miny, epsgin=epsgin, epsgout=epsgout)
        (xmaxk, ymaxk) = change_coords(maxx, maxy, epsgin=epsgin, epsgout=epsgout)        
        (lonmin, latmin) = change_coords(minx, miny, epsgin=epsgin, epsgout=epsglatlon)
        (lonmax, latmax) = change_coords(maxx, maxy, epsgin=epsgin, epsgout=epsglatlon)        
        bboxstr = '{},{},{},{}'.format(xmink,ymink,xmaxk,ymaxk)        

        # For every year selected within the timespan
        time=[]
        for y in range(yrstart, yrend+1): # configured on top
            time.append('{}-01-01T00:00:00.000Z'.format(y))
        timestr = ",".join(time)

        # Calculate shape
        if ((xmaxk-xmink) > (ymaxk-ymink)):
            resparam='width=1024'
        else:
            resparam='height=1024'

        # Build up url
        url='{}?layers={}&bbox={}&transparent=true&format=image/gif;subtype=animated&format_options=gif_loop_continuosly:true&aparam=TIME&avalues={}&{}'.format(
            GEOSERVER_ANIM_URL, GEOSERVER_ANIM_LAY, bboxstr, timestr, resparam)
        logging.info('WMS[animation] = {}'.format(url))

        # Download gif
        try:
            tmpfile = tempfile(PLOTS_DIR, typen='anim', extension='.gif')            
            urllib.urlretrieve(url, tmpfile)
            im = Image.open(tmpfile)
            values['url_gif'] = APACHE_DIR + os.path.basename(tmpfile)
            values['url_gif_x0'] = minx
            values['url_gif_y0'] = miny
            values['url_gif_x1'] = maxx
            values['url_gif_y1'] = maxy
            values['url_gif_w'] = im.size[0]
            values['url_gif_h'] = im.size[1]
        except:
            # Not data available
            msg = 'No data for the selected bounding box. Please draw inside the available area.'
            logging.info(msg)            
            values['error_html'] = msg
            
        # Write data 
        json_str = json.dumps(values)
        outdata.write(json_str)
        self.json.setValue(outdata)

        return