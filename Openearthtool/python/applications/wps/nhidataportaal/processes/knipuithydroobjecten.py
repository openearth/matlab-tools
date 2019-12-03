# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares for LHM Projects
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

# $Id: info_nhiflux.py 13706 2017-09-13 09:29:46Z sala $
# $Date: 2017-09-13 11:29:46 +0200 (Wed, 13 Sep 2017) $
# $Author: sala $
# $Revision: 13706 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/onlinemodelling/info_nhiflux.py $
# $Keywords: $

import os
from owslib.wfs import WebFeatureService


def clipfromwfs(wfs, layer, bbx, fn, srs=4326, of='shape-zip'):
    print(bbx)
    wfs11 = WebFeatureService(url=wfs, version='1.1.0', timeout=320)
    try:
        response = wfs11.getfeature(
            typename=layer, bbox=bbx,
            srsname='urn:x-ogc:def:crs:EPSG:{s}'.format(s=srs),
            outputFormat=of)
        if os.path.isfile(fn):
            os.unlink(fn)
        out = open(fn, 'wb')
        out.write(response.read())
        out.close()
        return fn
    except:
        print((' '.join(['error occurred while clipping layer',
                         layer, 'from', wfs])))
        return None


def writewfs2csv(bbx, tmpdir):
    wfs = 'https://data.nhi.nu/geoserver/oppervlaktewater_1/ows?'
    layer = 'oppervlaktewater_1:hydroobject'
    fn = os.path.join(tmpdir, 'hydrobjects.csv')
    srs = 28992
    fn = clipfromwfs(wfs, layer, bbx, fn, srs, 'csv')
    return fn


# Temporary folder setup
tmpdir = r'd:\temp\nhi'
# define bounding box
bbx = (145300, 389795, 149665, 393415)
# create generate file for the window of calculation
fncsv = writewfs2csv(bbx, tmpdir)
