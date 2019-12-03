import numpy as np
import math

from pyproj import Proj
from pyproj import transform

# coordinate definitions
Projections = { \
               'RD':("+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.999908 +x_0=155000 +y_0=463000 +ellps=bessel +towgs84=565.237,50.0087,465.658,-0.406857,0.350733,-1.87035,4.0812 +units=m +no_defs"), \
               'GOOGLE':("+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs +over"), \
               'WGS84':("+proj=latlong +datum=WGS84") \
}

def transform_coords(from_coord,to_coord,x,y):
    if not x.size == y.size or x.ndim < 2:
        X, Y = np.meshgrid(x, y)
    else:
        X = x
        Y = y
        
    if from_coord in Projections and to_coord in Projections:
        x, y = transform(Proj(Projections[from_coord]), Proj(Projections[to_coord]), X, Y)
    
    return x, y

def get_latlon(dataset):
    if 'lat' in dataset.variables and 'lon' in dataset.variables:
        lat = dataset.variables['lat'][:]
        lon = dataset.variables['lon'][:]
    else:
        if 'x' in dataset.variables and 'y' in dataset.variables:
        
            x = dataset.variables['x'][:]+dataset.attributes['PARAMS']['xori']
            y = dataset.variables['y'][:]+dataset.attributes['PARAMS']['yori']
            
            lon, lat = transform_coords(dataset.attributes['PARAMS']['coordsys'], 'WGS84', x, y)
        else:
            assert False, "No coordinate system defined"
            
    return (lat,lon)

def get_rotation(lat,lon):
    return math.atan2((lat.max()-lat.min()), (lon.max()-lon.min()))