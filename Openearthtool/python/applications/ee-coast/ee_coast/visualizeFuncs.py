#=====================================
#Earth Engine Visualization Functions
#=====================================
#JFriedman
#June 17/2015
#==============================

#import all necessary packages
#=============================
import ee
ee.Initialize()
import os
import math
import datetime
import urllib2			
from PIL import Image
from cStringIO import StringIO
import matplotlib as mpl
import matplotlib.colors as colors
import matplotlib.cm as cm
import matplotlib.dates as mdates
import matplotlib.pyplot as plt
plt.ioff() #turn off plots popping on screen
import numpy as np
import simplekml
import moviepy.editor as mpy
import tideWPS as TIDE

#visualizes each image in a collection (includes name, time, timebar, etc...)
#============================================================================
def Raw(name,images,sdate,edate,dater,clouder,region,tempdir,vis,tideFlag,visType,visRes,visAspect):

    #determine type of output image
    if visType == 'TC':
        vis_bands = 'R,G,B'
    elif visType == 'FC':
        vis_bands = 'SWIR,NIR,G'
    
    #get location for extracting tide
    lon = math.ceil(max(region)[0]/0.5)*0.5
    lat = math.ceil(max(region)[1]/0.5)*0.5

    #temporal extents of available images
    syear = datetime.datetime.strptime(sdate,'%Y-%m-%d').year
    eyear = datetime.datetime.strptime(edate,'%Y-%m-%d').year + 2 #in order to get extent of image collection (i.e. eyear + 1)
    
    #loop through images
    for ind in range(len(dater)): 
    
        im = ee.Image(images.toList(1,ind).get(0)) #get image from collection
        
        if visAspect is 'Square':
            url = str(im.getThumbURL({'bands':vis_bands,'min':vis[0],'max':vis[1],
                        'gamma':vis[2],'region':str(region),'dimensions':'%dx%d'%(visRes,visRes)}))
        else:
            url = str(im.getThumbURL({'bands':vis_bands,'min':vis[0],'max':vis[1],
                        'gamma':vis[2],'region':str(region),'dimensions':'%d'%(visRes)}))
        
        #open image -> store locally
        img_file = urllib2.urlopen(url)
        img = StringIO(img_file.read())
        img = Image.open(img)
        
        #make figure of the raw satellite image
        fig = plt.figure(figsize=(6,6), dpi=150, facecolor='w', edgecolor='k')
        plt.imshow(img)
        plt.axis('off')
        temp_dater = datetime.datetime.strftime(dater[ind],'%Y-%m-%d %H:%M:%S')
        plt.title('%s [%s]' %(name,temp_dater)) #add title to image
        
        #add axis of the temporal range, image frequency + current image
        ax_dater = fig.add_axes([0.075, 0.05, 0.85, 0.05]) #position at bottom of image
        for d in dater:
            plt.plot([d,d],[0,1],'0.75',linewidth=0.5)
            
        plt.plot([dater[ind],dater[ind]],[0,1],'r',linewidth=1.5)
        ax_dater.get_yaxis().set_visible(False)
        ax_dater.tick_params(labelsize=8)
        ax_dater.set_xticks([datetime.datetime(yr,1,1) for yr in range(syear,eyear)])
    
        #only if enabled!
        if tideFlag:
            #add axis of the tide
            ax_tide = fig.add_axes([0.625, 0.125, 0.3, 0.1]) #position at bottom of image
            t,h = TIDE.extractTide(lon, lat,dater[ind],2.5)
            plt.plot(t,h,'b',linewidth=0.5)  
            hmax = math.ceil(max(h)/0.5)*0.5
            hmin = math.floor(min(h)/0.5)*0.5
            plt.plot([dater[ind],dater[ind]],[hmin,hmax],'r',linewidth=1.5)
            ax_tide.get_yaxis().set_visible(False)
            ax_tide.get_xaxis().set_visible(False)
    
        #export figure
        temp = os.path.join(tempdir,"%s_%s.png" %(name.replace(' ','_'),datetime.datetime.strftime(dater[ind],'%Y%m%d_%H%M%S')))
        fig.savefig(temp,dpi=300,bbox_inches='tight')
        plt.close("all")

