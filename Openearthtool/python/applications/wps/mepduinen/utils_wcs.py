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

# $Id: utils_wcs.py 14127 2018-01-30 07:21:10Z hendrik_gt $
# $Date: 2018-01-30 08:21:10 +0100 (Tue, 30 Jan 2018) $
# $Author: hendrik_gt $
# $Revision: 14127 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/mepduinen/utils_wcs.py $
# $Keywords: $

import os
import string
import math
import logging
import tempfile
import simplejson as json
import numpy as np
from pyproj import Proj, transform
from owslib.wcs import WebCoverageService
from osgeo import gdal
from shapely import wkt
from random import choice
from scipy.ndimage import map_coordinates

## TO READ WCS outputs
class WCS:
    """WCS object to get metadata etc and to get grid."""
    def __init__(self,host,layer):
        self.id = layer        
        self.wcs = WebCoverageService(host,version='1.0.0')
        self.layer = self.wcs[self.id]
        #_, self.format, self.identifier = self.layer.keywords
        self.cx, self.cy = map(int,self.layer.grid.highlimits)
        self.crs = self.layer.boundingboxes[0]['nativeSrs']
        self.bbox = self.layer.boundingboxes[0]['bbox']
        self.lx,self.ly,self.hx,self.hy = map(float,self.bbox)
        self.resx, self.resy = (self.hx-self.lx)/self.cx, (self.hy-self.ly)/self.cy        
        self.width = self.cx
        self.height = self.cy
        
    def getw(self):
        """Downloads raster and returns filename of written GEOTIFF in the tmp dir."""
        gc = self.wcs.getCoverage(identifier=self.id,
                                  bbox=self.bbox,
                                  format='GeoTIFF',
                                  crs=self.crs,
                                  width=self.width,
                                  height=self.height)
        # random unique filename
        tmpdir = tempfile.gettempdir()
        filename = ''.join(choice(string.ascii_uppercase + string.digits) for _ in range(7))+'.tif'    
        fn = os.path.join(tmpdir,filename)               
        f = open(fn,'wb')
        f.write(gc.read())            
        f.close()
        return fn

