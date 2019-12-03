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

# $Id: opendap_nhi.py 13800 2017-10-10 07:50:22Z sala $
# $Date: 2017-10-10 09:50:22 +0200 (Tue, 10 Oct 2017) $
# $Author: sala $
# $Revision: 13800 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/onlinemodelling/opendap_nhi.py $
# $Keywords: $

"""
Created on Tue Oct 13 14:22:36 2015
NHI Opendap Accessor
"""

import math
from pyproj import Proj, transform
import numpy as np
from netCDF4 import Dataset
import logging

# Get spreidingslengte values for a X,Y and layer
def nhi_spreidingslengte_XYL(x, y, layer):
    # Urls Opendap
    url_vert_res = '''http://opendap-nhi-data.deltares.nl/thredds/dodsC/opendap/Modellen/NHI/modelinvoer/verical_resistance/vertical_resistance_layer{}.nc'''.format(layer)
    url_transm = '''http://opendap-nhi-data.deltares.nl/thredds/dodsC/opendap/Modellen/NHI/modelinvoer/transmissivity/transmissivity_layer{}.nc'''.format(layer)

    # Get values
    c = get_opendap_value(x, y, url_vert_res)
    Kd = get_opendap_value(x, y, url_transm)
    sl = math.sqrt(Kd*c)
    return Kd, c, sl

# Loop around the levels
def find_spreidingslengte(x, y):
    for l in range(1,7):
        # Method 1 - With 1 access to opendap Matrix 3x3
        Kd1, c1, sl1 = nhi_spreidingslengte_BOX_3x3_odap(x, y, l)
        Kdm = np.mean(Kd1)
        cm = np.mean(c1)
        slm = np.mean(sl1)
        logging.info('layer=L{} - Spreidingslengte_3x3_mean: (x={}, y={}) => (Kd={}, c={}, sl={})'.format(l,x,y,Kdm,cm,slm))
        
        # Method 2 - With 9 access to opendap via XY coords
        # Kd2,c2,sl2 = nhi_spreidingslengte_BOX_3x3(x, y, l)
        # Kdm = np.mean(Kd2)
        # cm = np.mean(c2)
        # slm = np.mean(sl2)
        # logging.info('layer=L{} - Spreidingslengte_3x3_mean: (x={}, y={}) => (Kd={}, c={}, sl={})'.format(l,x,y,Kdm,cm,slm))

def zoetzout(x, y):
    "Returns zoetzout boundary."
    rdnew = Proj(init='epsg:28992')
    wgs84 = Proj(init='epsg:4326')
    nx, ny = transform(rdnew, wgs84, x, y)
    zoetzouturl = 'http://opendap-nhi-data.deltares.nl/thredds/dodsC/opendap/Modellen/NHI/modelresults/infoline3_cl_repos.nc'
    rdata = Dataset(zoetzouturl, 'r')
    xnear, xi = find_nearest(rdata['lon'][:], nx)
    ynear, yi = find_nearest(rdata['lat'][:], ny)

    r = rdata['Band1'][yi, xi]
    return r

def get_opendap_value(x, y, url):
    """Returns Band1 value from opendap for x,y."""
    rdata = Dataset(url, 'r')
    rdnew = Proj(init='epsg:28992')
    wgs84 = Proj(init='epsg:4326')
    nx, ny = transform(rdnew, wgs84, x, y)
    xnear, xi = find_nearest(rdata['lon'][:], nx)
    ynear, yi = find_nearest(rdata['lat'][:], ny)
    return rdata['Band1'][yi, xi]

def find_nearest(array, value):
    """Finds nearest value in array.
    taken from stack^ question 2566412"""
    idx = (np.abs(array - value)).argmin()
    return array[idx], int(idx)

