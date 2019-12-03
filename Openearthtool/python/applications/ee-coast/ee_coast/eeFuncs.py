#==============================
#Earth Engine Map Functions
#==============================
#JFriedman
#June 17/2015
#==============================

#import all necessary packages
#=============================
import ee
ee.Initialize()
import math
import datetime
from shapely.geometry import LineString,Polygon
from scipy.ndimage import gaussian_filter1d
import numpy as np

#pansharp RGB bands (for Landsat 8)
#==================================
def pansharp(image):
    rgb = image.select(['R','G','B']);
    pan = image.select('P')
    hsv  = rgb.rgbtohsv();
    huesat = hsv.select('hue', 'saturation')
    copy = ee.Image.cat(huesat, pan).hsvtorgb().select(['red','green','blue'],['R','G','B'])
    return image.addBands(copy,['R','G','B'],True)
    
#pansharp SWIR + NIR band (for Landsat 8)
#=================================
def pansharpIR(image):
    rgb = image.select(['NIR','SWIR','G']);
    pan = image.select('P')
    hsv  = rgb.rgbtohsv()
    huesat = hsv.select('hue', 'saturation')
    copy = ee.Image.cat(huesat, pan).hsvtorgb().select(['red','green'],['NIR','SWIR'])
    return image.addBands(copy,['NIR','SWIR'],True)
 
#change to hsv/rgb for other satellites (silly!)
#================================================
def dummyShift(image):
    copy = image.select(['R','G','B']).rgbtohsv().hsvtorgb().select(['red','green','blue'],['R','G','B'])
    return image.addBands(copy,['R','G','B'],True)

#change to hsv/rgb for other satellites (silly!)
#================================================
def dummyShiftIR(image):
    copy = image.select(['NIR','SWIR','B']).rgbtohsv().hsvtorgb().select(['red','green','blue'],['NIR','SWIR','B'])
    return image.addBands(copy,['NIR','SWIR'],True)

#water "mask" from NDWI normalized difference (NIR is absorbed by water)
#=======================================================================
def getWater(image,waterThresh,vecFac):
    NDWI = image.normalizedDifference(['NIR', 'G']).lte(waterThresh)
    # NDWI = NDWI.focal_mode(vecFac).focal_max(vecFac*1.1).focal_min(vecFac)
    return NDWI

#get vector from raster layer of water "mask"
#=============================================
def findCoast(NDWI,aoi,res):
    NDWI = NDWI.mask(NDWI.gt(0)).uint32() #requires an integer -> vectors
    return NDWI.reduceToVectors(None, aoi, res)

#map function to reduce image collection by date limits to an interval mean (i.e. percent by pixel)
#===================================================================================================
def cloudReduce(collection,sdate,edate,delta,pct,clouder,imCutoff):
    
    temp_sdate = datetime.datetime.strptime(sdate,'%Y-%m-%d')
    real_edate = min([datetime.datetime.now(),datetime.datetime.strptime(edate,'%Y-%m-%d')])
    X,dateLims = [],[]
    spct = str(pct)
    while temp_sdate < real_edate: #go through dates -> get images
        if delta: #only if supplied
            temp_edate = temp_sdate + datetime.timedelta(days=delta) #diff is in DAYS (PAY ATTENTION!)
        else:
            temp_edate = real_edate
        ee_sdate = datetime.datetime.strftime(temp_sdate,'%Y-%m-%d')
        ee_edate = datetime.datetime.strftime(temp_edate,'%Y-%m-%d')
        img_count = len(collection.getInfo()['features']) #put length of images to list 
        if img_count >= imCutoff: #reduce to percentiles if there are enough images!
            temp = (collection.filterDate(ee_sdate,ee_edate)
                .reduce(ee.Reducer.percentile([pct]))
                .select(['R_p'+spct,'G_p'+spct,'B_p'+spct,'NIR_p'+spct,'SWIR_p'+spct],['R','G','B','NIR','SWIR']))
                # .reduce(ee.Reducer.intervalMean(pct, pct+1))  
                # .select(['R_mean','G_mean','B_mean','NIR_mean','SWIR_mean'],['R','G','B','NIR','SWIR']))
        else:
            temp = (collection.filterDate(ee_sdate,ee_edate) 
                .filterMetadata('CLOUD_COVER','less_than',np.mean(clouder)+0.01) #remove the cloudy images -> disrupting reduction
                .reduce(ee.Reducer.percentile([pct]))
                .select(['R_p'+spct,'G_p'+spct,'B_p'+spct,'NIR_p'+spct,'SWIR_p'+spct],['R','G','B','NIR','SWIR']))
                #.reduce(ee.Reducer.intervalMean(pct, pct+1))
                #.select(['R_mean','G_mean','B_mean','NIR_mean','SWIR_mean'],['R','G','B','NIR','SWIR']))
                
        X.append(temp)
        dateLims.append([temp_sdate,temp_edate])
        temp_sdate = temp_edate
    return ee.ImageCollection(X),dateLims

