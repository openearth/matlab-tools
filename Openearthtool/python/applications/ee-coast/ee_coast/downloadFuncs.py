#=====================================
#Earth Engine Download Functions
#=====================================
#JFriedman
#Nov 30/2015
#=====================================

#import all necessary packages
#=============================
import os
import zipfile
from urllib2 import Request, urlopen		
from PIL import Image

#function to download actual (not thumbnail) Earth Engine image
#==============================================================
def buildEEImage(im,visType,vis,imName,imScale,imType,imBounds):
    
    #determine type of output image
    if visType == 'TC':
        vis_bands = 'R,G,B'
    elif visType == 'FC':
        vis_bands = 'SWIR,NIR,G'
        
    #visualize image based on user-selected type (only if needed!)
    if visType == 'TC' or visType == 'FC':
        visparams = {'bands':vis_bands,'min':vis[0],'max':vis[1],'gamma':vis[2]}
        im = im.visualize(**visparams)
    
    #export visualized image
    url = im.getDownloadURL({'name': imName,'scale': imScale,
                             'format': imType,'region': imBounds,'crs': 'EPSG:4326'})
    
    return url

#function to unzip downloaded image from Earth Engine
#====================================================
def unzipEEImage(outdir):
    
    #read contents of zip file
    zf = zipfile.ZipFile(os.path.join(outdir,'test.zip'), 'r')
    files = zf.namelist()
    
    #extract contents of zip file (loop through contents -> i.e. "files")
    for f in files:
        try:
            localFile = open(os.path.join(outdir,f), "wb") #build local file
            localFile.write(zf.read(f)) #write the zipped contents to local file
            localFile.close()
        except KeyError:
            print 'ERROR: Did not find %s in zip file' %f
    zf.close()
    
    #remove the original zip (not needed)
    os.remove(os.path.join(outdir,'test.zip'))

#function to download actual (not thumbnail) Earth Engine image
#==============================================================
def downloadEEImage(outdir,url):

    #request a given path to the file
    reqObj = Request(url)
    
    #open it up
    fileObj = urlopen(reqObj)
    
    #create a local file to hold the data we get (here "wb" is for "write binary")
    localFile = open(os.path.join(outdir,'test.zip'), "wb")
    
    #read from the file object, write to the local object. Then close.
    localFile.write(fileObj.read())
    localFile.close()
    
    unzipEEImage(outdir)
   
#get individual bands -> merge to single image
#=============================================
def mergeIm(outdir,imName,visType):
    
    if visType == 'TC' or visType == 'FC':    
        fname = os.path.join(outdir,imName)
        r = Image.open(fname+".vis-red.tif")
        g = Image.open(fname+".vis-green.tif")
        b = Image.open(fname+".vis-blue.tif")
        im = Image.merge("RGB", (r, g, b))
        r.close()
        g.close()
        b.close()
        del r,g,b
        im.save(fname+".tif")
        
        #remove individual bands (not needed)
        os.remove(fname+".vis-red.tif")
        os.rename(fname+".vis-red.tfw",fname+".tfw")
        os.remove(fname+".vis-green.tif")
        os.remove(fname+".vis-green.tfw")
        os.remove(fname+".vis-blue.tif")
        os.remove(fname+".vis-blue.tfw")
    else:
        ims = [f for f in os.listdir(outdir) if f.endswith('.tif')]
        in_name = os.path.join(outdir,ims[0])
        out_name = os.path.join(outdir,ims[0].split('.')[0]+'.tif')
        os.rename(in_name,out_name)
        tfws = [f for f in os.listdir(outdir) if f.endswith('.tfw')]
        os.remove(os.path.join(outdir,tfws[0]))