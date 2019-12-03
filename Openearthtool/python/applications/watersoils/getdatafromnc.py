# -*- coding: utf-8 -*-
"""
Created on Tue Aug 11 16:23:53 2015

Populate Infoline read netcs
"""
#  Copyright notice
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
# your own tools.

# $Id: getdatafromnc.py 12178 2015-08-17 10:49:07Z hendrik_gt $
# $Date: 2015-08-17 12:49:07 +0200 (Mon, 17 Aug 2015) $
# $Author: hendrik_gt $
# $Revision: 12178 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/infoline/getdatafromnc.py $
# $Keywords: $


import numpy as np
import netCDF4
import logging

url = r'd:\data\geotop.nc'
"""data originates from http://www.dinodata.nl/opendap/GeoTOP/contents.html, opendap does not seem to work,
   if opendap link works above path should be replaced by that path, or for performance and convenience leave it like this.
"""

dataset = netCDF4.Dataset(url)
variables = dataset.variables

def test():
    anx = 148879
    any = 456710
    anz = -10
    
    print getvalues(anx,any,anz)

"""http://stackoverflow.com/questions/8914491/finding-the-nearest-value-and-return-the-index-of-array-in-python"""
def find_closest(A, target):
    #A must be sorted
    idx = A.searchsorted(target)
    idx = np.clip(idx, 1, len(A)-1)
    left = A[idx-1]
    right = A[idx]
    idx -= target - left < right - target
    return idx

def getvalues(anx,any,anz):
    listvars = ['crs', 'x', 'y' ,'z']
    
    x = variables['x'][:]
    y = variables['y'][:]
    z = variables['z'][:]
    
    idx = find_closest(np.sort(x),anx)
    idy = find_closest(np.sort(y),any)
    idz = find_closest(np.sort(z),anz)
    lstvals = []
    for var in variables:
        try:
            listvars.index(var)
        except ValueError:
            #print ' '.join([var, variables[var].long_name, str(variables[var][idx,idy,idz])])
            #logging.info(' '.join([var, variables[var].long_name, str(variables[var][idx,idy,idz]]))
            lstvals.append(' '.join([var, variables[var].long_name, str(variables[var][idx,idy,idz])]))
    return lstvals