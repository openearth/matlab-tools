# -*- coding: utf-8 -*-
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

# $Id: opendap_nhi.py 12740 2016-05-20 09:21:14Z pronk_mn $
# $Date: 2016-05-20 11:21:14 +0200 (Fri, 20 May 2016) $
# $Author: pronk_mn $
# $Revision: 12740 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/infoline/opendap_nhi.py $
# $Keywords: $

"""
Created on Tue Oct 13 14:22:36 2015
NHI Opendap Accessor
"""

from pyproj import Proj, transform
import numpy as np
from netCDF4 import Dataset
import psycopg2
from shapely.geometry import Point
from operator import itemgetter
import logging


def zoetzout(x, y):
    "Returns zoetzout boundary."
    rdnew = Proj(init='epsg:28992')
    wgs84 = Proj(init='epsg:4326')
    nx, ny = transform(rdnew, wgs84, x, y)

    zoetzouturl = 'http://opendap-nhi-data.deltares.nl/thredds/dodsC/opendap/Modellen/NHI/modelresults/infoline3_cl_repos.nc'

    rdata = Dataset(zoetzouturl, 'r')
    xnear, xi = find_nearest(rdata['lon'][:], nx)
    ynear, yi = find_nearest(rdata['lat'][:], ny)
    #r = rdata['Band1'][xi, yi]
    r = rdata['Band1'][yi, xi]
    return r


def find_nearest(array, value):
    """Finds nearest value in array.
    taken from stack^ question 2566412"""
    idx = (np.abs(array - value)).argmin()
    return array[idx], int(idx)


def nhi_invoer(x, y, layers=range(1, 7)):
    """Returns values for each NHI model input layer."""

    # Only 6 layers available.
    # if not (1 <= int(layer) <= 6):
    #   print("Not a valid layer!")
    #   return None

    # Transform coordinates
    rdnew = Proj(init='epsg:28992')
    wgs84 = Proj(init='epsg:4326')
    nx, ny = transform(rdnew, wgs84, x, y)

    results = {}
    for layer in layers:
        results[layer] = []

        # Urls used for input parameters
        top_url = 'http://opendap-nhi-data.deltares.nl/thredds/dodsC/opendap/Modellen/NHI/modelinvoer/tops_bottoms/top_impermeable_layer_{}.nc'.format(
            layer)
        base_url = 'http://opendap-nhi-data.deltares.nl/thredds/dodsC/opendap/Modellen/NHI/modelinvoer/tops_bottoms/base_impermeable_layer_{}.nc'.format(
            layer)
        ghg_url = 'http://opendap-nhi-data.deltares.nl/thredds/dodsC/opendap/Modellen/NHI/modelresults/ghg_1998-2006_l{}.nc'.format(
            layer)
        glg_url = 'http://opendap-nhi-data.deltares.nl/thredds/dodsC/opendap/Modellen/NHI/modelresults/glg_1998-2006_l{}.nc'.format(
            layer)

        flf_url = 'http://opendap-nhi-data.deltares.nl/thredds/dodsC/opendap/Modellen/NHI/modelresults/flf_mean_19980101-20070101_mm_l{}.nc'.format(
            layer)

        for i, x in enumerate([flf_url, ghg_url, glg_url, top_url, base_url]):
            try:
                rdata = Dataset(x, 'r')
                if i == 0:
                    xnear, xi = find_nearest(rdata['lon'][:], nx)
                    ynear, yi = find_nearest(rdata['lat'][:], ny)

                r = rdata['Band1'][yi, xi]
                # print r, i, x
                if not str(r) == '--':
                    results[layer].append(r)
                else:
                    logging.info("{} returned --".format(x))
                    results[layer].append(None)
            except:
                logging.error("Failed to open dataset {}".format(x))
                results[layer].append(None)
    return results


#if __name__ == "__main__":
#    x = 148879
#    y = 456710
#    print nhi_invoer(x, y)
#    print zoetzout(x, y)
