#=================================
#Earth Engine Collection Functions
#=================================
#JFriedman
#June 17/2015
#==============================

#import all necessary packages
#=============================
import ee
ee.Initialize()
from . import eeFuncs as EE

#global constants of Landsat missions
#====================================
collection_names = {'IM_L4':'LANDSAT/LT4_L1T_TOA',
                    'IM_L5':'LANDSAT/LT5_L1T_TOA',
                    'IM_L7':'LANDSAT/LE7_L1T_TOA',
                    'IM_L8':'LANDSAT/LC8_L1T_TOA'} #collections according to EE
band_names = {'IM_L4':['B1','B2','B3','B4','B5'], #designated band numbers
    'IM_L5':['B1','B2','B3','B4','B5'],
    'IM_L7':['B1','B2','B3','B4','B5'],
    'IM_L8':['B2','B3','B4','B5','B6','B8']}
band_std_names = {'IM_L4':['B','G','R','NIR','SWIR'], #designated band numbers
    'IM_L5':['B','G','R','NIR','SWIR'],
    'IM_L7':['B','G','R','NIR','SWIR'],
    'IM_L8':['B','G','R','NIR','SWIR','P']}
    
    
#get all applicable images (by collection) for the site + daters
#==============================================================
def combineCollections(satellites,sdate,edate,aoi):
    
    C = {}
    images,collections,dater,clouder = [],[],[],[]
    satellites = ['IM_'+sat for sat in satellites]
    
    for val in satellites:
        if val == 'IM_L8':    #separate for newest landsat missions since pansharpening is possible
                                      
            C[val] = (ee.ImageCollection(collection_names[val]) #get selected collection
                .filterDate(sdate,edate).filterBounds(aoi)      #filter by temporal bounds
                .select(band_names[val],band_std_names[val])    #rename bands to standard names
                .map(EE.pansharp)                               #pansharp RGB
                .map(EE.pansharpIR))                            #pansharp NIR
            num = len(C[val].getInfo()['features'])             #number of images in collection
            if num > 0:                                         #only proceed if image collection NOT empty!
                collections.append(val)
                ft = C[val].map(EE.getMetaData)                 #get dates + cloud cover for images in collection
                dater,clouder = EE.formatMetaData(ft)           #extract dates + cloud cover
            else:
                del C[val]                                      #delete image collection DATA in dictionary
                
        else:
            
            C[val] = (ee.ImageCollection(collection_names[val]) #get selected collection
                .filterDate(sdate,edate).filterBounds(aoi)      #filter by temporal bounds
                .select(band_names[val],band_std_names[val])   #rename bands to standard names
                .map(EE.dummyShift).map(EE.dummyShiftIR))
            num = len(C[val].getInfo()['features'])             #number of images in collection
            #print num            
            if num > 0:                                         #only proceed if image collection NOT empty!
                collections.append(val)                          #get names of image collections WITH images
                ft = C[val].map(EE.getMetaData)                 #get dates + cloud cover for images in collection
                dater,clouder = EE.formatMetaData(ft)           #extract dates + cloud cover                   
            else:
                del C[val]                                      #delete image collection DATA in dictionary

    
    if not C:
        images,dater,clouder = [],[],[]
    else:
        #compile collection together -> sort by dater/time    
        images = ee.ImageCollection(C[collections[0]]) #first GOOD collection WITH images
        for collection in collections[1:]: #loop through REST of collections
            images = eval('images.merge(C["%s"])' %collection) #merge collections TOGETHER
        images = ee.ImageCollection(images) #.sort('system:time_start', True)) #SORT image collection in together in time
        images = images.select(['R','G','B','NIR','SWIR']) #select specific bands for analysis
        
    return images,dater,clouder


#=======================================================================
#SORT OUT HOW TO BUILD A MOSAIC OF OVERLAPPING PATHS AT ONE PROJECT SITE -> perhaps not useful if reduced images are used (won't matter!)
#=======================================================================
#dt_threshold = 5 #minutes between images -> otherwise mosaic
#dt_images = [(t1-t0).total_seconds()/60. < dt_threshold for t1,t0 in zip(dater[1:],dater[:-1])]
#dt_images[1] = True
#any(dt_images)
#loc = [i for i in range(len(dt_images)) if dt_images[i] == True]
#for l in loc:
#    im = ee.ImageCollection([images.toList(1,l).get(0),images.toList(1,l+1).get(0)]).mosaic()