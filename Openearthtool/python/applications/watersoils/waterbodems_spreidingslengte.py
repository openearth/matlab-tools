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

# $Id: waterbodems_spreidingslengte.py 12746 2016-05-20 12:35:24Z sala_joan $
# $Date: 2016-08-22 14:35:24 +0200 (Mon, 22 Aug 2016) $
# $Author: sala $
# $Revision: 12746 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/watersoils/waterbodems_spreidingslengte.py $
# $Keywords: $

# modules
import logging
import simplejson as json
import StringIO
import math
from pywps.Process import WPSProcess
import numpy as np
import geojson
from netCDF4 import Dataset
from pyproj import Proj, transform
from shapely.ops import cascaded_union 
from shapely.geometry import Point
from shapely.geometry import MultiPolygon, Polygon

# relative
from lineSlice import lineSlice
from lineSlice import change_coords

"""
Waterbodems spreidingslengte WPS start script

This is a redesigned WPS for the Waterbodems application, based in infoline_redesigned.

if it runs on localhost then:
getcapabilities:  http://localhost/cgi-bin/pywps.cgi?request=GetCapabilities&service=wps&version=1.0.0
describe process: http://localhost/cgi-bin/pywps.cgi?request=DescribeProcess&service=wps&version=1.0.0&identifier=waterbodems_spreidingslengte
"""