#settings for visualizing RGB bands to image (for image + video export)
#======================================================================
def visImage(image):
    visparams = {'bands':['SWIR','NIR','G'],'min':0.05,'max':0.45,'gamma':1.5}
    return image.visualize(**visparams)
        
#makes a video of the exported images using ffmpeg (local)
#=========================================================
def exportVideo(name,tempdir,fps):
    clip = mpy.ImageSequenceClip(tempdir,fps)
    clip.write_videofile(os.path.join(tempdir,name+'.mp4'),fps,'libx264')
       
#makes a video of the images in a collection -> exports to google drive
#======================================================================
def exportEEVideo(name,images,region,fps):
    
    images = images.map(visImage) #make RGB images from collection
    images = images.map(lambda image: image.uint8()) #uint for movie export
    E = ee.batch.Export.video(images,'%s'%(name), {
      'dimensions': 1920,
      'driveFolder':'Coastal Morphology',
      'framesPerSecond': fps,
      'region': region})
    E.start() #start the export
  
#visualizes reduced images from collection (includes name, time, timebar, etc...)
#================================================================================
def Reduced(name,proc_images,dater,dateLims,clouder,image_bounds,tempdir,vis,visType,visRes,visAspect):  
    
    #determine type of output image
    if visType == 'TC':
        vis_bands = 'R,G,B'
    elif visType == 'FC':
        vis_bands = 'SWIR,NIR,G'    
    
    #temporal extents of available images
#    syear = dateLims[0][0].year
#    eyear = dateLims[-1][1].year + 2 #in order to get extent of image collection (i.e. eyear + 1)
    num = len(dateLims) #number of images
    
    #loop through images
    for ind in range(num): 
        
        im = ee.Image(proc_images.toList(1,ind).get(0)) #get image from collection

        #build url to visualized image
        if visAspect is 'Square':
            url = str(im.getThumbURL({'bands':vis_bands,'min':vis[0],'max':vis[1],
                        'gamma':vis[2],'region':str(image_bounds),'dimensions':'%dx%d'%(visRes,visRes)}))
        else:
            url = str(im.getThumbURL({'bands':vis_bands,'min':vis[0],'max':vis[1],
                        'gamma':vis[2],'region':str(image_bounds),'dimensions':'%d'%(visRes)}))
                                              
        #open image -> store locally
        img_file = urllib2.urlopen(url)
        img = StringIO(img_file.read())
        img = Image.open(img)
        
        #get date range from "reduce" function
        sx,ex = dateLims[ind]
                
        #set up colormap for cloud cover %
        cmapper = plt.cm.get_cmap('RdYlGn_r')
        cNorm  = colors.Normalize(vmin=0, vmax=100)
        scalarMap = cm.ScalarMappable(norm=cNorm, cmap=cmapper)
        
        #make figure of the raw satellite image
        fig = plt.figure(figsize=(6,6), dpi=150, facecolor='w', edgecolor='k')
        plt.imshow(img)
        plt.axis('off')
        plt.title('%s [%s to %s]' %(name,datetime.datetime.strftime(sx,'%Y/%m/%d'),
                  datetime.datetime.strftime(ex,'%Y/%m/%d'))) #add title to image
        
        #add axis of the temporal range, image frequency and cloud cover
        ax_dater = fig.add_axes([0.075, 0.05, 0.815, 0.05]) #position at bottom of image
        for d,c in zip(dater,clouder):
            colorVal = scalarMap.to_rgba(c)
            if (d >= sx) and (d <= ex): #within bounds of "region"
                plt.plot([d,d],[0,1],c=colorVal,linewidth=0.75)
