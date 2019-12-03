#==============================
#OpenStreetMaps Functions
#==============================
#JFriedman
#June 17/2015
#==============================

#import all necessary packages
#=============================
import requests
import xml.etree.ElementTree as ET
import osmapi
from pyproj import Proj, transform

#convert to cartesian coordinates to determine possible zones
#============================================================
def ConvertCoordinates(EPSGin,EPSGout,x1,y1):
    
    inProj = Proj(init='epsg:%s' %EPSGin) #input projection
    outProj = Proj(init='epsg:%s' %EPSGout) #ouput projection
    xy = transform(inProj,outProj,x1,y1)
    return xy

#extract NODES from WAYS
#=======================
def ExtractNodes(MyApi,WayIds,EPSGcode):
    
    d = MyApi.WaysGet(WayIds)
    lon = [[MyApi.NodeGet(pt)['lon'] for pt in d[val]['nd']] for val in WayIds]
    lat = [[MyApi.NodeGet(pt)['lat'] for pt in d[val]['nd']] for val in WayIds]
    xy = [ConvertCoordinates(4326,EPSGcode,x,y) for x,y in zip(lon,lat)]
    return xy

#get codes in xml document from request
#======================================
def GetFeatureIDs(KEY,VAL,lons,lats):
    
    r = requests.get('http://www.overpass-api.de/api/xapi?way[%s=%s][bbox=%f,%f,%f,%f]' %(KEY,VAL,lons[0],lats[0],lons[1],lats[1]))
    root = ET.fromstring(r.text)
    WayIds = [int(child.get('id')) for child in root.findall('way')] #extract all "ways"
    return WayIds

#run specific functions depending on "way" vs. "relation"
#========================================================
def ExtractOSMFeatures(KEY,VAL,lons,lats,name,EPSGcode):
    
    WayIds = GetFeatureIDs(KEY,VAL,lons,lats)
    MyApi = osmapi.OsmApi() #get instance of API
    xy = ExtractNodes(MyApi,WayIds,EPSGcode)
    return xy #return projected coordinates for later analysis