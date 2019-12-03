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
#=============================================
#Input/Output Functions for Feature Extraction
#=============================================
#JFriedman
#Apr 19/2016
#=============================================

#import all necessary packages
#=============================
import os
import simplekml
import json
import datetime as dt
import numpy as np
from PIL import Image
import matplotlib.cm as cm
from pyproj import Proj, transform

#convert to cartesian coordinates to determine possible zones
#============================================================
def ConvertCoordinates(EPSGin, EPSGout, x1, y1):
	inProj = Proj(init='epsg:%s' % EPSGin)  #fixed since coming from OSMaps -> lat/lon
	outProj = Proj(init='epsg:%s' % EPSGout)  #variable based on location!
	xy = transform(inProj, outProj, x1, y1)
	return xy

#build output folder based on name
#=================================
def PathBuilder(curr, name):
	outdir = os.path.join(curr, name)
	if not os.path.exists(outdir):
		os.makedirs(outdir)
	return outdir

#extract the image, its date and real world extents
#==================================================
def getImage(fid, tempdir):
	#load the image and its date
	img = Image.open(os.path.join(tempdir, fid))
	dater = dt.datetime.strptime(fid[-19:-4], '%Y%m%d_%H%M%S')  #HARD-CODED FOR DATE!

	#load world file for georeferencing satellite image
	if fid.endswith('.png'):
		fidw = fid.replace('.png', '.pgw')
	else:
		fidw = fid.replace('.tif', '.tfw')
	with open(os.path.join(tempdir, fidw), 'r') as f:  #read world file
		info = f.readlines()
	info = [float(i) for i in info]

	#get pixel size (in px,py) and origin (x0,y0)
	px = info[0]
	py = info[3]
	x0 = info[4]
	y0 = info[5]

	#build spatial extents from world file
	[m, n] = img.size
	xlims = [x0, x0 + px * m]
	ylims = [y0 + py * n, y0]

	return img, dater, xlims, ylims

#save JSON data from features for possible later processing
#=============================================================
def dumpJSON(fout, xy):
	with open(fout, 'w') as f:
		json.dump(xy, f, indent=2)

#write out the coastline results into *.ldb file (later analysis)
#================================================================
def writeLDB(fout, xy):
	with open(fout, 'w') as f:
		f.write('*column 1 = x coordinate\n')
		f.write('*column 2 = y coordinate\n')
		f.write('   1\n')
		num_vals = len(xy)
		f.write('%d 2\n' % num_vals)

		for jj in range(num_vals):
			f.write('%f %f\n' % (1000 * xy[jj][0], 1000 * xy[jj][1]))

#read all *.ldb files for processing into a *.kml
#================================================
def readLDB(fid):
	with open(fid, 'r') as f:
		temp = f.readlines()

	#get date from filename for dynamic link in GE
	d = fid.split('_')
	d = '_'.join([d[-2], d[-1]]).replace('.ldb', '')
	dater = dt.datetime.strptime(d, '%Y%m%d_%H%M%S')

	#get coordinates and format to zipped tuple
	coords = [coords.split() for coords in temp if not coords.startswith('*')]
	coords.pop(0)  #remove the "1"
	coords.pop(0)  #remove the number of coordinates
	coords = [(float(c[0]), float(c[1])) for c in coords]

	return coords, dater

#visualize extracted features in a single kml
#===========================================  
def buildKML(name, imdir, ldbdir):
	
	#get all *.ldb files in analysis directory
	fids = [f for f in os.listdir(ldbdir) if f.endswith('.ldb')]

	#get EPSG code for properly displaying it in GE
	EPSG = [f.replace('.epsg', '') for f in os.listdir(imdir) if f.endswith('.epsg')]
	EPSG = int(EPSG[0])

	#get info for each extracted feature
	coords = []
	dater = []
	for fid in fids:
		c, d = readLDB(os.path.join(ldbdir, fid))
		coords.append(c)
		dater.append(d)

	#number of images available
	num = len(coords)  #number of images
	color = cm.Reds(np.linspace(0.15, 0.85, num))  #build colormap

	#blank kml
	kml = simplekml.Kml()

	ind = 0
	for c, d in zip(coords, dater):
		[x, y] = ConvertCoordinates(EPSG, 4326, [x[0] for x in c], [x[1] for x in c])
		date_out = dt.datetime.strftime(d, '%Y/%m/%d %H:%M:%S')
		lin = kml.newlinestring(name=date_out, coords=zip(x, y))
		lin.style.linestyle.color = simplekml.Color.rgb(color[ind][0] * 255, color[ind][1] * 255,
		                                                color[ind][2] * 255, color[ind][3] * 255)
		lin.style.linestyle.width = 3
		lin.timespan.begin = dt.datetime.strftime(d, '%Y-%m-%d')
		lin.timespan.end = dt.datetime.strftime(d, '%Y-%m-%d')
		lin.AltitudeMode = 'clampToGround'
		ind += 1

	temp = os.path.join(ldbdir, "%s_Extracted_Features.kml" % name)
	kml.save(temp)
	

	