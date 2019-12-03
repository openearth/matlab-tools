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

# $Id: kust_transect.py 14128 2018-01-30 07:30:36Z sala $
# $Date: 2018-01-30 08:30:36 +0100 (Tue, 30 Jan 2018) $
# $Author: sala $
# $Revision: 14128 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/emisk/kust_transect.py $
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
from geojson import LineString, Feature, FeatureCollection
from shapely import wkt

# Self libraries
from utils import *
from bokeh_plots import *

"""
This is a redesigned WPS for the mep duinen application
"""

START_YEAR = 1997
END_YEAR = 2015

class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="kust_transect",
                            title="Kust - Transect",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Deze functie maakt het mogelijk om dwarsprofielen van de JARKUS grids te maken. Teken een profiel (dubbel klik om het profiel af te sluiten) en klik op Execute om het dwarsprofiel te bepalen (dit is een dynamisch proces en kan even duren).""",
                            grassLocation=False)

        self.transect = self.addLiteralInput(identifier="transect",
                                              title="Teken een transect en klik op Execute",
                                              abstract="input=mapselection",
                                              type=type(""),
                                              uoms=["linestring"])

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
        PLOTS_DIR, APACHE_DIR, GEOSERVER_URL, _, _, _, _, _ = readConfig()

        # Inputs check
        try:
            linestr_str = self.transect.getValue()
            yrstart = int(self.yrstart.getValue())
            yrend = int(self.yrend.getValue())
            logging.info('''INPUT [kust_transect]: location={}'''.format(str(linestr_str)))      
            lwkt = wkt.loads(linestr_str)  
        except:
            msg = 'Selecteer eerst een transect en klik op Execute'
            logging.info(msg)            
            values['error_html'] = msg
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return   
                
        # Get values for selected xy in fixed epsg
        epsgout = 'epsg:28992'
        epsgin = 'epsg:3857'
        wcs_x = {}
        wcs_y = {}

        # For every layer, supports multilinestrings
        err = False
        mindist =  99999
        maxdist = -99999
        for y in range(yrstart, yrend+1): # configured on top
            # For every subline of the transect
            x0, y0 = change_coords(lwkt.coords[0][0], lwkt.coords[0][1], epsgin=epsgin, epsgout=epsgout)
            wcs_vals = []
            wcs_dist = []
            first = True
            total_dist = 0
            # Go line by line
            for xin,yin in lwkt.coords: 
                # First point is useless
                if first: 
                    first = False
                    continue
                
                # Point
                (xk,yk) = change_coords(xin, yin, epsgin=epsgin, epsgout=epsgout)
                total_dist += math.sqrt((xk-x0)*(xk-x0) + (yk-y0)*(yk-y0))
                if total_dist > 10000:
                    msg = 'de maximaal toegestane afstand voor een transect is 10 km. Probeer het opnieuw.'
                    logging.info(msg)            
                    values['error_html'] = msg
                    json_str = json.dumps(values)
                    outdata.write(json_str)
                    self.json.setValue(outdata)
                    return
                
                # Retrieve and parse data
                d=getDatafromWCS(GEOSERVER_URL, 'Kust:{}'.format(y), x0, y0, xk, yk)   
                if not(d is None):
                    N=float(len(d))
                    step=float(total_dist)/N
                    # concatenate values  
                    i=0.0                  
                    for val in d: 
                        if not(val is None) and val > -999.0: #no-nonsense
                            wcs_vals.append(val) 
                            wcs_dist.append(step*i)                            
                        i+=1.0

            # Add to hash results for layer l
            if len(wcs_vals):                 
                wcs_y[y] = wcs_vals
                wcs_x[y] = wcs_dist
                maxdist = max(maxdist, max(wcs_dist))
                mindist = min(mindist, min(wcs_dist))

        # Start/End of data
        m = math.sqrt((xk-x0)*(xk-x0) + (yk-y0)*(yk-y0))
        xu = float(xk-x0)/float(m)
        yu = float(yk-y0)/float(m)
        xs = x0 + mindist*xu
        ys = y0 + mindist*yu       
        xe = x0 + maxdist*xu
        ye = y0 + maxdist*yu
        (lone,late) = change_coords(xe, ye, epsgin=epsgout, epsgout='epsg:4326')
        (lons,lats) = change_coords(xs, ys, epsgin=epsgout, epsgout='epsg:4326')
        
        # Generate plot borehole       
        if len(wcs_y) or err:
            # Prepare plot            
            tmpfile = tempfile(PLOTS_DIR)
            bokeh=bokeh_Plot(wcs_x, wcs_y, {'x':'Transect', 'y':'Transect', 'locationke':'Selected by user'}, tmpfile)
            bokeh.plot_Transect()

            # Send back result JSON     
            values['url_plot'] = APACHE_DIR + os.path.basename(tmpfile)
            values['plot_xsize'] = 1020
            values['plot_ysize'] = 550
            values['zoomx'] = (lwkt.coords[0][0]+lwkt.coords[1][0])/2.0
            values['zoomy'] = (lwkt.coords[0][1]+lwkt.coords[1][1])/2.0
            values['title'] = 'OpenEarth WPS'
            values['wkt_transect'] = 'LINESTRING ({} {}, {} {})'.format(lons,lats,lone,late)
            json_str = json.dumps(values)
            logging.info('''OUTPUT [kust_transect]: {}'''.format(json_str))
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