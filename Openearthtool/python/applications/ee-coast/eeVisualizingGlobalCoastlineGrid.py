#=============================
#Visualizing Individual Boxes
#=============================
#JFriedman
#Sep 22/2015
#=============================

#==============================
# 0. INPUT REQUIRED PARAMETERS
#==============================
main_dir = r'.\output'
num_pix = 1000 #number of pixels for thumbnail image

#==================================
# 1. IMPORT ALL NECESSARY PACKAGES
#==================================

import os

#initialize Earth Engine
import ee
ee.Initialize()

#include any other required standard libraries
import json
from shapely.geometry import Polygon
import time
start_time = time.time() #for timing the code
import urllib2
from PIL import Image
from cStringIO import StringIO
from mpl_toolkits.basemap import Basemap
import matplotlib.pyplot as plt
plt.ioff() #turn off plots popping on screen

#=========================
# 2. LOAD GLOBAL DATASETS
#=========================

all_dirs = []
boxes = [d for d in os.listdir(main_dir) if os.path.isdir(os.path.join(main_dir, d))]
# boxes = ['BOX_029']

boxes.sort() #sort in place
for b in boxes:
    temp_dir = os.path.join(main_dir,b)
    search_boxes = [d for d in os.listdir(temp_dir) if os.path.isdir(os.path.join(temp_dir, d))]
    search_boxes.sort()
    all_dirs.extend([os.path.join(temp_dir,s) for s in search_boxes])

for search_dir in all_dirs:

    loop_time = time.time() #for timing the individual loop code

    #get name for figure
    namer = os.path.split(search_dir)[1]
    print('Currently Extracting: %s' %namer)

    #read json data into bounds
    with open(os.path.join(search_dir,namer+'.json'), 'r') as f: 
        aoi = json.load(f)
    bounds = ee.Geometry.Polygon(aoi)
    
    #check if ANY images exist (only check Landsat 8)
    bgIm = (ee.ImageCollection('LANDSAT/LC8_L1T_TOA').filterBounds(bounds.centroid(1)))
    
    imFlag = bgIm.toList(1).length().getInfo()
    
    #if there are absolutely NO images -> continue loop + make note in search_dir
    if not imFlag:
        
        print 'No Images Found!'
        fid = open(os.path.join(search_dir,'~NO_IMS.txt'),'w')
        fid.close()
        
        continue
     
    #check for a nice cloud-free background image
    bgIm = (ee.ImageCollection('LANDSAT/LC8_L1T_TOA')
        .filterBounds(bounds.centroid(1))
        .filterMetadata('CLOUD_COVER','less_than',15)
        .sort('CLOUD_COVER', True)
        .select(['B6','B5','B3']))
    
    #if cloud-free LC8 images do not exist (very rare) -> get the best LE7 image
    imFlag = bgIm.toList(1).length().getInfo()
    
    if not imFlag:
        bgIm = (ee.ImageCollection('LANDSAT/LE7_L1T_TOA')
        .filterBounds(bounds.centroid(1))
        .filterMetadata('CLOUD_COVER','less_than',20)
        .sort('CLOUD_COVER', True)
        .select(['B5','B4','B2']))   
    
    #visualize the background image
    visparams = {'min':0,'max':0.35,'gamma':1.5,'forceRgbOutput':True}
    bgIm = ee.Image(bgIm.first()).clip(bounds).visualize(**visparams)            

    # build composite image (i.e. mosaic) of all layers for debugging + reference
    bbox = bounds.getInfo()['coordinates']
    
    #in case the bounding box crosses the longitude edges (i.e. +180/-180)
    if bounds.type().getInfo() == 'MultiPolygon':

        #find the incorrect negative -180 coordinates
        min_loc = bbox.index(min(bbox))
        max_loc = bbox.index(max(bbox))
        xy_min = zip([x[0]+360 for x in bbox[min_loc][0]],[x[1] for x in bbox[min_loc][0]])
        xy_max = zip([x[0] for x in bbox[max_loc][0]],[x[1] for x in bbox[max_loc][0]])
        
        #union of both "pieces" of scene cut along +180/-180 longitude!
        bbox = [list(Polygon(xy_min).union(Polygon(xy_max)).exterior.coords)]
    
    url = str(bgIm.getThumbURL({'region':bbox,'dimensions':'%sx%s' %(str(num_pix),str(num_pix))}))
    
    #open image -> store locally
    img_file = urllib2.urlopen(url)
    img = StringIO(img_file.read())
    img = Image.open(img)
    
    # make figure for mosaic image
    fig = plt.figure(figsize=(6,6), dpi=150, facecolor='w', edgecolor='k')
    plt.imshow(img)
    plt.axis([0,num_pix,num_pix,0])
    plt.axis('off')
    plt.title(namer) #add title to image
  
    # include an overview basemap for reference
    fig.add_axes([0.025, -0.025, 0.25, 0.25]) #position at bottom of image
    m = Basemap(projection='merc',llcrnrlat=-70,urcrnrlat=80,\
                llcrnrlon=-180,urcrnrlon=180,lat_ts=10,resolution='c')
    m.drawcoastlines(linewidth=0.25)
    m.fillcontinents(color='0.6',lake_color='0.9')
    m.drawmapboundary(fill_color='0.9')
    #m.etopo(scale=0.1)
    llcorn = bbox[0][0]
    m.plot(llcorn[0],llcorn[1],'o',mfc='r',mec='r',ms=2,latlon=True)
    
    #export figure
    temp = os.path.join(search_dir,namer+'.png')
    fig.savefig(temp,dpi=300,bbox_inches='tight')
    plt.close("all")
    
    #update user regarding loop run time     
    print('%.1f seconds' %(time.time() - loop_time))            

#update user regarding entire run time            
print('%.1f seconds' %(time.time() - start_time))