## TO handle transects
class LS:
    """Intersection on grid line"""
    def __init__(self,awkt,crs,host,layer,sampling=1):
        self.wkt = awkt
        self.crs = crs
        self.gs = WCS(host,layer) # Initiates WCS service to get some parameters about the grid.
        self.sampling = sampling
        
    def line(self):
        """Creates WCS parameters and sample coordinates for cells in raster based on line input."""
        self.ls = wkt.loads(self.wkt)
        self.ax, self.ay, self.bx, self.by = self.ls.bounds
        # TODO http://stackoverflow.com/questions/13439357/extract-point-from-raster-in-gdal
        
        """if first x is larger than second, coordinates will be flipped during process of defining bounding box !!!!
           next lines introduce a boolean flip variable used in the last part of this proces"""
        flipx = False
        flipy = False
        ax, bx = self.ls.coords.xy[0]
        ay, by = self.ls.coords.xy[1]
        
        if ax >= bx:
            flipx = True
        if ay >= by:
            flipy = True
        
        """get raster coordinates"""
        self.ax = self.ax - self.gs.lx # coordinates minus coordinates of raster, start from 0,0
        self.ay = self.ay - self.gs.ly
        self.bx = self.bx - self.gs.lx
        self.by = self.by - self.gs.ly
        self.x1, self.y1 = int(self.ax // self.gs.resx), int(self.ay // self.gs.resy)
        self.x2, self.y2 = int(self.bx // self.gs.resx)+1, int(self.by // self.gs.resy)+1
        self.gs.bbox = (self.x1*self.gs.resx+self.gs.lx,
                        self.y1*self.gs.resy+self.gs.ly, 
                        self.x2*self.gs.resx+self.gs.lx, 
                        self.y2*self.gs.resy+self.gs.ly)
        self.gs.width = abs(self.x2-self.x1) # difference of x cells
        self.gs.height = abs(self.y2-self.y1)

        """ here we go back to our line again instead of calculating bbox for wcs request."""
        self.ax, self.bx = self.ls.coords.xy[0]
        self.ay, self.by = self.ls.coords.xy[1]
        
        # coordinates minus coordinates of raster, start from 0,0
        self.ax = self.ax - self.gs.lx 
        self.ay = self.ay - self.gs.ly
        self.bx = self.bx - self.gs.lx
        self.by = self.by - self.gs.ly   
        
        if flipx and flipy: # who draws these lines?
            # top right to bottom left
           #logging.info("Both flipped")        
            self.x2, self.y2 = int(self.bx // self.gs.resx), int(self.by // self.gs.resy)
            self.x1, self.y1 = int(self.ax // self.gs.resx)+1, int(self.ay // self.gs.resy)+1
        elif flipx:
            # bottom right to top left
           #logging.info("X flipped")        
            self.x2, self.y1 = int(self.bx // self.gs.resx), int(self.ay // self.gs.resy)
            self.x1, self.y2 = int(self.ax // self.gs.resx)+1, int(self.by // self.gs.resy)+1
        elif flipy:
            # top left to bottom right
           #logging.info("Y flipped")        
            self.x1, self.y2 = int(self.ax // self.gs.resx), int(self.by // self.gs.resy)
            self.x2, self.y1 = int(self.bx // self.gs.resx)+1, int(self.ay // self.gs.resy)+1
        else: 
            # normal
           #logging.info("Normal line")        
            self.x1, self.y1 = int(self.ax // self.gs.resx), int(self.ay // self.gs.resy)
            self.x2, self.y2 = int(self.bx // self.gs.resx)+1, int(self.by // self.gs.resy)+1

        # From upperright to lower left x values become negative
        # Subdivide the line into sampling points of the raster.
        # Takes longest dimension and uses number of cells * sampling as the
        # number of subdivisions.
        # Grid of subdivions is pixel grid - 0.5 
        self.subdiv = int(max(self.gs.width, self.gs.height)) * self.sampling
        self.xlist = np.linspace((self.ax/self.gs.resx)-min(self.x1,self.x2), (self.bx/self.gs.resx)-min(self.x1,self.x2), num=self.subdiv)
        self.ylist = np.linspace((self.ay/self.gs.resy)-min(self.y1,self.y2), (self.by/self.gs.resy)-min(self.y1,self.y2), num=self.subdiv)
        
    def intersect(self, all_box=False):
        """Returns values of line intersection on downlaoded geotiff from wcs."""
        #TODO: this gives y as integer, should be float
        self.fn = self.gs.getw() # filename of just downloaded geotiff
        gdal.UseExceptions()
        try:
            self.raster = gdal.Open(self.fn)
        except:
            logging.error("Raster probably empty, check what you intersect!")
            return None
            
        # Gets raster and flips it to positive dimensions so 0,0 is lower left.
        if all_box:
            self.ra = np.array(self.raster.GetRasterBand(1).ReadAsArray())
        else:
            self.ra = np.array(self.raster.GetRasterBand(1).ReadAsArray())[::-1]

        # Scipy needs transposed array, weird.
        self.coords = np.array(zip(self.ylist,self.xlist)).T
        
        # Order is order of spline interpolation, between 0-5
        # Mode is what happens if cell is requested outside of raster.
        self.values = map_coordinates(self.ra, self.coords, order=0, mode='nearest')

        # Fill nodata values.
        nodata = self.raster.GetRasterBand(1).GetNoDataValue()
        self.values = np.where(self.values == nodata, None, self.values)
        
        # Return whole box or just transect values
        if all_box: 
            return self.ra
        return self.values

    def json(self):
        """Returns JSON with world x,y coordinates and values."""
        self.xco = np.linspace(self.ax+self.gs.lx,self.bx+self.gs.hx,len(self.values))
        self.yco = np.linspace(self.ay+self.gs.ly,self.by+self.gs.hy,len(self.values))
        # note that this is not a real representation at ALL, just for testing.
        self.distances = map(float, np.linspace(0,len(self.values),len(self.values)) * (self.length / len(self.values)))
        return json.dumps(zip(self.distances,self.values))
        #return json.dumps(zip(self.xco,self.yco,avalues))