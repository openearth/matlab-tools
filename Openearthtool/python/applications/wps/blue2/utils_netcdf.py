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

# $Id: utils_netcdf.py 14127 2018-01-30 07:21:10Z hendrik_gt $
# $Date: 2018-01-30 08:21:10 +0100 (Tue, 30 Jan 2018) $
# $Author: hendrik_gt $
# $Revision: 14127 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/blue2/utils_netcdf.py $
# $Keywords: $

import netCDF4
import numpy as np

def getAllVariableNames(fname):
    """ Gets all variables titles """
    dset = netCDF4.Dataset(fname)
    return dset.variables.keys() 

def getAllVariableNameswithTime(fname):
    """ Gets all variables with 3 dimensions at least """
    dset = netCDF4.Dataset(fname)
    datavars = []
    for key, value in dset.variables.iteritems():
        if value.ndim > 2:
            datavars.append(key)
    return datavars

def getAllVariables(fname):
    """ Gets all variables metadata """
    dset = netCDF4.Dataset(fname)
    datavars = {}
    for key, value in dset.variables.iteritems():
        if value.ndim > 2:
            datavars[key] = value
    return datavars    

def find_nearest(array, value):
    """Finds nearest value in array."""
    idx = (np.abs(array - value)).argmin()
    return array[idx], int(idx)

def getDataLatLonV(lat, lon, varname, fname):
    """Returns height from maaiveld from opendap for x,y."""
    rdata = netCDF4.Dataset(fname, 'r')     
    xnear, xi = find_nearest(rdata['lonc'][:], lon)
    ynear, yi = find_nearest(rdata['latc'][:], lat)
    return rdata[varname][0, yi, xi]

def getTseriesLatLonV(lat, lon, varname, fname):
    """Returns height from maaiveld from opendap for x,y."""
    rdata = netCDF4.Dataset(fname, 'r')     
    xnear, xi = find_nearest(rdata['lonc'][:], lon)
    ynear, yi = find_nearest(rdata['latc'][:], lat)
    return rdata[varname][0:-1, yi, xi]

def getTimeSteps(fname):
    """Returns height from maaiveld from opendap for x,y."""
    rdata = netCDF4.Dataset(fname, 'r')     
    tname = "time"
    nctime = rdata.variables[tname][:] # get values
    t_unit = rdata.variables[tname].units # get unit  "days since 1950-01-01T00:00:00Z"
    t_cal = u"gregorian" # or standard
    return netCDF4.num2date(nctime, units=t_unit, calendar=t_cal)

if __name__ == "__main__":

    fname = r"D:\NETCDF_DATA\MMF\medsea_5x5_fabm_1989_04.3d.nc"
    
    lat = 38.3
    lon = 17.9

    # For all variables
    print getAllVariableNameswithTime(fname)