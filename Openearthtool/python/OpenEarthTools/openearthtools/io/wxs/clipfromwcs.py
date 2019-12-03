# -*- coding: utf-8 -*-
#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares for Three clicks to a ground watermodel
#   Gerrit Hendriksen@deltares.nl
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

# $Id: orm_subsurface.py 13354 2017-05-16 12:45:29Z hendrik_gt $
# $Date: 2017-05-16 14:45:29 +0200 (Tue, 16 May 2017) $
# $Author: hendrik_gt $
# $Revision: 13354 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/datamodel/subsurface/orm_subsurface.py $
# $Keywords: $


import os
#Dictionary step1
dct = {}
dct['laag0'] = ['http://webservices.isric.org/geoserver/ows?', 'geonode:bdticm_m_250m','wcs'] #Absolute depth to bedrock
#dct['laag1'] = ['http://fast.openearth.eu/geoserver/Global_Maps/ows?','Global_Maps:Global Topography and Bathymetry (SRTMplus15)','wcs']  # global elevation SRTM  
#dct['laag2'] = ['http://chw.openearth.eu/geoserver/GeologicalLayout/ows?','GeologicalLayout:glim_v01_export','wfs']
#dct['laag3'] = ['http://deltaresdata.openearth.nl/geoserver/ows?','global:Sediment Thickness of the World','wcs']
#dct['laag4'] = ['http://localhost:8080/geoserver/global/ows?','global:glhymps','wfs'] # porosity and permeability

"""
This functions downloads a raster to GTIFF from a WCS. 
Inputs are:
- url of the WCS (i.e.'http://webservices.isric.org/geoserver/ows?')
- layername
- bounding box (xmin,ymin,xmax,ymax)
"""
def getrasterfromwcs(url, laag, rbbox):
    from owslib.wcs import WebCoverageService        
    wcs = WebCoverageService(url,version='1.0.0',timeout=320)
    wcs.identification.type
    wcs.identification.title
    #print list(wcs.contents)
    
    sed = wcs[laag]
    #sed = wcs['global:Sediment Thickness of the World'] sed.keywords 
    sed.grid.highlimits 
    sed.boundingboxes 
    cx, cy=map(int,sed.grid.highlimits)
    #Wat is cx, cy=map(int,sed.grid.highlimits)?
    bbox = sed.boundingboxes[0]['bbox'] 
    lx,ly,hx,hy = map(float,bbox) 
    resx, resy = (hx-lx)/cx, (hy-ly)/cy 
    width = cx/100
    height = cy/100

    requestbbox  =(rbbox)

    gc = wcs.getCoverage(identifier=sed.id,
                                   bbox=requestbbox,
                                   format='GeoTIFF',
                                   crs=sed.boundingboxes[0]['nativeSrs'],
                                   width=width,
                                   height=height)

    # choose where it will be saved step 4
    
    tmpdir = r'C:\data\temp\test'
    fn = os.path.join(tmpdir,'.'.join([laag.split(':')[1],'tif']))
    c = open(fn,'wb')
    c.write(gc.read())
    c.close()
    return fn

