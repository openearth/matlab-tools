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
name = 'Gangneung_Harbour'   #name for output images/videos/features

#spatial settings
inputType = 'kml'         #option for loading spatial extents (OSM,json,kml)
satellites = ['L4','L5','L7','L8']      #list of satellites to use ['L4','L5','L7','L8']

#temporal settings
years = range(2005,2016) #range of years for LT analysis

#image reduction settings
imCutoff = 1            #minimum # images for non-filtered percentile reduction [-]
pct = 20                 #pixel percentile for reducing images [%]
waterThresh = 0          #NDWI threshold value for water detection [-]

#visualization settings
visType = 'TC'            #type of output images -> True Color [TC] or False Color [FC]
visRes = 1000             #resolution of output images [in pixels]
vis = [0,0.25,1.5]       #visualization settings [I_min,I_max,gamma]
visAspect = None         #aspect ratio of image [square or automatic in ee]

#raster -> vector settings
vecFac = 5               #for smoothing features with a median filter [pixels]
vecRes = 10              #resolution for vector conversion [m]
vecSmoothFlag = True    #flag for Gaussian smoothing of final vectors (remove sawtooth patterns)

#==================================
# 1. IMPORT ALL NECESSARY PACKAGES
#==================================
#get the current working path + system path working properly
import sys
import os
curr = r'p:\1205871-bouwen-ad-kust\SatelliteImages\ee-coast' #define working file path (SLOPPY - need to fix!)
os.chdir(curr) #change working directory
sys.path.append(curr) #add to system path

#import built engine module for satellite image analysis
import engine.loadFuncs as LOAD
import engine.ioFuncs as IO
import engine.eeFuncs as EE
import engine.getCollections as GETCOL
import engine.visualizeFuncs as VIS

#initialize Earth Engine
import ee
ee.Initialize()

#include any other required standard libraries
import shutil
import datetime as dt
import time
start_time = time.time() #for timing the code

#===================================
# 2. LOAD THE SPATIAL EXTENTS (AOI)
#===================================
print 'Searching for images ... '
projdir = os.path.join(curr,'PROJECTS',name) #get the outdir for the chosen location
aoi,image_bounds,_ = LOAD.projLocation(inputType,name,curr,projdir) #load the spatial data

#==============================================
# 3. ORGANIZE RUN FOLDER + SAVE DATA FOR LATER
#==============================================
outdir = IO.PathBuilder(projdir,'LT_pct=%02d' %pct) #make folder for pixel input
shutil.copyfile(os.path.join(curr,'eeMorphology_LT.py'),os.path.join(outdir,'eeMorphology_LT_SETTINGS.py'))

#===========================================
# 3. PROCESS IMAGES BY YEAR (MORE EFFICIENT)
#===========================================
print 'Starting the annual loop ... '
XY = dict()
counter = 0

for year in years:
    
    #=============================
    # 3.1 GET COLLECTION OF IMAGES
    #=============================
    sdate = '%d-01-01' %year
    edate = '%d-12-31' %year
    images,dater,clouder = GETCOL.combineCollections(satellites,sdate,edate,aoi) #get applicable images by aoi + time (sort by date!)
    
    if clouder:
        
        if len(clouder) == 1 and all([c > pct for c in clouder]): #check if only 1 image exists and not poor quality!
            

            print '%d is Poor Quality' %year		
            
            #keep all data to combine into a single KML
            XY[counter] = None #extract the first coastline from xy coordinates
            counter += 1
		
        else:
			
            #update user
            print 'Processing %d' %year
            			
            images = images.map(lambda image: image.clip(aoi)) #clip image collection to aoi (reduce image size)
            		
            #=======================================================
            # 3.2 REDUCE IMAGE COLLECTION BY PERCENTILE (EACH PIXEL)
            #=======================================================
            tempdir = IO.PathBuilder(outdir,'01-REDUCED')
            proc_images,dateLims = EE.cloudReduce(images,sdate,edate,None,pct,clouder,imCutoff) #remove clouds by reducing collection based on percentile
            VIS.Reduced(name,proc_images,dater,dateLims,clouder,image_bounds,tempdir,vis,visType,visRes,visAspect) #export reduced collection as raw images (local)
            
            #==============================
            # 3.3 WATER DETECTION ALGORITHM
            #==============================
            tempdir = IO.PathBuilder(outdir,'02-WATER_DETECTION')
            	
            ndwi = proc_images.map(lambda image: EE.getWater(image,waterThresh,vecFac))
            VIS.EdgeDetection(name,proc_images,dater,dateLims,clouder,image_bounds,tempdir,visRes,visAspect)
            	
            #==========================================
            # 3.4 EXTRACTING AND VISUALIZING COASTLINES
            #==========================================
            tempdir = IO.PathBuilder(outdir,'03-COASTLINES')
            		
            coastlines = ndwi.map(lambda image: EE.findCoast(image,aoi,vecRes))
            xy = EE.getCoastline(name,coastlines,dateLims,image_bounds,vecSmoothFlag) #extract coastline data
            IO.writeCoastline(name,xy,dateLims,tempdir) #export coastline data into simple *.txt file

        #keep all data to combine into a single KML
        XY[counter] = xy[0] #extract the first coastline from xy coordinates
        counter += 1

#visualize all coastline data in a single KML
dateLims = [[dt.datetime(yr,1,1),dt.datetime(yr,12,31)] for yr in years]
VIS.buildKML(name,XY,dateLims,tempdir) #build KML
    
#==============================
# 4. KEEP RECORD OF RUN LENGTH
#==============================
fid = open(os.path.join(outdir,'~TIMER.txt'),'w')
fid.write('total_runtime = %.1f seconds (%.1f min)\n' %((time.time() - start_time),(time.time() - start_time)/60))
fid.write('avg_runtime = %.1f seconds/year\n' %((time.time() - start_time)/len(years)))
fid.close()