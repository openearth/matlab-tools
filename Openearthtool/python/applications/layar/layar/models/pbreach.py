#!/usr/bin/env python
import netCDF4
import shapely
import shapely.geometry
from pyproj import Proj, Geod
import numpy as np
import beaker.cache

import logging

log = logging.getLogger(__name__)

projstr = '+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.999908 +x_0=155000 +y_0=463000 +ellps=bessel +units=m +towgs84=565.4174,50.3319,465.5542,-0.398957388243134,0.343987817378283,-1.87740163998045,4.0725 +no_defs'
pa = Proj(projstr)
g = Geod(ellps='WGS84')

class Breach(object):
    def __init__(self, f):
        ds = netCDF4.Dataset(f)
        lat = ds.variables['lat'][:]
        lon = ds.variables['lon'][:]
        p  = ds.variables['P_f'][:,1]   # 2nd limit state is the one we want
        ds.close()
        self.data = dict(
            lat=lat,
            lon=lon,
            p=p)
    @beaker.cache.cache_region('short_term', 'multipoints')
    def getmultipoints(self):
        """return projected points"""
        return shapely.geometry.multipoint.MultiPoint(points=zip(self.data['lon'], self.data['lat']))
    def intersect(self, lat, lon, radius):
        """compute the intersection if the given latitude with the points"""
        # let's compute a radius in arcs so we can compare it with lat lon's
        # first compute the radius in meters
        # transform lat lon to x,y (Dutch only)
        x,y = pa(lon,lat)
        
        lon2, lat = pa(x+radius, y, inverse=True)
        arcradius = abs(lon2 - lon)
        point = shapely.geometry.point.Point(lon,lat)
        print arcradius, len(self.getmultipoints()), lat, lon
        circle = point.buffer(arcradius)
        intersect = self.getmultipoints().intersection(circle)
        if len(intersect) > 0:
            lon, lat  = np.asarray(intersect).T
            idx = np.logical_and(
                np.in1d(self.data['lat'], lat), # find lat idx
                np.in1d(self.data['lon'], lon)  # find lon idx
                )
            p = self.data['p'][idx]
        else:
            lat = lon = p = []
        return {'lat':lat, 'lon':lon, 'p':p}
    def intersect2(self, lat, lon, radius):
        """compute the radius with all points"""
        (azimuthfwd, azimuthbckwd, distance) =  g.inv(
            self.data['lon'],
            self.data['lat'],
            np.ones(self.data['lon'].shape)*lon,
            np.ones(self.data['lat'].shape)*lat
            )
        (idx,) = np.where(distance < radius)
        if len(idx) > 0:
            result = dict(
                lon=self.data['lon'][idx],
                lat=self.data['lat'][idx],
                p=self.data['p'][idx]
                )
        else:
            result = dict(
                lat=[],
                lon=[],
                p=[]
                )
        return result
                
             
if __name__ == '__main__':
    b = Breach('../../data/year_2008extra.nc')
    
    
    
