# -*- coding: utf-8 -*-
#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares for <projectdata>
#       Lilia Angelova, Gerrit Hendriksen
#
#       Lilia.Angelova@deltares.nl,gerrit.hendriksen@deltares.nl
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

import netCDF4
import numpy as np
import time
import sys
import os
import xarray as xr

#from arr2idf import *
from .imod_package import write


def change_coords(px, py, epsgin='epsg:3857', epsgout='epsg:28992'):
    from pyproj import Proj, transform
    outProj = Proj(init=epsgout)
    inProj = Proj(init=epsgin)
    return transform(inProj, outProj, px, py)


def calcindx(BB, x, y):
    xidx1 = list(x.data).index(BB['x'][0])
    yidx1 = list(y.data).index(BB['y'][0])
    xidx2 = list(x.data).index(BB['x'][1])
    yidx2 = list(y.data).index(BB['y'][1])
    bbidx = (xidx1, xidx2, yidx1, yidx2)
    return bbidx


def calcdimensions(bbox, cs, x, y, epsg):
    xmin, ymin = change_coords(bbox[0], bbox[1], epsg)
    xmax, ymax = change_coords(bbox[2], bbox[3], epsg)
    xmin = round((xmin-cs)/cs) * cs
    ymin = round((ymin-cs)/cs) * cs
    xmax = round((xmax+cs)/cs) * cs
    ymax = round((ymax+cs)/cs) * cs
    BB = dict(x=[xmin, xmax],
              y=[ymin, ymax])
    bbidx = calcindx(BB, x, y)
    HEADER = [('NCOLS', (xmax-xmin)/cs),
              ('NROWS', (ymax-ymin)/cs),
              ('XLLCORNER', xmin),
              ('YLLCORNER', ymin),
              ('CELLSIZE', 100),
              ('NODATA_VALUE', -9999)]
    return HEADER, bbidx


def write_to_IDF(SOURCE, path, bbox, LAYERS, epsg='3857'):
    # Open netCDF
    nc = netCDF4.Dataset(SOURCE)
    nc.set_always_mask(True)
    cs = 100
    x = nc.variables['x'][:]  # lists with proj coordinates indices
    y = nc.variables['y'][:]

    HEADER, bbidx = calcdimensions(bbox, cs, x, y, epsg)

    # Initialize program

    forms = []
    formations = nc.variables['layer'][:]
    for formation in formations:
        form = "".join(formation)
        forms.append(form)
    # Retrieve data
    for layer in LAYERS:
        for idx, form in zip(range(0, 132), forms):
            # Record progress
            # progress = float(num)/(len(LAYERS)*132)*100
            # sys.stdout.write("\rProgress: {:5.2f}%".format(progress))

            #data = np.flip(nc.variables[layer][idx,bbidx[2]:bbidx[3],bbidx[0]:bbidx[1]], 0)
            data = nc.variables[layer][idx, bbidx[2]:bbidx[3], bbidx[0]:bbidx[1]]

            # check if data is not only 0
            if data.data.argmax() != 0:  # returns the idices of the max values in the array (so if all the same returns 0)

                # IPF
                # retrieve coords
                x_subset = nc.variables['x'][bbidx[0]:bbidx[1]]
                y_subset = np.flip(nc.variables['y'][bbidx[2]:bbidx[3]], 0)
                # add 50.0 - xarray midpoint of grid not start?
                x_subset2 = x_subset.data + 50.0
                y_subset2 = y_subset.data + 50.0

                # imod package works with xarray
                a = xr.DataArray(
                    data, coords={"y": y_subset2, "x": x_subset2}, dims=('y', 'x'))
                path_to_f = os.path.join(path, "{}_{}.idf".format(form, layer))
                #path_to_f = r'C:\Users\angelova\OneDrive - Stichting Deltares\Desktop\REGIS\idf_output\{}_{}.idf'.format(form,layer)
                write(path_to_f, a)

    nc.close()

# if __name__ == "__main__":
#    SOURCE = "http://www.dinodata.nl:80/opendap/REGIS/REGIS.nc"
#    path = "D:\webserver\Apache24\htdocs\ddv2\gmdb\downloads"
#    bbox = (621446,6707268,630757,6730545)
#    LAYERS = ['kD', 'kh','top','bottom']
#    write_to_IDF(SOURCE,path,bbox,LAYERS)