#function to map image collection -> get dates + cloud cover by image
#=====================================================================
def getMetaData(im):
    d = ee.Date(im.get('system:time_start')).format('yyyyMMdd_HHmmss') #format date
    cc = ee.String(im.get('CLOUD_COVER')) #get cloud cover
    return ee.Feature(ee.Geometry.Point([0,0]),{'clouds':cc,'date':d})

#function to extract data from feature (i.e. getInfo + format)
#=============================================================
def formatMetaData(ft):
    temp = ft.getInfo()
    clouder = [cc['properties']['clouds'] for cc in temp['features']]
    dater = [dd['properties']['date'] for dd in temp['features']]
    dater = [datetime.datetime.strptime(dd,'%Y%m%d_%H%M%S') for dd in dater]
    return dater,clouder
    
#simple pythagorus for getting distance between points
#======================================================
def distance(p0, p1):
    return math.sqrt((p0[0] - p1[0])**2 + (p0[1] - p1[1])**2) #pythagorus between two points

#function to "clean" raw vector points of coastline (from vector water "mask")
#=============================================================================
def cleanVector(CL_pts,BND):
    
    #get bounding box
    IN_BOX = Polygon(BND).buffer(-1./2000) #convert to polygon apply interior offset (to remove edge vectors)
    
    #determine which points are in inside box
    CL = LineString([(x[0],x[1]) for x in CL_pts]) #change CL list to LineString
    CL_IN_BOX = IN_BOX.intersection(CL) #check which points intersect INSIDE box
    
    #extract coordinates from coastline INSIDE box
    COORDS = []
    if CL_IN_BOX.geom_type == "LineString": #if LineString -> get coords
        temp = list(CL_IN_BOX.coords)
        COORDS.append(temp)
    else: #in case MultiLineString -> extract most basic LineString features       
        for poly in CL_IN_BOX:
            if poly.geom_type == "LineString":
                temp = list(poly.coords)
                COORDS.append(temp)
            else:
                val = [val for val in poly]
                temp = list(val.coords)
                COORDS.append(temp)
                    
#    if not CL_IN_BOX.is_empty:  
#        COORDS = np.vstack(COORDS).tolist() #convert to list for easier handling
#            
#        dist = [distance(i0,i1) for i0,i1 in zip(COORDS[:-1], COORDS[1:])] #distance of COORDS in lat/lon
#        if max(dist) > 0.1: #if any points are very far away from one another...
#            ind = next(x[0] for x in enumerate(dist) if x[1] > 0.1) - 1 #get index where discontinuity is found
#            COORDS = COORDS[:ind] #only use COORDS up to that index
        
#        #DEBUG -> visualize if done correctly
#        import matplotlib.pyplot as plt
#        plt.plot([x[0] for x in CL_pts],[y[1] for y in CL_pts],c='g',label='Original Coastline')
#        plt.plot([x[0] for x in BND],[y[1] for y in BND],c='0.6',label='AOI Boundary')
#        for C in COORDS:        
#            plt.plot([x[0] for x in C],[y[1] for y in C],'-r',label='Actual Coastline')
#        plt.legend()
#        plt.axis('equal')

    return COORDS

