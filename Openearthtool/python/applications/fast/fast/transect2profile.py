#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2014 Deltares for FAST project
#       Giorgio Santinelli
#
#       giorgio.santinelli@deltares.nl
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

# $Id$
# $Date$
# $Author$
# $Revision$
# $HeadURL$
# $Keywords$


import logging

from scipy import interpolate
import netCDF4
import numpy as np

demfile = r'http://fast.openearth.eu/thredds/dodsC/fast/thredds/Spain/dem_bath_clip_wgs84.nc'


def transect2profile(url, lat0, lon0, lat1, lon1):
    """
    returns a profile from start and end of it

    >>> url = 'http://fast.openearth.eu/thredds/dodsC/fast/thredds/Spain/dem_bath_clip_wgs84.nc'
    >>> lat0 = 36.399
    >>> lon0 = -6.2
    >>> lat1 = 36.4
    >>> lon1 = -6.0
    >>> transect2profile(url, lat0, lon0, lat1, lon1)
    aaa
    """
    logging.info(url)
    ds = netCDF4.Dataset(url)
    lat = ds.variables['lat'][:]
    lon = ds.variables['lon'][:]

    # take  a subset
    id_lat = np.arange(np.abs(lat-lat0).argmin(), np.abs(lat-lat1).argmin()+1)
    id_lon = np.arange(np.abs(lon-lon0).argmin(), np.abs(lon-lon1).argmin()+1)

    Zsub = ds.variables['Band1'][id_lat, id_lon]
    ds.close()

    ## use arange for a subset ?
    latsub = lat[id_lat]
    lonsub = lon[id_lon]

    xii = lonsub
    yii = latsub

    if '_fillvalue' in Zsub:
        Zsub.data[Zsub.data == Zsub._fillvalue] = 0
        Zii = Zsub.data
    else:
        Zii = Zsub

    # Do the interpolation

    # This should be ciruclar...
    f = interpolate.RectBivariateSpline(yii, xii, Zii, kx=1, ky=1, s=0)

    TR_lon = np.linspace(lon0, lon1, num=1e3)
    TR_lat = np.linspace(lat0, lat1, num=1e3)
    znew = f(TR_lat, TR_lon)
    return TR_lon, TR_lat, znew[0]


if __name__ == '__main__':
    import doctest
    doctest.testmod()
