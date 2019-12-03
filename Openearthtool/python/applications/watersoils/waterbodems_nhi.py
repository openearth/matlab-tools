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

# $Id: waterbodems_nhi.py 12746 2016-05-20 12:35:24Z sala_joan $
# $Date: 2016-08-22 14:35:24 +0200 (Mon, 22 Aug 2016) $
# $Author: sala $
# $Revision: 12746 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/waterbodems/waterbodems_nhi.py $
# $Keywords: $

# core
import os
import operator
import math
import tempfile
import logging

# modules
import simplejson as json
import StringIO
from pywps.Process import WPSProcess

# relative
from opendap_nhi import nhi_invoer
from ahn2 import ahn
from bokeh_waterbodems import waterbodems_Plot
from lineSlice import lineSlice
from lineSlice import change_coords

"""
Waterbodems nhi WPS start script

This is a redesigned WPS for the Waterbodems application, based in infoline_redesigned.

if it runs on localhost then:
getcapabilities:  http://localhost/cgi-bin/pywps.cgi?request=GetCapabilities&service=wps&version=1.0.0
describe process: http://localhost/cgi-bin/pywps.cgi?request=DescribeProcess&service=wps&version=1.0.0&identifier=waterbodems_nhi
execute:          http://localhost/cgi-bin/pywps.cgi?&service=wps&request=Execute&version=1.0.0&identifier=waterbodems_nhi&datainputs=[linestr={%20"type":%20"FeatureCollection",%20"features":%20[%20{%20"type":%20"Feature",%20"properties":%20{%20"id":%20null%20},%20"geometry":%20{%20"type":%20"LineString",%20"coordinates":%20[%20[%2083831.092144669499,%20448452.68563390407%20],%20[%2083958.355731735704,%20448428.40837328951%20],%20[%2084101.003099671972,%20448430.12129659101%20],%20[%2084247.216841408226,%20448418.68480195443%20],%20[%2084347.366886706994,%20448334.90273034602%20],%20[%2084437.90036527536,%20448234.41033133975%20],%20[%2084524.658347761986,%20448132.09910295915%20],%20[%2084624.369683701385,%20448016.50065624306%20],%20[%2084727.680250018995,%20447889.61876790464%20],%20[%2084823.542831033759,%20447766.58495800826%20],%20[%2084908.650886898482,%20447679.27150645608%20]%20]%20}%20}%20]%20}]
"""