#            else:
#                plt.plot([d,d],[0,1],'0.75',linewidth=0.5)
                
        #add background fill to highlight the "reduced" image in time        
        plt.fill([sx, ex, ex, sx, sx], [0, 0, 1, 1, 0],'0.75', alpha = 0.3)
        ax_dater.get_yaxis().set_visible(False)
        ax_dater.tick_params(labelsize=8)       
        ax_dater.xaxis.set_major_locator(mdates.MonthLocator(interval=3))
        ax_dater.xaxis.set_major_formatter(mdates.DateFormatter('%Y-%b'))
        
        #add colormap for easy referencing
        cbaxes = fig.add_axes([0.9, 0.05, 0.02, 0.05]) 
        cbar = mpl.colorbar.ColorbarBase(cbaxes, cmap=cmapper, norm=cNorm, orientation='vertical')
        cbar.set_ticks([0,50,100])
        cbar.set_label('Cloud %',fontsize=6)
        plt.tick_params(labelsize=6)    

#        ax_dater.set_xticks([datetime.datetime(yr,1,1) for yr in range(syear,eyear)]) #ticks for timebar
    
        #export figure
        temp = os.path.join(tempdir,"%s_%s_to_%s.png" %(name.replace(' ','_'),datetime.datetime.strftime(sx,'%Y%m%d'),
                  datetime.datetime.strftime(ex,'%Y%m%d')))
        fig.savefig(temp,dpi=300,bbox_inches='tight')
        plt.close("all")

#visualize the edge detection with the NDWI (includes name, time, etc...)
#========================================================================
def EdgeDetection(name,proc_images,dater,dateLims,clouder,region,tempdir,visRes,visAspect):  
    
    #temporal extents of available images
#    syear = dateLims[0][0].year
#    eyear = dateLims[-1][1].year + 2 #in order to get extent of image collection (i.e. eyear + 1)
    num = len(dateLims) #number of images
    
    #loop through images
    for ind in range(num): 
        
        im = ee.Image(proc_images.toList(1,ind).get(0)) #get image from collection
        ndwi = im.normalizedDifference(['NIR','G'])
        mask = ndwi.mask(ndwi.gt(0))
        
        #visualize the NDWI layer
        visparams = {'bands':['nd'],'min':-0.5,'max':0.5,'forceRgbOutput':True}
        ndwi = ndwi.visualize(**visparams)
        
        #set up the water mask layer    
        visparams = {'palette':'FFFF00','forceRgbOutput':True}
        mask = mask.visualize(**visparams)
        
        #combine together into a single mosaic
        flat = ee.ImageCollection([ndwi,mask]).mosaic()
        
        if visAspect is 'Square':
            url = str(flat.getThumbURL({'region':str(region),'dimensions':'%dx%d'%(visRes,visRes)}))
        else:
            url = str(flat.getThumbURL({'region':str(region),'dimensions':'%d'%(visRes)}))
        
        #open image -> store locally
        img_file = urllib2.urlopen(url)
        img = StringIO(img_file.read())
        img = Image.open(img)        
        
        #get date range from "reduce" function
        sx,ex = dateLims[ind]
        
        #set up colormap for cloud cover %
        cmapper = plt.cm.get_cmap('RdYlGn_r')
        cNorm  = colors.Normalize(vmin=0, vmax=100)
        scalarMap = cm.ScalarMappable(norm=cNorm, cmap=cmapper)        
        
        #make figure of the raw satellite image
        fig = plt.figure(figsize=(6,6), dpi=150, facecolor='w', edgecolor='k')
        plt.imshow(img)
        plt.axis('off')
        plt.title('%s [%s to %s]' %(name,datetime.datetime.strftime(sx,'%Y/%m/%d'),
                  datetime.datetime.strftime(ex,'%Y/%m/%d'))) #add title to image
        
        #add axis of the temporal range, image frequency and cloud cover
        ax_dater = fig.add_axes([0.075, 0.05, 0.815, 0.05]) #position at bottom of image
        for d,c in zip(dater,clouder):
            colorVal = scalarMap.to_rgba(c)
            if (d >= sx) and (d <= ex): #within bounds of "region"
                plt.plot([d,d],[0,1],c=colorVal,linewidth=0.75)