def nhi_invoer(x, y, layers=range(1, 7)):
    """Returns values for each NHI model input layer."""

    # Transform coordinates
    rdnew = Proj(init='epsg:28992')
    wgs84 = Proj(init='epsg:4326')
    nx, ny = transform(rdnew, wgs84, x, y)

    results = {}
    for layer in layers:
        results[layer] = []

        # Urls used for input parameters
        #top_url = 'http://opendap-nhi-data.deltares.nl/thredds/dodsC/opendap/Modellen/NHI/modelinvoer/tops_bottoms/top_impermeable_layer_{}.nc'.format(
        #    layer)
        top_url = 'http://opendap-nhi-data.deltares.nl/thredds/dodsC/opendap/Modellen/NHI33/modelinvoer/tops_bottoms/top_sdl{}_m.nc'.format(
            layer)
        base_url = 'http://opendap-nhi-data.deltares.nl/thredds/dodsC/opendap/Modellen/NHI33/modelinvoer/tops_bottoms/bot_sdl{}_m.nc'.format(
            layer)
        #base_url = 'http://opendap-nhi-data.deltares.nl/thredds/dodsC/opendap/Modellen/NHI/modelinvoer/tops_bottoms/base_impermeable_layer_{}.nc'.format(
        #    layer)
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
                if not str(r) == '--':
                    results[layer].append(r)
                else:
                    logging.info("{} returned --".format(x))
                    results[layer].append(None)
            except:
                logging.error("Failed to open dataset {}".format(x))
                results[layer].append(None)
    return results

# ---------------------
# - 3x3 Box functions -
# ---------------------

def get_opendap_box_3x3(x, y, url):
    """Returns Band1 value from opendap for x,y."""
    rdata = Dataset(url, 'r')
    rdnew = Proj(init='epsg:28992')
    wgs84 = Proj(init='epsg:4326')
    cx, cy = transform(rdnew, wgs84, x, y)
    xnearn, xn = find_nearest(rdata['lon'][:], cx)
    ynearn, yn = find_nearest(rdata['lat'][:], cy)
    return rdata['Band1'][yn-1:yn+2, xn-1:xn+2] # 3x3 box from -1 to +1

# Get Opendap box [3x3 cells] - Matrix method via opendap
def nhi_spreidingslengte_BOX_3x3_odap(x, y, layer, N=3):
    # Urls Opendap
    url_vert_res = '''http://opendap-nhi-data.deltares.nl/thredds/dodsC/opendap/Modellen/NHI/modelinvoer/verical_resistance/vertical_resistance_layer{}.nc'''.format(layer)
    url_transm = '''http://opendap-nhi-data.deltares.nl/thredds/dodsC/opendap/Modellen/NHI/modelinvoer/transmissivity/transmissivity_layer{}.nc'''.format(layer)

    # Get values
    Mat_c = get_opendap_box_3x3(x, y, url_vert_res)
    Mat_Kd = get_opendap_box_3x3(x, y, url_transm)
    Mat_sl = np.matrix([[0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0]])

    # Get values
    for i in range(N):
        for j in range(N):
            Mat_sl.itemset((j,i), math.sqrt(Mat_Kd[j,i]*Mat_c[j,i]))
    return Mat_Kd, Mat_c, Mat_sl

# Get Opendap box [3x3 cells]
def nhi_spreidingslengte_BOX_3x3(x, y, layer, resolution=250, N=3):
    # Init
    Mat_c = np.matrix([[0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0]])
    Mat_Kd = np.matrix([[0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0]])
    Mat_sl = np.matrix([[0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0]])
    xaxis = [x - resolution, x, x + resolution]
    yaxis = [y - resolution, y, y + resolution]

    # Get values
    for i in range(N):
        for j in range(N):
            Kdv, cv, slv = nhi_spreidingslengte_XYL(xaxis[i], yaxis[j], layer)
            Mat_Kd.itemset((j,i), Kdv)
            Mat_c.itemset((j,i), cv)
            Mat_sl.itemset((j,i), slv)
    return Mat_Kd, Mat_c, Mat_sl

# TEST
if __name__ == "__main__":
    x = 148879
    y = 456710
    find_spreidingslengte(x, y)