class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="waterbodems_nhi",
                            title="waterbodems_nhi",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Waterbodems WPS gets data from various online subsurface resources in order to give information
                                        about status of subsurface in the Netherlands. Same principle as Infoline but the input is now a Linestring
                                        Contributing to Waterbodems are NHI (http://nhi.nu), Dinoloket (http://www.dinoloket.nl).
                                        See describeprocess for input and output parameters""",
                            grassLocation=False)
                                      
        self.linestr = self.addComplexInput(identifier = "linestr", maxmegabites=20,
                                             title = "Input vector (point, linestring) in format geojson, well known text or gml in epsg:3857",
                                             formats = [
                                                 {'mimeType': 'text/plain', 'encoding': 'UTF-8'},                                                 
                                                 {'mimeType': 'application/json'}
                                             ])

        self.bounds = self.addComplexInput(identifier = "bounds", maxmegabites=20,
                                     title = "Input MultiPolint (2 points, begin and end) in format geojson, well known text or gml in CRS EPSG:3857",
                                     formats = [
                                         {'mimeType': 'text/plain', 'encoding': 'UTF-8'},                                                 
                                         {'mimeType': 'application/json'}
                                     ])

        self.depth = self.addComplexInput(identifier="depth",
                                         title="Depth of the drilling [meters]",
                                         formats = [
                                             {'mimeType': 'text/plain', 'encoding': 'UTF-8'},                                             
                                         ])        

        self.json = self.addComplexOutput(identifier="json",
                                          title="Returns list of values (lithology in case of Geotop in m below surface level) for specified xy",
                                          abstract="""For every geotop lithology top, bottom, lithology and hex colour is given. Origin of Geotop is http://www.dinodata.nl/opendap/""",
                                          formats=[{"mimeType": "text/plain"},  # 1st is default
                                                   {'mimeType': "application/json"}]) 

    def execute(self):

        # Output prepare
        json_output = StringIO.StringIO()
        values = {}
        
        # Input line/point   
        with open(self.linestr.getValue(),'r') as f1:
            linestr_str = f1.read()
            logging.info('LINESTR: '+linestr_str)        
            data = json.loads(linestr_str)            
        
        # Input begin/end
        with open(self.bounds.getValue(),'r') as f2:
            bounds_str = f2.read()
            logging.info('BOUNDS: '+bounds_str)        
            databounds = json.loads(bounds_str)  


        # Depth
        try:
            with open(self.depth.getValue(),'r') as f3:
                depth = float(f3.read())
                logging.info('DEPTH: {}'.format(depth))
        except:
            depth = 99999.0 # default NaN

        # Data resolution (geotop=100m, nhi/regis=250) ==> overwrite input polyline with sliced one
        resolution=250        
        grid_size= math.sqrt((resolution**2)*2)               
        ls=lineSlice(data, databounds, grid_size)
        orientation=ls.getOrientation()
        
        # Main loop (for every point of the line)  
        values['nhi'] = []
        npoints = 0
        
        logging.info('SPLIT+SAMPLING -> {}'.format(ls.coordsfinal))
        for xin,yin in ls.coordsfinal:          
            # convert coordinates                
            (x,y) = change_coords(xin, yin, epsgin='epsg:3857', epsgout='epsg:28992')
                
            # AHN
            try:
                hoogte = ahn(x, y)
                #values['maaiveldhoogte'] = float(hoogte)
            except:
                hoogte = 0.0
                #values['maaiveldhoogte'] = hoogte                
              
            # x0,y0
            if npoints == 0:
                xo = x
                yo = y
                
            # NHI (x,y)
            try:
                dt = {}
                ranges = [hoogte]
                fluxes = []
                dt['layers'] = []            
                dt['dist'] = math.sqrt((x-xo)*(x-xo) + (y-yo)*(y-yo)) # euclidean distance            
                dt['point'] = [round(x,1), round(y,1)]
                
                nhi = nhi_invoer(x, y)
                prev = float(hoogte)
                nhi_sort = sorted(nhi.items(), key=operator.itemgetter(0))
        
                for item in nhi_sort:
                    key, value = item
                    value = [float(x) if x is not None else None for x in value]
                    flf, ghg, glg, top, base = value
        
                    if not base or not top:
                        continue
        
                    if base is not None:
                        ranges.append(base)
                    if top is not None:
                        ranges.append(top)
                    if flf is not None:
                        fluxes.append(flf)
                    
                    # NaN control
                    if math.isnan(prev):    prev = None
                    if math.isnan(top):     top = None
                    if math.isnan(base):    base = None 
                    
                    layer_fer = {"top": prev, "bottom": top,
                                 "type": "aquifer", "GLG": glg, "GHG": ghg}
                    layer_tar = {"flux": flf, "top": top,
                                 "bottom": base, "type": "aquitard"}
                    dt['layers'].append(layer_fer)
                    dt['layers'].append(layer_tar)
        
                    prev = base
        
                maaiveldhoogte = float(max(ranges))
        
                # Correction for maaiveld
                for layer in dt['layers']:
                    layer['top'] -= maaiveldhoogte
                    layer['bottom'] -= maaiveldhoogte
        
                # because we've corrected with maaiveldhoogte
                dt['max'] = 0
                dt['min'] = float(min(ranges)) - maaiveldhoogte
                dt['maxFlux'] = float(max(fluxes))
                dt['minFlux'] = float(max(fluxes))
        
                # add to list
                values['nhi'].append(dt)
                npoints+=1
            except:
                pass
       
        # Output and graph (temporary files, outside of wps instance tempdir, otherwise they get deleted)      
        dirname = os.path.basename(tempfile.gettempdir())
        parent_dir = os.path.abspath(os.path.join(tempfile.gettempdir(), os.pardir))
        temp_html = os.path.join(parent_dir, dirname+'.html')
        values['title'] = """LHM (orientation {})""".format(orientation)                
        plot = waterbodems_Plot(values, temp_html, depth, colorTable='NHI')
        plot.generate_plot()        
        apache_dir='http://tw-137.xtr.deltares.nl/wpsoutputs/'
        values['url_plot'] = apache_dir + dirname+'.html'
        
        # Output finalize        
        json_str = json.dumps(values)
        json_output.write(json_str)
        #logging.info(json_str)
        self.json.setValue(json_output)        

        return
