#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: pronk_mn
# @Date:   2015-10-23 11:36:02
# @Last Modified by:   pronk_mn
# @Last Modified time: 2015-12-02 09:21:08
# -*- coding: utf-8 -*-
"""
AHN Query
WCS and OpenDAP example
@author Maarten Pronk
"""

import logging
import unittest

from netCDF4 import Dataset
from owslib.wcs import WebCoverageService
from pyproj import Proj, transform
import gdal
import numpy as np

def find_nearest(array, value):
    """Finds nearest value in array. 
    taken from stack^ question 2566412"""
    idx = (np.abs(array - value)).argmin()
    return array[idx], idx


def AHN_DAP(x, y, url='http://opendap-nhi-data.deltares.nl/thredds/dodsC/opendap/Modellen/NHI/modelinvoer/ahn/maaiveld.nc'):
    """Returns height from maaiveld from opendap for x,y."""
    rdata = Dataset(url, 'r')

    rdnew = Proj(init='epsg:28992')
    wgs84 = Proj(init='epsg:4326')
    lon, lat = transform(rdnew, wgs84, x, y)

    xnear, xi = find_nearest(rdata['lat'][:], lat)
    ynear, yi = find_nearest(rdata['lon'][:], lon)

    return rdata['Band1'][xi, yi]


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
        self.area = [self.x - 50, self.y - 50, self.x + 50, self.y + 50]
        self.layer = self.wcs[layer]

        self.cx, self.cy = map(int, self.layer.grid.highlimits)
        self.crs = self.layer.boundingboxes[0]['nativeSrs']
        self.bbox = self.layer.boundingboxes[0]['bbox']
        self.lx, self.ly, self.hx, self.hy = map(float, self.bbox)
        self.resx, self.resy = (
            self.hx - self.lx) / self.cx, (self.hy - self.ly) / self.cy

        self.path = "/vsimem/cswraster"  # virtual raster

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
            return np.mean(arr[arr > -200])  # filter values
        except:
            logging.info("Raster invalid")
            ds = None
            return -9999


class TestAHNHeights(unittest.TestCase):

    def testHeight(self):
        locaties = [(183551, 309839, 137),  # Zuid limburg
                    (97912, 439544, -6.22),  # Nieuwerkerk ad IJssel
                   ]

        for loc in locaties:
            x, y, height = loc
            # Factors are not that nice
            # Could also use + 5m, -5m
            lowerh = abs(height) * 0.7
            upperh = abs(height) * 1.3

            w = AHN_WCS_Area(x=x, y=y)
            w.getc()
            h = abs(w.getaverage())
            logging.info(height, h)

            self.assertTrue(lowerh < h < upperh)

    def testNHI(self):
        locaties = [(183551, 309839, 137),  # Zuid limburg
                    (119481.381985, 529890.915415, -0.5),  # Gerrit
                   ]

        for loc in locaties:
            x, y, height = loc
            # Factors are not that nice
            # Could also use + 5m, -5m
            lowerh = abs(height) - 5
            upperh = abs(height) + 5
            h = abs(AHN_DAP(x, y))
            logging.info(height, h)
            if h != "--":
                self.assertTrue(lowerh < h < upperh)

if __name__ == "__main__":
    # x = 183551
    # y = 309839
    # print AHN_DAP(x, y)
    # w = AHN_WCS_Area(x=x, y=y)
    # w.getc()
    # print w.getaverage()
    unittest.main()
