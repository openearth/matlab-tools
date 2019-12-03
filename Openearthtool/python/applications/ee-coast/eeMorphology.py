#=============================
#Earth Engine (EE) Morphology
#=============================
#JFriedman
#Sep 11/2015
#=============================

#=========================
# 0. REQUIRED USER INPUTS
#=========================

#project name
name = 'Zandmotor'   #name for output images/videos/features

#spatial settings
inputType = 'json'         #option for loading spatial extents (OSM,json,kml)
satellites = ['L4','L5','L7','L8']      #list of satellites to use ['L4','L5','L7','L8']

#temporal settings
sdate = '2015-01-01'     #start time to filter image collections
edate = []    #end time to filter image collections (blank for today)

#image reduction settings
imCutoff = 1            #minimum # images for non-filtered percentile reduction [-]
delta = 180              #window for mean percentile [days]
pct = 15                 #pixel percentile for reducing images [%]
waterThresh = 0          #NDWI threshold value for water detection [-]

#visualization flags
visRawFlag = True     #flag for saving ALL raw satellite images (with video)
visTideFlag = False      #flag for including astronomical tide with raw images
visMorphFlag = True     #flag for saving morphological trends (i.e. delta coastlines)

#visualization settings
visType = 'TC'            #type of output images -> True Color [TC] or False Color [FC]
visRes = 1000             #resolution of output images [in pixels]
visAspect = 'Square'         #aspect ratio of image [square or automatic in ee]
vis = [0,0.3,1.5]       #visualization settings [I_min,I_max,gamma]
vidFps = 5               #output video frames per second (if visRawFlag is ENABLED)

#raster -> vector settings
vecFac = 1             #for smoothing features (using a median filter)
vecRes = 15              #resolution for vector conversion [m]
vecSmoothFlag = True    #flag for Gaussian smoothing of final vectors (remove sawtooth patterns)

#==================================
# 1. IMPORT ALL NECESSARY PACKAGES
#==================================
#get the current working path + system path working properly
import sys
import os
curr = r'd:\friedman\Documents\OpenEarth\trunk\python\applications\ee-coast' #define working file path (SLOPPY - need to fix!)
projdir = r'd:\friedman\Documents\OpenEarth\trunk\python\applications\ee-coast-projects' #get the outdir for the chosen location
os.chdir(curr) #change working directory
sys.path.append(curr) #add to system path

#import built engine module for satellite image analysis
import ee_coast.loadFuncs as LOAD
import ee_coast.ioFuncs as IO
import ee_coast.eeFuncs as EE
import ee_coast.getCollections as GETCOL
import ee_coast.visualizeFuncs as VIS

#initialize Earth Engine
import ee
ee.Initialize()

#include any other required standard libraries
import datetime as dt
import shutil
import time
start_time = time.time() #for timing the code

#===================================
# 2. LOAD THE SPATIAL EXTENTS (AOI)
#===================================
print 'Loading spatial extents ...'
projdir = os.path.join(projdir,name)
aoi,image_bounds,_ = LOAD.projLocation(inputType,name,curr,projdir) #load the spatial data

#==============================================
# 3. ORGANIZE RUN FOLDER + SAVE DATA FOR LATER
#==============================================
outdir = IO.PathBuilder(projdir,'dt=%03d_pct=%02d' %(delta,pct)) #make folder for delta/pixel input
shutil.copyfile(os.path.join(curr,'eeMorphology.py'),os.path.join(outdir,'eeMorphology_SETTINGS.py'))

#=============================
# 4. GET COLLECTION OF IMAGES
#=============================
print 'Joining image collections ...'
if not edate: #if empty -> put in today's date
    edate = dt.datetime.strftime(dt.datetime.now(),'%Y-%m-%d')

images,dater,clouder = GETCOL.combineCollections(satellites,sdate,edate,aoi) #get applicable images by aoi + time
images = images.map(lambda image: image.clip(aoi)) #clip image collection to aoi (reduce image size)

#=========================================
# 5. VISUALIZE RAW IMAGES FROM COLLECTION
#=========================================
if visRawFlag:
    
    print 'Visualizing raw images ...'
    tempdir = IO.PathBuilder(projdir,'~RAW') #build directory for raw images
    
    VIS.Raw(name,images,sdate,edate,dater,clouder,image_bounds,tempdir,vis,visTideFlag,visType,visRes,visAspect) #export collection as raw images (local)
    VIS.exportVideo(name,tempdir,vidFps) #visualize raw images together into video (local)

#======================================================
# 6. REDUCE IMAGE COLLECTION BY PERCENTILE (EACH PIXEL)
#======================================================
print 'Visualizing reduced images ...'
tempdir = IO.PathBuilder(outdir,'01-REDUCED')

proc_images,dateLims = EE.cloudReduce(images,sdate,edate,delta,pct,clouder,imCutoff) #remove clouds by reducing collection based on percentile
VIS.Reduced(name,proc_images,dater,dateLims,clouder,image_bounds,tempdir,vis,visType,visRes,visAspect) #export reduced collection as raw images (local)

#==============================
# 7. WATER DETECTION ALGORITHM
#==============================
print 'Detecting water mask ...'
tempdir = IO.PathBuilder(outdir,'02-WATER_DETECTION')

ndwi = proc_images.map(lambda image: EE.getWater(image,waterThresh,vecFac))
VIS.EdgeDetection(name,proc_images,dater,dateLims,clouder,image_bounds,tempdir,visRes,visAspect)

#==========================================
# 8. EXTRACTING AND VISUALIZING COASTLINES
#==========================================
print 'Extracting coastlines ...'
tempdir = IO.PathBuilder(outdir,'03-COASTLINES')

coastlines = ndwi.map(lambda image: EE.findCoast(image,aoi,vecRes))
xy = EE.getCoastline(name,coastlines,dateLims,image_bounds,vecSmoothFlag) #extract coastline data
IO.writeCoastline(name,xy,dateLims,tempdir) #export coastline data into simple *.txt file
VIS.buildKML(name,xy,dateLims,tempdir) #build KML

#=======================================================
# 9. VISUALIZE MORPHOLOGICAL TRENDS FROM REDUCED IMAGES
#=======================================================
if visMorphFlag:
    
    print 'Visualizing morphology ...'
    tempdir = IO.PathBuilder(outdir,'04-MORPHOLOGY')
    
    m = VIS.Morphology(name,ndwi,aoi,image_bounds,dateLims,tempdir,visRes,visAspect) #make images of morphology between adjacent reduced images in time
    IO.writeMorphology(name,m,dateLims,tempdir) #export morphology into a small formatted *.txt file

#==============================
# 10. KEEP RECORD OF RUN LENGTH
#==============================
fid = open(os.path.join(outdir,'~TIMER.txt'),'w')
fid.write('%.1f seconds' %(time.time() - start_time))
fid.close()