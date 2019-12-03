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
import pandas
from owslib.wfs import WebFeatureService
from owslib.fes import *

class EMODNET_WFS_query:

    # Create class
    def __init__(self, bbox_in, outshp, url_wfs, layer_wfs, format, propertyname, literal, viewparams):
        self.bbox_in = bbox_in
        self.outshp = outshp
        self.url_wfs = url_wfs
        self.layer_wfs = layer_wfs
        self.format = format
        self.propertyname = propertyname
        self.literal = literal
        self.viewparams = viewparams

    ## ------------------------------
    ##      Get Features via WFS
    ## ------------------------------
    def getDataWFS(self):
        # define the input variables
        afilter = PropertyIsEqualTo(propertyname=self.propertyname, literal=self.literal)

        # define the link to the service and carry out the request
        wfs11 = WebFeatureService(url=self.url_wfs, version='1.1.0', timeout=320)
        response = wfs11.getfeature(typename=self.layer_wfs,
                                    bbox=self.bbox_in,
                                    outputFormat=self.format,
                                    filter=afilter
                                    )
        # Write result
        if os.path.isfile(self.outshp):
            os.unlink(self.outshp)
        out = open(self.outshp, 'wb')
        out.write(response.read())
        out.close()
        return

    ## ------------------------------
    ##      Get Features via WFS
    ## ------------------------------
    def getDataWFSView(self):
        # define the input variables
        afilter = PropertyIsEqualTo(propertyname=self.propertyname, literal=self.literal)

        # define the link to the service and carry out the request
        wfs11 = WebFeatureService(url=self.url_wfs, version='1.1.0', timeout=320)
        response = wfs11.getfeature(typename=self.layer_wfs,
                                    bbox=self.bbox_in,
                                    outputFormat=self.format,
                                    viewparams=self.viewparams,
                                    format = self.format
                                    )
        # Write result
        if os.path.isfile(self.outshp):
            os.unlink(self.outshp)
        out = open(self.outshp, 'wb')
        out.write(response.read())
        out.close()
        return

