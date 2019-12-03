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
@author Maarten Pronk/Gerrit Hendriksen
"""

from owslib.wcs import WebCoverageService
import numpy as np
import gdal
import logging

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

        self.cx, self.cy = list(map(int, self.layer.grid.highlimits))
        self.crs = self.layer.boundingboxes[0]['nativeSrs']
        self.bbox = self.layer.boundingboxes[0]['bbox']
        self.lx, self.ly, self.hx, self.hy = list(map(float, self.bbox))
        self.resx, self.resy = (
            self.hx - self.lx) / self.cx, (self.hy - self.ly) / self.cy

        self.path = "/vsimem/" # virtual raster

    def getc(self):
        """Make request to WCS and store it in a memory buffer."""
        output = self.wcs.getCoverage(
            resolutions=[int(self.resx), int(self.resy)], identifier=self.layername.split(":")[-1], bbox=self.area, format='image/tiff', crs=self.crs,
            width=int(100 / self.resx), height=int(100 / self.resy))
        print(output.geturl())
        print(output.info())
        print(output.read())
        gdal.FileFromMemBuffer(self.path, bytes(output.read()))

    def getaverage(self):
        """Open memory raster and average valid cells."""
        ds = gdal.Open(self.path)
        try:
            band = ds.GetRasterBand(1)
            arr = band.ReadAsArray()
            ds = None  # close dataset
            return np.mean(arr[arr > -200]) # filter values
        except:
            logging.info("Raster invalid")
            ds = None
            return -9999

def getwcslayers(url):
    from owslib.wcs import WebCoverageService
    wcs = WebCoverageService(url,version='1.0.0')
    wcs.identification.type
    wcs.identification.title
    return list(wcs.contents)


if __name__ == "__main__":
    x = 84901
    y = 445226
    url = 'https://geodata.nationaalgeoregister.nl/ahn3/ows'
    print(getwcslayers(url))
    w = AHN_WCS_Area(x=x, y=y, url=url, layer='ahn3:ahn3_05m_dsm')
    w.getc()
    print(w.getaverage())
