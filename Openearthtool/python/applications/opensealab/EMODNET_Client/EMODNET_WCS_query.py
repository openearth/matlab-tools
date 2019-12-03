# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
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
# $Keywords: $

import os
from owslib.wcs import WebCoverageService

class EMODNET_WCS_query:

    # Create class
    def __init__(self, bbox_in, outtif, url_wcs, layer_wcs, ident, format_in='GeoTiff', wfactor=100, hfactor=100):
        self.bbox_in = bbox_in
        self.outtif = outtif
        self.url_wcs = url_wcs
        self.layer_wcs = layer_wcs
        self.ident = ident
        self.format_in = format_in
        self.wfactor = wfactor
        self.hfactor = hfactor

    ## ------------------------------
    ##      Get WCS raster piece
    ## ------------------------------
    def getDataWCS(self):
        # define the connection
        wcs = WebCoverageService(self.url_wcs, version='1.0.0', timeout=320)
        wcs.identification.type
        wcs.identification.title

        # get the data
        sed = wcs[self.layer_wcs]  # this is necessary to get essential metadata from the layers advertised
        sed.keywords
        sed.grid.highlimits
        sed.boundingboxes
        cx, cy = map(int, sed.grid.highlimits)
        bbox = sed.boundingboxes[0]['bbox']
        lx, ly, hx, hy = map(float, bbox)
        resx, resy = (hx - lx) / cx, (hy - ly) / cy
        width = cx / self.wfactor
        height = cy / self.hfactor
        gc = wcs.getCoverage(identifier=self.ident,
                             bbox=self.bbox_in,
                             coverage=sed,
                             format='GeoTIFF',
                             crs=sed.boundingboxes[0]['nativeSrs'],
                             width=width,
                             height=height)

        # Output tiff
        if os.path.isfile(self.outtif):
            os.unlink(self.outtif)
        f = open(self.outtif, 'wb')
        f.write(gc.read())
        f.close()
        return width, height

## ======== TEST ========
def test():
    # Test inputs
    url_wcs = 'http://ows.emodnet-bathymetry.eu/wcs?'
    layer_wcs = 'emodnet:mean_atlas_land'
    ident = 'emodnet:mean'
    outtif = '../tmp_data/wcs.tif'
    bbox_in = (2.097, 52.715, 4.277, 53.935)

    # Do work
    emodwcs = EMODNET_WCS_query(bbox_in, outtif, url_wcs, layer_wcs, ident)
    width, height = emodwcs.getDataWCS()
    print 'WCS query finished'
    print 'Image created with resolution = {} x {}'.format(width, height)

## ======== MAIN ======== [ Class test ]
if __name__ == "__main__":
    print 'EMODNET_WCS loaded'
    #test()