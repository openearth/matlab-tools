#===========================
#Earth Engine Load Function
#===========================
#JFriedman
#June 17/2015
#==============================

#import all necessary packages
#=============================
import ee
ee.Initialize()
#import re
import os
import json
from . import aoiExtract as AOI
from . import ioFuncs as IO

def projLocation(inputType,name,curr,projdir):

    if inputType is 'OSM':
        lats = [35.15, 35.16]   #bounds for latitude [deg N]
        lons = [129.154, 129.17]     #bounds for longitude [deg E]
        EPSGcode = 3092         #EPSG code for converting coordinates (XY <-> Lat/lon)
        buffer_dist = 150       #buffer distance around OSMaps coastline [m]
        buffer_bounds = AOI.SHELL(name,lats,lons,EPSGcode,buffer_dist,curr) #extract the AOI bounds
        
    #special case for multiple geometries (i.e. multipolygons)
    elif inputType is 'geojson':
        infile = [file for file in os.listdir(projdir) if ".geojson" in file][0] #get first *.json file
        with open(os.path.join(projdir,infile), 'r') as f: #read json data into bounds
             buffer_bounds = json.load(f) 
            
        aoi = ee.FeatureCollection(ee.Feature(buffer_bounds).buffer(0,1e-10)) #build ee polygon into feature collection (buffer fixed polygon)    
        image_bounds = ee.Geometry(buffer_bounds).bounds().getInfo()['coordinates'] #convert bounds into list for visualization        
        
#        #turn nested list of coordinates into nested list of TUPLES
#        p_start = re.compile(r'\[(?=[^\[])')
#        sub_start = '('
#        p_end = re.compile(r'\b\]')
#        sub_end = ')'
#          
#        bounds = re.sub(p_start, sub_start, str(bounds))
#        bounds = re.sub(p_end, sub_end, bounds)
#        bounds = eval(bounds)

    elif inputType is 'json':
        infile = [file for file in os.listdir(projdir) if ".json" in file][0] #get first *.json file
        with open(os.path.join(projdir,infile), 'r') as f: #read json data into bounds
             buffer_bounds = json.load(f)
        #bounds = [tuple(x) for x in bounds]   

    elif inputType is 'kml':
        buffer_bounds = IO.loadKML(projdir) #bounds is a list of lists

    #define the area of interest (AOI) for the feature collection + bounding box (region)
    if inputType is not 'geojson':
        #NOTE -> Polygon in EE must be COUNTERCLOCKWISE or its centroid is INCORRECT (results in errors due to wrong bounds in EE)
        aoi = ee.FeatureCollection(ee.Geometry.Polygon([buffer_bounds]).buffer(0,1e-10)) #build ee polygon into feature collection (buffer fixed polygon)    
        image_bounds = [[x[0],x[1]] for x in buffer_bounds] #convert bounds into list for visualization
        
    return aoi,image_bounds,buffer_bounds

    