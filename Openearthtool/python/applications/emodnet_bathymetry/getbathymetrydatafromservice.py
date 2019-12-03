# -*- coding: utf-8 -*-
"""
Created on Tue Nov 08 13:49:34 2016

@author: Gerrit Hendriksen

#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares for EMODnet Chemistry
#       Gerrit Hendriksen
#       gerrit.hendriksen@deltares.nl
#       Giorgio Santinelli
#       giorgio.santinelli@deltares.nl
#
#   This library is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
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
# This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
# OpenEarthTools is an online collaboration to share and manage data and
# programming tools in an open source, version controlled environment.
# Sign up to recieve regular updates of this function, and to contribute
# your own tools.

# $Id: getbathymetrydatafromservice.py 13423 2017-06-29 13:46:32Z hendrik_gt $
# $Date: 2017-06-29 06:46:32 -0700 (Thu, 29 Jun 2017) $
# $Author: hendrik_gt $
# $Revision: 13423 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/emodnet_bathymetry/getbathymetrydatafromservice.py $
# $Keywords: $
"""
import os
import tempfile
from owslib.wcs import WebCoverageService
from osgeo import gdal
import urllib2
import pandas
from owslib.fes import *    

def getwcsconnection(url):
    try:
        wcs = WebCoverageService(url,version='1.0.0',timeout=320)
        wcs.identification.type
        wcs.identification.title
        #list(wcs.contents)
        return wcs
    except:
        print(' '.join(['error occurred while retrieving wcs for url',url]))
        return False
    
def getpointdata(wcs, layer, pnt,clipfile):
    sed = wcs[layer]
    sed.keywords
    sed.grid.highlimits
    sed.boundingboxes
    cx, cy = map(int,sed.grid.highlimits)
    bbox = sed.boundingboxes[0]['bbox']
    lx,ly,hx,hy = map(float,bbox)
    resx, resy = (hx-lx)/cx, (hy-ly)/cy
    px,py = map(float,pnt)
    gc = wcs.getCoverage(identifier='emodnet:mean',
                         bbox=[px-resx,py-resy,px+resx,py+resy],
                         format='GeoTIFF',
                         crs=sed.boundingboxes[0]['nativeSrs'],
                         width=1,
                         height=1)
    fn = clipfile
    f = open(fn,'wb')
    f.write(gc.read())
    f.close()                           
                         
def cliplayer(wcs, layer, requestbbox,clipfile):
    bathyml = 'emodnet:mean'
    sed = wcs[layer]
    sed.keywords
    sed.grid.highlimits
    sed.boundingboxes
    cx, cy = map(int,sed.grid.highlimits)
    bbox = sed.boundingboxes[0]['bbox']
    lx,ly,hx,hy = map(float,bbox)
    resx, resy = (hx-lx)/cx, (hy-ly)/cy
    width = cx/1000
    height = cy/1000
    
    gc = wcs.getCoverage(identifier=bathyml,
                         bbox=requestbbox,
                         coverage=sed,
                         format='GeoTIFF',
                         crs=sed.boundingboxes[0]['nativeSrs'],
                         width=width,
                         height=height)
    
    fn = clipfile
    f = open(fn,'wb')
    f.write(gc.read())
    f.close()
    img = getgdalobject(clipfile)
    os.unlink(clipfile)
    return img,resx,resy
    
def getgdalobject(fname):
    filetiff = gdal.Open(fname)
    theImage = filetiff.GetRasterBand(1).ReadAsArray()
    filetiff = None
    return theImage

