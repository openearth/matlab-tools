#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
#       Gerben Hagenaars
#
#       Gerben.Hagenaars@deltares.nl
#       
#       Wiebe de Boer
#
#       Wiebe.deBoer@deltares.nl
#
#       P.O. Box 177
#       2600 MH Delft
#       The Netherlands
#
#   This library is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Lesser General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this library.  If not, see <http://www.gnu.org/licenses/>.
#   --------------------------------------------------------------------
#
# This tool is developed as part of the research cooperation between
# Deltares and the Korean Institute of Science and Technology (KIOST).
# The development is funded by the CoMIDAS project of the South Korean
# government and the Deltares strategic research program Coastal and
# Offshore Engineering. This financial support is highly appreciated.
#
#=====================================
#Earth Engine Download Functions
#=====================================
#JFriedman
#Nov 30/2015
#=====================================

#import all necessary packages
#=============================
import os
import ee
import zipfile
from urllib2 import Request, urlopen
from PIL import Image

#function to download actual (not thumbnail) Earth Engine image
#==============================================================
def buildEEImage(im, visType, imName, imScale, imType, imBounds, EPSGout):
	#determine type of output image
	if visType == 'TC':
		vis_bands = 'R,G,B'
		vis_bands2 = ['R', 'G', 'B']
	elif visType == 'FC':
		vis_bands = 'SWIR,NIR,G'
		vis_bands2 = ['SWIR', 'NIR', 'G']

	#visualize image based on user-selected type (only if needed!)
	if visType == 'TC' or visType == 'FC':
		temp = im.select(vis_bands2).reduceRegion(reducer=ee.Reducer.mean(),
		                                          geometry=ee.Geometry.Polygon(imBounds), scale=imScale * 10).getInfo()
		mu = [temp[v] for v in vis_bands2]

		temp = im.select(vis_bands2).reduceRegion(reducer=ee.Reducer.stdDev(),
		                                          geometry=ee.Geometry.Polygon(imBounds), scale=imScale * 10).getInfo()
		sig = [temp[v] for v in vis_bands2]

		if not any(mu) or not any(sig):

			url = 0
			return url  #error code -> don't download image (doesn't overlap with region)

		else:
			minner = [max([0, m - 3 * s]) for m, s in zip(mu, sig)]
			maxxer = [m + 3 * s for m, s in zip(mu, sig)]

			visparams = {'bands': vis_bands, 'min': minner, 'max': maxxer, 'gamma': 1.5}
			im = im.visualize(**visparams)

	#export visualized image
	url = im.getDownloadURL({'name': imName, 'scale': imScale,
	                         'format': imType, 'region': imBounds, 'crs': 'EPSG:' + str(EPSGout)})

	return url


#function to unzip downloaded image from Earth Engine
#====================================================
def unzipEEImage(outdir):

    #read contents of zip file
    if zipfile.is_zipfile(os.path.join(outdir, 'test.zip')):
    
        zf = zipfile.ZipFile(os.path.join(outdir, 'test.zip'), 'r')    
        files = zf.namelist()
    
        #extract contents of zip file (loop through contents -> i.e. "files")
        for f in files:
            try:
                localFile = open(os.path.join(outdir, f), "wb")  #build local file
                localFile.write(zf.read(f))  #write the zipped contents to local file
                localFile.close()
            except KeyError:
                print 'ERROR: Did not find %s in zip file' % f
        zf.close()

    #remove the original zip (not needed)
    os.remove(os.path.join(outdir, 'test.zip'))


#function to download actual (not thumbnail) Earth Engine image
#==============================================================
def downloadEEImage(outdir, url):
    
    #request a given path to the file
    reqObj = Request(url)
    
    f = file(os.path.join(outdir,'url.txt'),'w')
    f.write(url)
    f.close()

    #open it up
    fileObj = urlopen(reqObj)

    #create a local file to hold the data we get (here "wb" is for "write binary")
    localFile = open(os.path.join(outdir, 'test.zip'), "wb")

    #read from the file object, write to the local object. Then close.
    localFile.write(fileObj.read())
    localFile.close()

    unzipEEImage(outdir)


#get individual bands -> merge to single image
#=============================================
def mergeIm(outdir, imName, visType):
	if visType == 'TC' or visType == 'FC':
		fname = os.path.join(outdir, imName)
		r = Image.open(fname + ".vis-red.tif")
		g = Image.open(fname + ".vis-green.tif")
		b = Image.open(fname + ".vis-blue.tif")
		im = Image.merge("RGB", (r, g, b))
		r.close()
		g.close()
		b.close()
		del r, g, b
		im.save(fname + ".tif")

		#remove individual bands (not needed)
		os.remove(fname + ".vis-red.tif")
		os.rename(fname + ".vis-red.tfw", fname + ".tfw")
		os.remove(fname + ".vis-green.tif")
		os.remove(fname + ".vis-green.tfw")
		os.remove(fname + ".vis-blue.tif")
		os.remove(fname + ".vis-blue.tfw")
	else:
		ims = [f for f in os.listdir(outdir) if f.endswith('.tif')]
		in_name = os.path.join(outdir, ims[0])
		out_name = os.path.join(outdir, ims[0].split('.')[0] + '.tif')
		os.rename(in_name, out_name)
		tfws = [f for f in os.listdir(outdir) if f.endswith('.tfw')]
		os.remove(os.path.join(outdir, tfws[0]))