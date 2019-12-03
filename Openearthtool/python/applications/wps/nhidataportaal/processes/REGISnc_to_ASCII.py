# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2015 Deltares
#       Gerrit Hendriksen
#
#       gerrit.hendriksen@deltares.nl
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
# your own tools


import netCDF4
import numpy as np
import time
import logging
import sys
import os


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


def write_to_ASCII(SOURCE, path, bbox, LAYERS, epsg):

    # Open netCDF
    nc = netCDF4.Dataset(SOURCE)
    nc.set_always_mask(True)
    cs = 100
    x = nc.variables['x'][:]  # lists with proj coordinates indices
    y = nc.variables['y'][:]
    HEADER, bbidx = calcdimensions(bbox, cs, x, y, epsg)

    # Initialize program
    #print("Start of program...")

    """naming convention
    [layer][i]_parameter

    where parameter is:
    - kD (transmissivity)
    - t (top)
    - b (bottom)
    - kh (horizontal transmissivity)
    etc
    """

    forms = []
    formations = nc.variables['layer'][:]
    for formation in formations:
        form = "".join(formation)
        forms.append(form)

    # Retrieve data
    num = 0
    for layer in LAYERS:
        for idx, form in zip(range(0, 132), forms):
            # Record progress
            progress = float(num)/(len(LAYERS)*132)*100
            sys.stdout.write("\rProgress: {:5.2f}%".format(progress))
            data = np.flip(
                nc.variables[layer][idx, bbidx[2]:bbidx[3], bbidx[0]:bbidx[1]], 0)

            # check if data is not only 0
            if data.data.argmax() != 0:  # returns the idices of the max values in the array (so if all the same returns 0)
                # print " not empty"
                # Check if formation folder already exists
                folder = os.path.join(path, 'output/{0}'.format(form))
                if not(os.path.isdir(folder)):
                    os.makedirs(folder)

                # Create filec
                if (len(layer) > 2):
                    filename = os.path.join(
                        path, 'output/{0}/{0}_{1}.asc'.format(form, layer[0]))
                else:
                    filename = os.path.join(
                        path, 'output/{0}/{0}_{1}.asc'.format(form, layer))

                # Add headers
                content = []
                with open(filename, 'w') as f:
                    for (name, value) in HEADER:
                        content.append(" ".join([name, str(value)]))
                    header = "\n".join(content) + "\n"
                    f.write(header)

                # Retrieve data
                with open(filename, 'ab') as f:
                    np.savetxt(f, data, delimiter=' ', fmt='%d')
            else:
                # print " empty"
                pass

            # Proceed
            num += 1

    sys.stdout.write("\rProgress: 100.00%\n")
    # Close netCDF
    nc.close()
#
# if __name__ == "__main__":
#    SOURCE = "http://www.dinodata.nl:80/opendap/REGIS/REGIS.nc"
#    path = r'D:\TEMP'
#    bbox = (621446,6707268,630757,6730545)
#    epsg = 'epsg:3857'
#    LAYERS = ['kD', 'kh','top','bottom']
#    write_to_ASCII(SOURCE,path,bbox,LAYERS,epsg)