def plotraster(img,resx,resy,bbox):
    from mpl_toolkits.mplot3d import Axes3D
    import matplotlib.pyplot as plt
    from matplotlib import cm
    from matplotlib.ticker import LinearLocator, FormatStrFormatter
    import numpy as np
    
    fig = plt.figure(figsize=(15, 15))
    ax = fig.gca(projection='3d')
    
    # Make data.
    X = np.linspace(bbox[0],bbox[2], img.shape[1])
    Y = np.linspace(bbox[1],bbox[3], img.shape[0])
    X, Y = np.meshgrid(X, Y)
    #R = np.sqrt(X**2 + Y**2)
    #Z = np.sin(R)
    Z = img
    # Plot the surface.
    surf = ax.plot_surface(X, Y, Z, cmap=cm.coolwarm,
                           linewidth=0, antialiased=False)
    
    # Customize the z axis.
    ax.set_zlim(Z.min().round(), Z.max().round())
    ax.zaxis.set_major_locator(LinearLocator(10))
    ax.zaxis.set_major_formatter(FormatStrFormatter('%.f'))
    
    # Add a color bar which maps values to colors.
    fig.colorbar(surf, shrink=0.5, aspect=5)
    
    plt.show()

def plotraster2(img,df,resx,resy,bbox):
    from mpl_toolkits.mplot3d import Axes3D
    import matplotlib.pyplot as plt
    from matplotlib import cm
    from matplotlib.ticker import LinearLocator, FormatStrFormatter
    import numpy as np
    
    fig = plt.figure()
    ax = fig.gca(projection='3d')

    #plot the vectors
    xv = df['Longitude']
    yv = df['Latitude']
    zv = df['MaximumDepth']
    ax.scatter(xv,yv,zv,label=df['ObservedIndividualCount'])
    
    # Make data.
    X = np.linspace(bbox[0],bbox[2], img.shape[1])
    Y = np.linspace(bbox[1],bbox[3], img.shape[0])
    X, Y = np.meshgrid(X, Y)
    #R = np.sqrt(X**2 + Y**2)
    #Z = np.sin(R)
    Z = img
    # Plot the surface.
    surf = ax.plot_surface(X, Y, Z, cmap=cm.coolwarm,
                           linewidth=0, antialiased=False,alpha=0.5)
    
    # Customize the z axis.
    ax.set_zlim(Z.min().round(), Z.max().round())
    ax.zaxis.set_major_locator(LinearLocator(10))
    ax.zaxis.set_major_formatter(FormatStrFormatter('%.f'))
    
    # Add a color bar which maps values to colors.
    fig.colorbar(surf, shrink=0.5, aspect=5)
    plt.savefig(r'd:\temp\emodnet\test.png',dpi=600)
    
    plt.show()

def clipwfs(bbox):
    from clipfromwfs import selectfromwfs

    """Get Species from EMODNet Biology"""
    wfs = 'http://geo.vliz.be/geoserver/Eurobis/ows?'  
    layer = 'Eurobis:eurobis_points'
    afilter = PropertyIsEqualTo(propertyname='Eurobis:ScientificName', literal='Amphiura filiformis')
    
    """define pandas dataframe for the output"""
    iocsv = selectfromwfs(wfs,layer,afilter,bbox)
    fn = r'd:\temp\emodnet\test.csv'
    out = open(fn, 'wb')
    out.write(iocsv.read())
    out.close()
    df = pandas.read_csv(fn,header=0,sep=',')
    os.unlink(fn)
    return df

def testandplot():
    url = 'http://ows.emodnet-bathymetry.eu/wcs'
    awcs = getwcsconnection(url)
    clipfile = r'D:\temp\emodnet\bathmcheckfinal.tif'
    requestbbox  =(-9.79,64.11,-3.87,66.26)    
    requestbbox = (2.097,52.715,4.277,53.935)
    layer = 'emodnet:mean_atlas_land'
    img,resx,resy = cliplayer(awcs, layer, requestbbox,clipfile)
    #plotraster(img,resx,resy,requestbbox)
    # subset the df (minimumdepth != NaN )
    df = clipwfs(requestbbox)
    adf = df[df['MinimumDepth']>0.]
    plotraster2(img,adf,resx,resy,requestbbox)

    # testen https://plot.ly/pandas/3d-scatter-plots/
    #plt.figure()
    #plt.scatter(df.Longitude, df.Latitude, s=df.ObservedIndividualCount)
