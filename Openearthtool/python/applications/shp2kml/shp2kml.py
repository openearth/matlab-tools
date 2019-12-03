# -*- coding: utf-8 -*-
"""
Created on Tue May 21 21:06:17 2013

@author: drs.Ing. Gerrit Hendriksen

@purpose:
     This Script creates a KML from a shapefile. 
     
@requirements:
    - ogr
    - simplekml
    - shapely
    - currently only works with shapefile in WGS
    - currently only works with polygons

@references:
    http://gis.stackexchange.com/questions/10033/python-efficiency-need-suggestions-about-how-to-use-ogr-and-shapely-in-more-e
    http://simplekml.readthedocs.org
"""

import simplekml
import ogr
from shapely.wkb import loads


# create the kml file
kml = simplekml.Kml(open=1)
pfol = kml.newfolder(name="title")


# consider there is only one layer available, which is always the case in a shapefile
# mind, this scripts only works with WGS, if desired a reprojection can be done
ashp = r'awgshape.shp'
openShape = ogr.Open((ashp))

layers = openShape.GetLayerByIndex(0)
i = 0
for element in layers:
    geom = loads(element.GetGeometryRef().ExportToWkb())
    i=i+1
    arrcoords = geom.to_wkt()
    # the part that creates the kml
    pol = pfol.newpolygon()
    pol.visibility = 0
    # 'trans Blue Poly'
    pol.style.polystyle.color = '7d00ff00'
    pol.altitudemode = 'relativeToGround'
    pol.extrude = 1
    #pol.outerboundaryis = ([(x1,y1),(x2,y2),(x3,y3),(x4,y4),(x1,y1)])
    coords = arrcoords.replace('POLYGON','').replace('(','').replace(')','')
    coords = coords.replace('MULTI','')
    coords = coords.split(',')
    asize = 1
    pol.outerboundaryis = ([(float(coords[j].split()[0]),float(coords[j].split()[1]),asize) for j in range(len(coords))])
       

openShape = None
layers = None

# save the kml
kml.save(r'akmlfile')
