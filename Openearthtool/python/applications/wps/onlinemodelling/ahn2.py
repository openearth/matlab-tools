#!/usr/bin/env python
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2015 Deltares
#       Maarten Pronk
#
#       maarten.pronk@deltares.nl
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

# $Id: ahn2.py 13631 2017-09-01 10:39:25Z sala $
# $Revision: 13631 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/onlinemodelling/ahn2.py $
# $Keywords: $

"""
AHN2 WCS average height tool for Infoline
@author Maarten Pronk
"""

from pyproj import Proj, transform
from owslib.wcs import WebCoverageService
import numpy as np
import gdal
import logging
from netCDF4 import Dataset


def find_nearest(array, value):
    """Finds nearest value in array. 
    taken from stack^ question 2566412"""
    idx = (np.abs(array - value)).argmin()
    return array[idx], int(idx)


def AHN_DAP(x, y, url='http://opendap-nhi-data.deltares.nl/thredds/dodsC/opendap/Modellen/NHI/modelinvoer/ahn/maaiveld.nc'):
    """Returns height from maaiveld from opendap for x,y."""
    rdata = Dataset(url, 'r')
    logging.info(' = '.join(['url', url]))
    rdnew = Proj(init='epsg:28992')
    wgs84 = Proj(init='epsg:4326')
    nx, ny = transform(rdnew, wgs84, x, y)

    xnear, xi = find_nearest(rdata['lon'][:], nx)
    ynear, yi = find_nearest(rdata['lat'][:], ny)

    return rdata['Band1'][yi, xi]


class AHN_WCS_Area:

    """WCS class specified for AHN2 webservice.
    Takes holes into account by requesting 100x100 grid
    and taking average height."""

    def __init__(self, url='http://geodata.nationaalgeoregister.nl/ahn2/ows', layer='ahn2:ahn2_5m', x=92524, y=453058):
        """Make connection to webservice and initiate parameters."""
        try:
            self.wcs = WebCoverageService(url, version='1.0.0')
        except:
            logging.error("WCS host unavailable")
        self.x, self.y = x, y
        self.layername = layer

        # AREA +50 of uitgelijnd op 0,0,100,100 etc.
        self.area = [self.x - 50, self.y - 50, self.x + 50, self.y + 50]

        self.layer = self.wcs[layer]
        self.cx, self.cy = map(int, self.layer.grid.highlimits)
        self.crs = self.layer.boundingboxes[0]['nativeSrs']
        self.bbox = self.layer.boundingboxes[0]['bbox']
        self.lx, self.ly, self.hx, self.hy = map(float, self.bbox)
        self.resx, self.resy = (
            self.hx - self.lx) / self.cx, (self.hy - self.ly) / self.cy
        self.path = "/vsimem/cswraster"

    def getc(self):
        """Make request to WCS and store it in a memory buffer."""
        output = self.wcs.getCoverage(
            resolutions=[int(self.resx), int(self.resy)], identifier=self.layername, bbox=self.area, format='TIFF', crs=self.crs,
            width=int(100 / self.resx), height=int(100 / self.resy))
        gdal.FileFromMemBuffer(self.path, bytes(output.read()))

    def getaverage(self):
        """Open memory raster and average valid cells."""
        ds = gdal.Open(self.path)
        try:
            band = ds.GetRasterBand(1)
            arr = band.ReadAsArray()
            ds = None  # close dataset
            return np.mean(arr[arr > -200])
        except:
            logging.info("Raster invalid")
            ds = None
            return -9999


def ahn(x, y):
    ret = AHN_DAP(x, y)
    logging.info(' = '.join(['returned from OPeNDAP', str(ret)]))
    if ret.data == -9999:
        w = AHN_WCS_Area(x=x, y=y)
        w.getc()
        ret = w.getaverage()
        logging.info(' = '.join(['ret', str(ret)]))
    return ret


# if __name__ == "__main__":
#    x = 84901
#    y = 445226
#    print AHN_DAP(x, y)
#    w = AHN_WCS_Area(x=x, y=y)
#    w.getc()
#    print w.getaverage()