#            else:
#                plt.plot([d,d],[0,1],'0.75',linewidth=0.5)
                
        #add background fill to highlight the "reduced" image in time        
        plt.fill([sx, ex, ex, sx, sx], [0, 0, 1, 1, 0],'0.75', alpha = 0.3)
        ax_dater.get_yaxis().set_visible(False)
        ax_dater.tick_params(labelsize=8)       
        ax_dater.xaxis.set_major_locator(mdates.MonthLocator(interval=3))
        ax_dater.xaxis.set_major_formatter(mdates.DateFormatter('%Y-%b'))
        
        #add colormap for easy referencing
        cbaxes = fig.add_axes([0.9, 0.05, 0.02, 0.05]) 
        cbar = mpl.colorbar.ColorbarBase(cbaxes, cmap=cmapper, norm=cNorm, orientation='vertical')
        cbar.set_ticks([0,50,100])
        cbar.set_label('Cloud %',fontsize=6)
        plt.tick_params(labelsize=6)    
    
#        ax_dater.set_xticks([datetime.datetime(yr,1,1) for yr in range(syear,eyear)]) #ticks for timebar    
    
        #export figure
        temp = os.path.join(tempdir,"%s_%s_to_%s.png" %(name.replace(' ','_'),datetime.datetime.strftime(sx,'%Y%m%d'),
                  datetime.datetime.strftime(ex,'%Y%m%d')))
        fig.savefig(temp,dpi=300,bbox_inches='tight')
        plt.close("all")

#visualize coastline changes in a single kml
#===========================================      
def buildKML(name,XY,dateLims,tempdir):
    
    
    #number of images available
    num = len(dateLims) #number of images
    syear = dateLims[0][0].year
    eyear = dateLims[-1][1].year + 1 #in order to get extent of image collection (i.e. eyear + 1)
    color = cm.Reds(np.linspace(0.15,0.85,num)) #build colormap    
    
    #blank kml
    kml = simplekml.Kml()
    
    for jj in range(len(XY)):
        
        sx,ex = dateLims[jj]
        sdater = datetime.datetime.strftime(sx,'%Y-%m-%d')
        edater = datetime.datetime.strftime(ex,'%Y-%m-%d')
        temp_dater = datetime.datetime.strftime(sx + (ex - sx)/2,'%Y-%m-%d') #average of date
        
        for ii in range(len(XY[jj])):
            
            for kk in range(len(XY[jj][ii])):
            
                lin = kml.newlinestring(name = temp_dater, coords = [(x,y) for (x,y) in XY[jj][ii][kk]])
                lin.style.linestyle.color = simplekml.Color.rgb(color[jj][0]*255,color[jj][1]*255,color[jj][2]*255,color[jj][3]*255)
                lin.style.linestyle.width = 3
                lin.timespan.begin = sdater
                lin.timespan.end = edater
                lin.AltitudeMode = 'clampToGround'
            
    temp = os.path.join(tempdir,"%s_%d_to_%d.kml" %(name.replace(' ','_'),syear,eyear))
    kml.save(temp)
   
