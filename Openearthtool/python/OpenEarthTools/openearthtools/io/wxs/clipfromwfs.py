# -*- coding: utf-8 -*-
#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares for Three clicks to a ground watermodel
#   Gerrit Hendriksen@deltares.nl
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

# $Id: orm_subsurface.py 13354 2017-05-16 12:45:29Z hendrik_gt $
# $Date: 2017-05-16 14:45:29 +0200 (Tue, 16 May 2017) $
# $Author: hendrik_gt $
# $Revision: 13354 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/datamodel/subsurface/orm_subsurface.py $
# $Keywords: $

import sys
import os
from owslib.fes import *
from owslib.etree import etree
from owslib.wfs import WebFeatureService

def clipfromwfs(wfs,layer,bbx,fn):
    print(bbx)
    #wfs11 = WebFeatureService(url='http://localhost:8080/geoserver/global/ows?', version='1.1.0',timeout=320)
    wfs11 = WebFeatureService(url=wfs, version='1.1.0',timeout=320)
    try:
        #response = wfs11.getfeature(typename='global:glhymps', bbox=(75,24,78,26),srsname='urn:x-ogc:def:crs:EPSG:4326',outputFormat='shape-zip')   
        response = wfs11.getfeature(typename=layer, bbox=bbx,srsname='urn:x-ogc:def:crs:EPSG:4326',outputFormat='shape-zip')   
        if os.path.isfile(fn):
            os.unlink(fn)
        out = open(fn, 'wb')
        out.write(response.read())
        out.close()
        return fn
    except:
        print(' '.join(['error occurred while clipping layer',layer,'from',wfs]))
        return None