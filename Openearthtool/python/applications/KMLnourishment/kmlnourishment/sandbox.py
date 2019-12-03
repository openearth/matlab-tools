# -*- coding: utf-8 -*-
"""
Created on Fri May 17 15:49:51 2013

@author: heijer
"""
import numpy as np
from netCDF4 import Dataset,num2date
import simplekml
from scipy import interpolate
from jarkus.transects import Transects

ncname  = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/suppleties/suppleties.nc'
contour = -3
kml = simplekml.Kml()

nourishment_idx = 4
for nourishment_idx in [35,238,375]:#np.arange(379):
    try:
        ds = Dataset(ncname)
        #nour_type = ds.variables['type'][nourishment_idx,]
        #print len(nour_type[~nour_type.mask]),len(nour_type.mask)
        stretch = ds.variables['stretch'][nourishment_idx,]
        ds.close()
        
        Jk = Transects()
        ids = Jk.get_data('id')
        ac = Jk.get_data('areacode')
        #print nourishment_idx,stretch,np.floor(stretch[0]/1e6)
        #print ac[639:642]==np.floor(stretch[0]/1e6)
        #print stretch
        id0 = int(np.floor(np.interp(stretch.min(), ids, np.arange(len(ids)))))
        id1 = int(np.ceil(np.interp(stretch.max(), ids, np.arange(len(ids)))))
        Jk.set_filter(alongshore=np.logical_and(np.arange(len(ids))>=id0, np.arange(len(ids))<id1))
        Jk.set_filter(time=-2)
        cs = Jk.get_data('cross_shore')
        #print Jk.get_data('id')
        MKL = Jk.MKL(lower=contour-1,upper=contour+1)
        print MKL
        xMKL = np.ma.masked_invalid(MKL[0])
        meanx = xMKL.mean()
        print 'meanx',meanx, type(meanx) == np.float64
        if type(meanx) != np.float64:
            meanx = 0
        print 'meanx',meanx
        base = 5
        csinner = int(base * np.round(meanx/base))
        Jk.set_filter(cross_shore=np.logical_or(cs==csinner,cs==csinner+100))
        lat = Jk.get_data('lat')
        lon = Jk.get_data('lon')
        Jk.close()
        pol = kml.newpolygon(name='nourishment_%03i.kml'%nourishment_idx,
                         outerboundaryis=zip(np.concatenate((lon[:,0], lon[::-1,1])), np.concatenate((lat[:,0], lat[::-1,1]))))
        pol.description = 'nourishment_%03i.kml'%nourishment_idx
    except:
        print nourishment_idx, 'error'
    print nourishment_idx,stretch, id0,id1,np.interp(stretch.min(), ids, np.arange(len(ids))),np.interp(stretch.max(), ids, np.arange(len(ids)))

kml.save('nourishments.kml')