#visualize the vector water "mask" based on nwdi (includes name, time, etc...)
#==============================================================================    
def Morphology(name,ndwi,aoi,image_bounds,dateLims,tempdir,visRes,visAspect):
    
    M = [] #initialize list
    im0 = ee.Image(ndwi.toList(1,0).get(0)) #get initial image
    num = len(dateLims) #number of images 
    
    temp_date = [x[0] + (x[1] - x[0])/2 for x in dateLims]
    
    #loop through all computed features   
    for jj in range(1,num): 
    
        im1 = ee.Image(ndwi.toList(1,jj).get(0))
        
        differ = im1.subtract(im0) #subtract images from the most "recent" one (i.e. im1)
        accretion = differ.lt(0).reduceRegion(ee.Reducer.sum(), aoi, 30).get('nd').getInfo()*30*30
        erosion = differ.gt(0).reduceRegion(ee.Reducer.sum(), aoi, 30).get('nd').getInfo()*30*30
        net = accretion - erosion
        
        M.append([accretion,erosion,net])

        visparams = {'palette':'ffffff,00ff00','min':0,'max':1,'forceRgbOutput':True}
        ero_layer = differ.lt(0).mask(differ.lt(0)).visualize(**visparams)
        visparams = {'palette':'ffffff,ff0000','min':0,'max':1,'forceRgbOutput':True}
        acc_layer = differ.gt(0).mask(differ.gt(0)).visualize(**visparams)

        #combine together into a single mosaic
        flat = ee.ImageCollection([ero_layer,acc_layer]).mosaic()
        
        if visAspect is 'Square':
            url = str(flat.getThumbURL({'region':str(image_bounds),'dimensions':'%dx%d'%(visRes,visRes)}))
        else:
            url = str(flat.getThumbURL({'region':str(image_bounds),'dimensions':'%d'%(visRes)}))

        #open image -> store locally
        img_file = urllib2.urlopen(url)
        img = StringIO(img_file.read())
        img = Image.open(img)

        #make figure of the raw satellite image
        fig = plt.figure(figsize=(6,6), dpi=150, facecolor='w', edgecolor='k')
        plt.imshow(img)
        plt.axis('off')
    
        #add the morphological data (i.e. erosion + accretion)
        plt.annotate("Erosion = $%.1f \cdot 10^3 m^2$" %(erosion/1000),xy=(0.98, 0.2),
                     xycoords='figure fraction', fontsize=10, ha='right', va='bottom',
                     bbox = dict(boxstyle="round", ec=(1., 0.5, 0.5), fc=(1., 0.8, 0.8),)) 
        plt.annotate("Accretion = $%.1f \cdot 10^3 m^2$" %(accretion/1000),xy=(0.98, 0.125),
                     xycoords='figure fraction', fontsize=10, ha='right', va='bottom',
                     bbox = dict(boxstyle="round", ec=(0.5, 1., 0.5), fc=(0.8, 1., 0.8),)) 
        plt.annotate("Net = $%.1f \cdot 10^3 m^2$" %(net/1000),xy=(0.98, 0.05),
                     xycoords='figure fraction', fontsize=10, ha='right', va='bottom',
                     bbox = dict(boxstyle="round", ec=(0.5, 0.5, 0.5), fc=(0.8, 0.8, 0.8),))
             
        sx = temp_date[jj-1]
        ex = temp_date[jj]
        plt.title('%s Morphology [$\Delta_{t}$ = %d days]' %(name,(ex-sx).days)) #add title to image
        
        #add the morphological data (i.e. erosion + accretion)
        plt.annotate("$im_1$ = %s" %datetime.datetime.strftime(ex,'%Y/%m/%d'),xy=(0.02,0.025),
                 xycoords='figure fraction',size=8,ha="left", va="bottom")
        plt.annotate("$im_0$ = %s" %datetime.datetime.strftime(sx,'%Y/%m/%d'),xy=(0.02,0.05),
                 xycoords='figure fraction',size=8,ha="left", va="bottom")  

        im0 = im1 #replace the im0 to the im1 (need to get next difference in time)
    
        #export figure
        temp = os.path.join(tempdir,"%s_%s_to_%s.png" %(name.replace(' ','_'),datetime.datetime.strftime(sx,'%Y%m%d'),datetime.datetime.strftime(ex,'%Y%m%d')))
        fig.savefig(temp,dpi=300,bbox_inches='tight')
        plt.close("all")
        
    return M