class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="waterbodems_spreidingslengte",
                            title="waterbodems_spreidingslengte",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""waterbodems_spreidingslengte statistics""",
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
                                          title="Returns a polygon of the spreidingslengte",
                                          abstract="""Statistics of the polyline, convex hull polyline of the lambda values (vertical resistance and transmissivity)""",
                                          formats=[{"mimeType": "text/plain"},  # 1st is default
                                                   {'mimeType': "application/json"}])
                                                   

    def execute(self):

        # Output prepare
        json_output = StringIO.StringIO()
                
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

        # Data resolution set to 50m              
        grid_size= 50
        ls=lineSlice(data, databounds, grid_size)
                
        # Main loop (for every point of the line)  
        buffer_circles = []
        
        # Urls Opendap
        url_vert_res = 'http://opendap-nhi-data.deltares.nl/thredds/dodsC/opendap/Modellen/NHI/modelinvoer/verical_resistance/vertical_resistance_layer1.nc'
        url_transm = 'http://opendap-nhi-data.deltares.nl/thredds/dodsC/opendap/Modellen/NHI/modelinvoer/transmissivity/transmissivity_layer1.nc'
                
        logging.info('SPLIT+SAMPLING -> {}'.format(ls.coordsfinal))
        for xin,yin in ls.coordsfinal:               
            # convert coordinates                
            (x,y) = change_coords(xin, yin, epsgin='epsg:3857', epsgout='epsg:28992')

            # spreidingslengte (x,y) - for every point
            try:
                # Queries
                Kd=self.get_opendap_value(x,y,url_vert_res)
                c=self.get_opendap_value(x,y,url_transm)
                
                # Buffer calculation and store
                l=math.sqrt(Kd*c)
                buffer_circles.append(Point(x,y).buffer(l))
            except:
                #logging.info('Warning spreidingslengte: No info for point (x,y) = ('+str(x)+','+str(y)+')')                    
                pass       
        
        # Cascaded union
        m = MultiPolygon(buffer_circles)
        c = cascaded_union(m)        
        g = geojson.Feature(geometry=c, properties={})
        
        # Get stats
        bbox=c.bounds
        url_landuse = 'http://opendap-nhi-data.deltares.nl/thredds/dodsC/opendap/Modellen/NHI/modelinvoer/metaswap/landuse.nc'      
        try:
        	arr=self.get_opendap_bbox(bbox[0],bbox[1],bbox[2],bbox[3], url_landuse)        
        	self.crop_data_polygon(arr,bbox[0],bbox[1],bbox[2],bbox[3],m) # intersection data + spreidingslengste                
        	stats = self.get_stats(arr)
        except:
        	logging.info('ERR: Could not get landuse information for the given location')
        	stats = self.get_stats(None)
        
        # Output finalize        
        poly_str = geojson.dumps(g, sort_keys=True)  
        res={}
        res['shape'] = json.loads(poly_str)
        res['stats'] = stats   
        json_str = json.dumps(res, use_decimal=True)
        json_output.write(json_str)
        self.json.setValue(json_output) 

        return
        
    ## AUXILIARY functions 
    def crop_data_polygon(self,data,x0,y0,x1,y1,spredl):       
        rows,cols = data.shape    
        Sx = (x1-x0)/float(cols)
        Sy = (y1-y0)/float(rows)

        for r in range(0,rows):
            for c in range(0,cols):                
                # We start by (0,0) then x0,y1=[0,0] || y is negative (down) || x is positive up
                box=Polygon([(x0+c*Sx, y1-r*Sy), (x0+c*Sx, y1-(r+1)*Sy), (x0+(c+1)*Sx, y1-(r+1)*Sy), (x0+(c+1)*Sx, y1-r*Sy), (x0+c*Sx, y1-r*Sy)])                
                if not(spredl.intersects(box)):
                     data[r,c]=-1
                
        
    def find_nearest(self, array, value):
        """Finds nearest value in array """
        idx = (np.abs(array - value)).argmin()
        return array[idx], int(idx)

    def get_opendap_value(self, x, y, url):
        """Returns Band1 value from opendap for x,y."""
        rdata = Dataset(url, 'r')
        rdnew = Proj(init='epsg:28992')
        wgs84 = Proj(init='epsg:4326')
        nx, ny = transform(rdnew, wgs84, x, y)
        xnear, xi = self.find_nearest(rdata['lon'][:], nx)
        ynear, yi = self.find_nearest(rdata['lat'][:], ny)
        return rdata['Band1'][yi, xi]

    def get_opendap_bbox(self, x0, y0, x1, y1, url):
        """Returns Band1 value from opendap for x,y."""
        rdata = Dataset(url, 'r')
        rdnew = Proj(init='epsg:28992')
        wgs84 = Proj(init='epsg:4326')
        nx0, ny0 = transform(rdnew, wgs84, x0, y0)
        nx1, ny1 = transform(rdnew, wgs84, x1, y1)
  
        xnear, xmin = self.find_nearest(rdata['lon'][:], nx0)
        xfar, xmax = self.find_nearest(rdata['lon'][:], nx1)        
        ynear, ymin = self.find_nearest(rdata['lat'][:], ny0)        
        yfar, ymax = self.find_nearest(rdata['lat'][:], ny1)
        
        return rdata['Band1'][ymin:ymax, xmin:xmax]
        
    def get_stats(self, arr):
        stats = {}
        stats['landbouw'] = 0
        stats['natuur'] = 0
        stats['water'] = 0
        stats['stedelijk'] = 0
        if arr == None:	return stats # empty

        N=0      
        for line in arr:
            for a in line:
                landuse=self.getclass(int(a))
                if landuse != None:
                    stats[landuse] = stats[landuse] + 1
                    N=N+1
        
        if N != 0: # nodata
            stats['landbouw'] = (float(stats['landbouw'])/N)*100
            stats['natuur'] = (float(stats['natuur'])/N)*100
            stats['water'] = (float(stats['water'])/N)*100
            stats['stedelijk'] = (float(stats['stedelijk'])/N)*100
        
        return stats
        
    def getclass(self, val):
        dct = {}        
        dct['landbouw'] = [1,2,3,4,5,6,7,8,9,10,26]
        dct['natuur'] = [11,12,13,14,15,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,45]
        dct['water'] = [0,16,17,27]
        dct['stedelijk'] = [18,19,20,21,22,23,24,25,28]

        for key in dct.keys():
            if val >= 46:
                return 'natuur'
            elif val in dct[key]:
                return key
   
