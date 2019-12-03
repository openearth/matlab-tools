# -*- coding: utf-8 -*-
"""
$Id: models.py 9157 2013-08-30 15:06:34Z heijer $
$Date: 2013-08-30 08:06:34 -0700 (Fri, 30 Aug 2013) $
$Author: heijer $
$Revision: 9157 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/KMLnourishment/kmlnourishment/models.py $
"""

import numpy as np
from netCDF4 import Dataset,num2date
import simplekml
from scipy import interpolate
from jarkus.transects import Transects

ncname  = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/suppleties/suppleties.nc'

def readnc_locations():
    """
    crawl the netcdf file and return a reference point for each nourishment
    """
    nc = Dataset(ncname)
    
    # read alongshore locations of beginning and end of nourishment stretch
    ID_stretch = nc.variables['stretch'][:]
    # read time information
    time = nc.variables['date']
    t = num2date(time[:], time.units)
    
    mask_stretch = np.ma.masked_invalid(ID_stretch)
    rowmask = np.logical_or(mask_stretch.mask[:,0],mask_stretch.mask[:,1])
    
    # call id and lat lon
    jarkusID = nc.variables['id'][:]
    lat = nc.variables['rsp_lat'][:]
    lon = nc.variables['rsp_lon'][:]
    
    nc.close()
    
    # convert the jarkus id to float (to compare with id_beg and id_end)
    jarkusIDfloat = np.array(jarkusID, dtype = 'f')
    print jarkusIDfloat.shape
    stretchIDfloat = np.array(ID_stretch[~rowmask,], dtype = 'f')
    print stretchIDfloat.shape
    
    idxbeg = np.empty(stretchIDfloat.shape[0], dtype=int)
    idxend = idxbeg.copy()
    
    idxs = np.arange(len(jarkusIDfloat))
    f = interpolate.interp1d(jarkusIDfloat, idxs, kind='nearest', bounds_error=False)
    for i,item in enumerate(stretchIDfloat):
        idx = np.asarray(f(item), dtype=int)
        idxbeg[i] = int(idx[0])
        idxend[i] = int(idx[1])
    
    # get the lat and lon of the nourishments
    lat_beg = lat[idxbeg]
    lon_beg = lon[idxbeg]
    lat_end = lat[idxend]
    lon_end = lon[idxend]

    # evaluate the mean of the stretch
    meanLat, meanLon = map(np.mean, zip(lat_beg,lat_end)), map(np.mean, zip(lon_beg,lon_end))
    idxs = map(lambda idx: 'nourishment_%03i'%idx, np.nonzero(~rowmask)[0])
    lonlats = zip(meanLon, meanLat)
    return lonlats, idxs, t[~rowmask]

def createkml_overview(code):
    """
    function to create an overview kml that includes links to all individual nourishments
    """
    nourishment_locations,nourishment_idxs,nourishment_times = readnc_locations()
    #print nourishment_locations,nourishment_idxs

    kml = simplekml.Kml()
    
    for loc,idx,t in zip(nourishment_locations,nourishment_idxs,nourishment_times):
        #link = kml.newnetworklink(name=idx)
        point = kml.newpoint(name=idx)
        margin = 2.
        lon,lat = loc[0],loc[1]
        box = simplekml.LatLonBox(north=lat+margin, south=lat-margin, west=lon-margin, east=lon+margin)
        lod = simplekml.Lod(minlodpixels=512)
        region = simplekml.Region(box, lod)
        point.coords = [loc,]
        point.region = region
        point.timespan.begin = t[0].strftime('%Y-%m-%d')
        point.timespan.end = t[1].strftime('%Y-%m-%d')
        
        print type(idx),idx
        link = kml.newnetworklink(name=idx)
        box = simplekml.LatLonBox(north=lat+margin, south=lat-margin, west=lon-margin, east=lon+margin)
        lod = simplekml.Lod(minlodpixels=512)
        region = simplekml.Region(box, lod)
        link.region = region
        link.timespan.begin = t[0].strftime('%Y-%m-%d')
        link.timespan.end = t[1].strftime('%Y-%m-%d')
        link.link.href = "http://localhost:6543/kml/%s.kml"%idx
        link.link.viewrefreshmode = simplekml.ViewRefreshMode.onregion
    
    return kml

def createkml_nourishment(nourishment_idx):
#    ds = Dataset(ncname)
#    print ds.variables['type'][nourishment_idx,]
#    print ds.variables['stretch'][nourishment_idx,]
#    ds.close()
#    
#    Jk = Transects()
#    ids = Jk.get_data('id')
#    Jk.close()
    contour = -3
    
    #nourishment_idx = 323
    ds = Dataset(ncname)
    #nour_type = ds.variables['type'][nourishment_idx,]
    stretch = ds.variables['stretch'][nourishment_idx,]
    ds.close()
    
    Jk = Transects()
    ids = Jk.get_data('id')
    id0 = int(np.floor(np.interp(stretch.min(), ids, np.arange(len(ids)))))
    id1 = int(np.ceil(np.interp(stretch.max(), ids, np.arange(len(ids)))))
    Jk.set_filter(alongshore=np.logical_and(np.arange(len(ids))>=id0, np.arange(len(ids))<=id1))
#    Jk.set_filter(alongshore=np.logical_and(ids>=stretch.min(), ids<=stretch.max()))
    Jk.set_filter(time=-1)
    cs = Jk.get_data('cross_shore')
    MKL = Jk.MKL(lower=contour-1,upper=contour+1)
    xMKL = np.ma.masked_invalid(MKL[0])
    meanx = xMKL.mean()
    base = 5
    csinner = int(base * np.round(meanx/base))
    Jk.set_filter(cross_shore=np.logical_or(cs==csinner,cs==csinner+100))
    lat = Jk.get_data('lat')
    lon = Jk.get_data('lon')
    Jk.close()
    
    kml = simplekml.Kml()
    pol = kml.newpolygon(name='test',
                         outerboundaryis=zip(np.concatenate((lon[:,0], lon[::-1,1])), np.concatenate((lat[:,0], lat[::-1,1]))))
    
    #print nourishment_idx
    #kml = simplekml.Kml()
    
    return kml