#function to smooth the "clean" vector output with a Gaussian smoothing kernel
#=============================================================================
def smoothVector(coord,sigma=1.75):

    c_sm = []
    for c in coord:
        
        #get coordinates --> build "space"
        x = [x[0] for x in c]
        y = [y[1] for y in c]
        t = np.linspace(0, 1, len(x))
        
        #to make sure there are enough points for smoothing
        t2 = np.linspace(0, 1, len(x)*2) 
        x2 = np.interp(t2, t, x) #interp original x to new space
        y2 = np.interp(t2, t, y) #interp original y to new space
        
        #apply Gaussian filter
        x3 = gaussian_filter1d(x2, sigma)
        y3 = gaussian_filter1d(y2, sigma)
        
        #interpolate the Gaussian smoothed coordinates to original "space"
        x4 = np.interp(t, t2, x3)
        y4 = np.interp(t, t2, y3)
        
        ##for debugging
        #plt.plot(x, y, "b-", lw=2,label='original')
        #plt.plot(x4, y4, "r-", lw=2,label='smoothed')
        #plt.legend()
        #plt.show()
        c_sm.append(zip(x4,y4))
    
    return c_sm  
    
#function to clean edges of feature collection by buffering
#==========================================================     
def clipVectors(ft,erode):
    return ft.intersection(erode,ee.ErrorMargin(1))
    
#extract coastline from vector layer -> save to dictionary
#=========================================================   
def getCoastline(name,coastlines,dateLims,image_bounds,smoothFlag):
  
    XY = {} #preallocate dictionary for all feature
    
    #number of available images
    num = len(dateLims) #number of images

    for jj in range(num): #loop through all computed features (i.e. years)
    
        temp = [] #preallocate list for individual polygons in feature
        fts = ee.FeatureCollection(coastlines.toList(1,jj).get(0)) #all coastline geometries as Feature Collection    
#        X = fts.map(lambda ft: clipVectors(ft,erode)).getInfo()  
        X = fts.getInfo()
        num_polys = len(X['features']) #determine number of polygons in feature
        
        for ii in range(num_polys): #loop through all polygons in each feature (i.e. sections of individual year)
        
            coords = X['features'][ii]['geometry']['coordinates'] #extract coordinates

            for kk in range(len(coords)):
                coord = cleanVector(coords[kk],image_bounds) #clean the edges of the vector layer
                if smoothFlag:                
                    coord = smoothVector(coord) #apply Gaussian smoothing to "cleaned" coastline vector   
                if coord: #if not empty!        
                    temp.append(coord) #append coordinates  
            
        XY[jj] = temp #add key of feature to XY dictionary

    return XY

#import matplotlib.pyplot as plt
#for a in XY[0]:
#    for b in a:
#        if isinstance(b[0][0],float):
#            plt.plot([x[0] for x in b],[x[1] for x in b])
#        else:
#            for c in b:
#                if isinstance(c[0][0],float):
#                    plt.plot([x[0] for x in c],[x[1] for x in c])
#                
#plt.axis('equal')
#plt.show()

#define main map reduce functions to find coastline "features" in WRS2 scene
#============================================================================
def getClipped(f2,f,buffer_dist):
        clippedFeature = ee.Feature(f2).intersection(f) #intersection with wrs2 path?!?
        clippedFeature = clippedFeature.buffer(buffer_dist) #buffer result to get clipping
        return clippedFeature
      
def getFeats(f,buffer_dist):
    features = ee.List(f.get('features')) #put all intersected features into list
    count = features.length() #total number of intersections
    clippedFeatures = features.map(lambda f2: getClipped(f2,f,buffer_dist))
    return f.set('feature_count', count).set('clipped_features', clippedFeatures) #add feature of number of intersections
