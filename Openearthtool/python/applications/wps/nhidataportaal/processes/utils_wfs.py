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

# $Id: emisk_utils_wcs.py 14127 2018-01-30 07:21:10Z hendrik_gt $
# $Date: 2018-01-30 08:21:10 +0100 (Tue, 30 Jan 2018) $
# $Author: hendrik_gt $
# $Revision: 14127 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/emisk/emisk_utils_wcs.py $
# $Keywords: $

from owslib.wfs import WebFeatureService
import string
import os
import logging


class WFS:

    # Create class
    def __init__(self, req, bboxrdnew, outdir, random):
        self.bbox_in = bboxrdnew
        self.url_wfs = req['owsurl']
        self.layer_wfs = req['layername']
        self.format = req['fformat']
        self.outdir = outdir
        self.outsrs = 'urn:x-ogc:def:crs:' + req['outcrs']
        self.random = random
        self.outfname = req['outfname']
        self.ext = req['ext']

    # ------------------------------
    # Get Features via WFS
    # ------------------------------
    def getDataWFS(self):
        # define the link to the service and carry out the request
        wfs11 = WebFeatureService(
            url=self.url_wfs, version='1.1.0', timeout=180)
        gf = wfs11.getfeature(typename=self.layer_wfs,
                              bbox=self.bbox_in, outputFormat=self.format)

        # Random unique filename
        filename = self.outfname + '_' + self.random + self.ext
        fn = os.path.join(self.outdir, filename)
        f = open(fn, 'wb')
        f.write(gf.read())
        f.close()
        logging.info('Writing: {}'.format(fn))
        return fn
