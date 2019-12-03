# -*- coding: utf-8 -*-
"""
Created on Mon Mar 12 16:45:39 2018

@author: hendrik_gt
"""

# -*- coding: utf-8 -*-
#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares for Three clicks to a ground watermodel
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

# $Id: getdata_overroads.py 14301 2018-04-16 08:40:40Z hendrik_gt $
# $Date: 2018-04-16 10:40:40 +0200 (Mon, 16 Apr 2018) $
# $Author: hendrik_gt $
# $Revision: 14301 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wegen/getdata_overroads.py $
# $Keywords: $

"""
the application makes use of the NWB wegvakken. This wegvakken is downloaded and uploaded into a PostGIS database
http://nationaalgeoregister.nl/geonetwork/srv/dut/catalog.search#/metadata/60caa9e5-60c5-4072-a575-e11ef5a07c40
"""
import os
import sqlfunctions
import requests, zipfile, StringIO
import rasterio
from rasterio.mask import mask
import json
import numpy as np

def roundCoords(px, py, resolution=5):
    return round(px/resolution)*resolution, round(py/resolution)*resolution    

def getcredentials():
    credentials = {}
    credentials['user'] = ''
    credentials['password']   = ''
    credentials['host']  = ''
    credentials['dbname'] = ''
    credentials['port'] = 5432    
    return credentials

# locations derived from https://maps.cityofirving.org/home/item.html?id=9039d4ec38ed444587c46f8689f0435e#data
def geturls():
    dct = {}
    dct['ahn2'] = ['http://geodata.nationaalgeoregister.nl/ahn2/extract/ahn2_5m/', 'ahn2_5_{}.tif.zip'] #download, basename
    dct['ahn3'] = ['https://geodata.nationaalgeoregister.nl/ahn3/extract/ahn3_5m_dtm/', 'M5_{}.ZIP'] #Absolute depth to bedrock
    return dct

def getwcsurls():
    dct = {}
    dct['ahn2'] = ['http://geodata.nationaalgeoregister.nl/ahn2/wcs?', 'ahn2:ahn2_5m','1.1.1']
    dct['ahn3'] = ['https://geodata.nationaalgeoregister.nl/ahn3/wcs?', 'ahn3:ahn3_5m_dtm','1.1.1']
    return dct


def downloadahn(unit,temppath,baseurl,basename):
    url = ''.join([baseurl,basename.format(unit)])
    print url
    try:
        r = requests.get(url, stream=True)  
        z = zipfile.ZipFile(StringIO.StringIO(r.content))
        z.extractall(path=temppath)
        #construct path
        fn = os.path.join(temppath,basename.format(unit)).replace('.zip','')
    except:
        fn =  None
    finally:
        return fn

# ok, laad die units en zorg ervoor dat die naam in onderstaande query ook opgehaald wordt
# per interesse weg (lijst van wegen)

def getlistofwegvakken(roadfilter,credentials):
    strSql = """SELECT wegvakken.wvk_id
                FROM wegvakken
                WHERE wegvakken.wgtype_oms IS NOT NULL and wegvakken.wegnr_hmp::text = '{}'::text""".format(roadfilter)
    a = sqlfunctions.executesqlfetch(strSql,credentials)
    return a

# clips rasters (fn) with a buffered road segment (wegvakid) and stores under the wegvak_id for both AHN2 and AHN3
def clipraster(fn,gjbuffer,n):
    print fn
    geoms = [json.loads(gjbuffer)]
    with rasterio.open(fn) as src:
        out_image, out_transform = mask(src, geoms, crop=True)
        print('writing '+fn.replace('.tif','_{}_clip.tif'.format(n)))
        out_meta = src.meta.copy()
        out_meta.update({"driver": "GTiff",
            "height": out_image.shape[1],
            "width": out_image.shape[2],
        "transform": out_transform})
        afile = fn.replace('.tif','_{}_clip.tif'.format(n))        
        with rasterio.open(afile, "w", **out_meta) as dest:
            dest.write(out_image)
            dest.close()
        return afile

def getrasterfromwcs(dctwcs, base, rbbox,temppath,name):
    from owslib.wcs import WebCoverageService        
    wcs = WebCoverageService(dctwcs[base][0],version=dctwcs[base][2],timeout=320)
    #wcs = WebCoverageService('https://geodata.nationaalgeoregister.nl/ahn3/wcs?',version='1.1.1',timeout=320)
    wcs = WebCoverageService('http://geodata.nationaalgeoregister.nl/ahn2/wcs?',version='1.1.1',timeout=320)
    wcs.identification.type
    wcs.identification.title
    #print list(wcs.contents)
    sed = wcs[list(wcs.contents)[2]]
    sed = wcs['ahn2:ahn2_5m']
    sed = wcs[dctwcs[base][1]]
    sed.grid.highlimits 
    sed.boundingboxes 
    cx, cy=map(int,sed.grid.highlimits)
    #Wat is cx, cy=map(int,sed.grid.highlimits)?
    bbox = sed.boundingboxes[0]['bbox'] 
    lx,ly,hx,hy = map(float,bbox) 
    resx, resy = (hx-lx)/cx, (hy-ly)/cy 
    width = cx
    height = cy

    requestbbox  =(rbbox)

    gc = wcs.getCoverage(identifier=sed.id,
                                   bbox=requestbbox,
                                   format='GeoTIFF',
                                   crs=sed.boundingboxes[0]['nativeSrs'],
                                   width=width,
                                   height=height)

    # choose where it will be saved step 4
    
    tmpdir = temppath
    fn = os.path.join(tmpdir,'.'.join([laag.split(':')[1]+'_'+name,'tif']))
    c = open(fn,'wb')
    c.write(gc.read())
    c.close()
    return fn

def getroundedbboxcoords(bbox):
    xll = float(bbox.replace('BOX(','').replace(')','').split(',')[0].split(' ')[0])
    yll = float(bbox.replace('BOX(','').replace(')','').split(',')[0].split(' ')[1])
    xul = float(bbox.replace('BOX(','').replace(')','').split(',')[1].split(' ')[0])
    yul = float(bbox.replace('BOX(','').replace(')','').split(',')[1].split(' ')[1])
    xyll = roundCoords(xll,yll)
    xyul = roundCoords(xul,yul)
    bbx = (xyll[0],xyll[1],xyul[0],xyul[1])
    return bbx

def gdalmerge(optfile,atif):
    import subprocess
    args = ['gdal_merge.bat', '-o',atif, '-a_nodata','-3.4028234663852886e+38', '--optfile',optfile]
    print(' '.join(args))
    try:
        subprocess.call(args)
    except BaseException as err:
        print err.args

def gdalcalc(atif2,atif3,temppath,roadnum):
    import subprocess
    resulttif = os.path.join(temppath,'{}_ahn3-ahn2.tif'.format(roadnum))
    args = ['gdal_calc.bat','-A',atif2,'-B',atif3,''.join(['--outfile=',resulttif]), '--calc="B-A"']
    print(' '.join(args))
    try:
        subprocess.call(args)
    except BaseException as err:
        print err.args 

# from here a loop over a list of wegvakken is intended

# someglobals
temppath = r'D:\projecten\datamanagement\Nederland\wegen\rasters'

credentials = getcredentials()

cf = r'D:\projecten\datamanagement\Nederland\wegen\credentials.txt'
credentials = sqlfunctions.get_credentials(cf)
lstroadnum = ['A58','A29','A16','A67','A73','A50','A30','A18','A35','A37']
lstroadnum = ['N11']
lstroadnum = ['A31','A76','A79']
roadnum = 'A29'
for roadnum in lstroadnum:
    a = getlistofwegvakken(roadnum,credentials)
    
    dct = geturls()
    dictwegvak = {}
    lstunits = []
    lstahn2 = []
    lstahn3 = []
    
    for wegvak in a:
        strSql = """SELECT w.wvk_id::text,unit, st_asgeojson(st_buffer(w.geom,250))
                    FROM wegvakken w
                    JOIN ahn_units a on st_intersects(a.geom,w.geom)
                    WHERE w.wvk_id = {}""".format(int(wegvak[0]))
        abuffer = sqlfunctions.executesqlfetch(strSql,credentials)
        wegvakahn2 = []
        wegvakahn3 = []
        # first check if the unit is already downloaded
        for w in abuffer:
            unit = w[1]
            for lidar in ['ahn2','ahn3']:
                baseurl = dct[lidar][0]
                basename = dct[lidar][1]
                if lidar == 'ahn2':
                    wegvakahn2.append(basename.format(unit).replace('.zip',''))
                elif lidar == 'ahn3':
                    wegvakahn3.append(basename.format(unit).replace('.ZIP','.tif'))
            
            if w[1] not in lstahn2: 
                # for each unit in the buffer download the data
                baseurl = dct['ahn2'][0]
                basename = dct['ahn2'][1]
                print(' '.join(['downloading',lidar,unit]))
                lstahn2.append(unit)
                if not os.path.isfile(os.path.join(temppath,basename.format(unit)).replace('.zip','')):
                    ahn2 = downloadahn(unit,temppath,baseurl,basename)
    
            if w[1] not in lstahn3: 
                # for each unit in the buffer download the data
                baseurl = dct['ahn3'][0]
                basename = dct['ahn3'][1]
                lstahn3.append(unit)
                print(' '.join(['downloading',lidar,unit]))
                if not os.path.isfile(os.path.join(temppath,basename.format(unit)).replace('.zip','')):
                    ahn3 = downloadahn(unit.upper(),temppath,baseurl,basename)
        # the buffer is stored in a dictionary per wegvakid
        dictwegvak[wegvak[0]] = (abuffer[0][2],wegvakahn2,wegvakahn3)
       
    # selecteer voor de buffer de atlasblokken noodzakelijk (kan in dezelfde query)
    listahn2clipped = []
    listahn3clipped = []
    for k in dictwegvak.keys():
        gjbuffer = dictwegvak[k][0]
        ahn2 = dictwegvak[k][1]
        ahn3 = dictwegvak[k][2]
        a2=0
        a3=0
        for l2 in ahn2:
            a2=a2+1
            fn = os.path.join(temppath,l2)
            if os.path.isfile(fn):
                clip2 = clipraster(fn,gjbuffer,'_'.join([str(int(k)),str(a2)]))
                listahn2clipped.append(clip2)
        for l3 in ahn3:
            a3=a3+1
            fn = os.path.join(temppath,l3)
            if os.path.isfile(fn):
                clip3 = clipraster(fn,gjbuffer,'_'.join([str(int(k)),str(a3)]))
                listahn3clipped.append(clip3)
    
    optfile2 = os.path.join(temppath,'fnahn2.lst')
    f2 = open(optfile2,'w+')
    f2.write(' '.join(listahn2clipped))
    f2.close()
    atif2 = os.path.join(temppath,'{}_ahn2.tif'.format(roadnum))
    
    
    optfile3 = os.path.join(temppath,'fnahn3.lst')
    f3 = open(optfile3,'w+')
    f3.write(' '.join(listahn3clipped))
    f3.close()
    atif3 = os.path.join(temppath,'{}_ahn3.tif'.format(roadnum))
    
    gdalmerge(optfile2,atif2)
    gdalmerge(optfile3,atif3)
    gdalcalc(atif2,atif3,temppath,roadnum)





"""
#################################################
deprecated perhaps useful stuf
"""


# save the resulting raster  

# download die blokken, houd bij welke blokken gedownload zijn



# maak een verschilraster
# ruim na een weg alle blokken op
strSql = """SELECT wegvakken.wvk_id::text,st_asgeojson(st_buffer(wegvakken.geom,250))
            FROM wegvakken
            WHERE wegvakken.wegnr_hmp::text = 'A20'::text AND wegvakken.wgtype_oms IS NOT NULL AND wegvakken.wvk_id = 200285004"""
a = sqlfunctions.executesqlfetch(strSql,credentials)

for w in a:
    name = w[0]
    gjbuffer = w[1]




baseurl = 'http://geodata.nationaalgeoregister.nl/ahn2/extract/ahn2_5m/'
baseurl3 = 'https://geodata.nationaalgeoregister.nl/ahn3/extract/ahn3_5m_dtm/'
#ahn2_5_10az2.tif.zip
unit = '38az1'    
basename = 'ahn2_5_{}.tif.zip'
basename3 = 'R5_01CZ1.ZIP'

import rasterio
from rasterio.mask import mask
from shapely.geometry import mapping
import geopandas as gpd
import json
import numpy as np
def clipraster(fn,gjbuffer):
    geoms = [json.loads(gjbuffer)]
    with rasterio.open(fn) as src:
        out_image, out_transform = mask(src, geoms, crop=True)
        no_data=src.nodata
        data = out_image.data[0]
        row, col = np.where(data != no_data) 
        elev = np.extract(data != no_data, data)
        
# werkend stukje, maar er wordt nu gebruikgemaakt van postgis geosjon
shapefile = gpd.read_file(r'D:\projecten\datamanagement\Nederland\wegen\nwb-wegen\stukje_buffer.shp')
geoms = shapefile.geometry.values # list of shapely geometries
geometry = geoms[0] # shapely geometry
# transform to GeJSON format
from shapely.geometry import mapping
geoms = [mapping(geoms[0])]        



"""
deprecated stuf
below is the WCS part, not known why this is not working with the AHN2 data from NGR.
"""
credentials = getcredentials()
wegvak = ['193281039']
import sqlfunctions
strSql = """SELECT w.wvk_id::text,unit, st_extent(st_buffer(w.geom,250))
                FROM wegvakken w
                JOIN ahn_units a on st_intersects(a.geom,w.geom)
                WHERE w.wvk_id = {}
                group by w.wvk_id, unit""".format(int(wegvak[0]))
abuffer = sqlfunctions.executesqlfetch(strSql,credentials)

lstahn2 = []
lstahn3 = []
dctwcs = getwcsurls()
for w in abuffer:
    bbox = w[2]
    xll = float(bbox.replace('BOX(','').replace(')','').split(',')[0].split(' ')[0])
    yll = float(bbox.replace('BOX(','').replace(')','').split(',')[0].split(' ')[1])
    xul = float(bbox.replace('BOX(','').replace(')','').split(',')[1].split(' ')[0])
    yul = float(bbox.replace('BOX(','').replace(')','').split(',')[1].split(' ')[1])
    xyll = roundCoords(xll,yll)
    xyul = roundCoords(xul,yul)
    bbx = (xyll[0],xyll[1],xyul[0],xyul[1])
    name = w[0]
    for ahn in dctwcs.keys():
        if ahn == 'ahn2':
            agtif = getrasterfromwcs(dctwcs, ahn, bbx,temppath,name)
            lstahn2.append(agtif)
        if ahn == 'ahn3':
            agtif = getrasterfromwcs(dctwcs, ahn, bbx,temppath,name)
            lstahn3.append(agtif)



    

# the main part 
#Dictionary step1
dct = {}
dct['ahn2'] = ['http://localhost:8080/geoserver/ows?', 'nederland:ahn2','wcs'] #Absolute depth to bedrock
dct['ahn2'] = ['http://geodata.nationaalgeoregister.nl/ahn2/wcs?', 'ahn2:ahn2_5m','wcs'] #Absolute depth to bedrock
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

bbx = (102836,444081,102938,444673)
xll = rbbox[0]
yll = rbbox[1]
xul = rbbox[2]
yul = rbbox[3]


url, laag = (dct['ahn2'][0], dct['ahn2'][1])
temppath = r'D:\projecten\datamanagement\Nederland\wegen\rasters'
#agtif = getrasterfromwcs(dct['ahn2'][0], dct['ahn2'][1], rbbox,temppath)



strSql = """SELECT wegvakken.wvk_id::text,
    st_extent(wegvakken.geom),
    wegvakken.wegnr_hmp,
    wegvakken.wgtype_oms
   FROM wegvakken
  WHERE wegvakken.wegnr_hmp::text = 'A20'::text AND wegvakken.wgtype_oms IS NOT NULL
  group by wegvakken.geom,wegvakken.wvk_id,wegvakken.wegnr_hmp,wegvakken.wgtype_oms"""

a = sqlfunctions.executesqlfetch(strSql,credentials)
lsttif = []
for w in a:
    bbox = w[1]
    xll = float(bbox.replace('BOX(','').replace(')','').split(',')[0].split(' ')[0])
    yll = float(bbox.replace('BOX(','').replace(')','').split(',')[0].split(' ')[1])
    xul = float(bbox.replace('BOX(','').replace(')','').split(',')[1].split(' ')[0])
    yul = float(bbox.replace('BOX(','').replace(')','').split(',')[1].split(' ')[1])
    xyll = roundCoords(xll,yll)
    xyul = roundCoords(xul,yul)
    bbx = (xyll[0],xyll[1],xyul[0],xyul[1])
    name = w[0]
    
    agtif = getrasterfromwcs(dct['ahn2'][0], dct['ahn2'][1], bbx,temppath,name)
    lsttif.append(agtif)


# per wegvak maak een buffer en selecteer
# dit moet in een for loop komen te staan, wcs downloaden werkt niet.
dct = getwcsurls()
for wegvak in a:
    strSql = """SELECT w.wvk_id::text,unit, st_asgeojson(st_buffer(w.geom,250)),st_extent(st_buffer(w.geom,250))
                FROM wegvakken w
                JOIN ahn_units a on st_intersects(a.geom,w.geom)
                WHERE w.wvk_id = {}
                GROUP BY w.wvk_id,unit,w.geom""".format(int(wegvak[0]))
    bufferedroads = sqlfunctions.executesqlfetch(strSql,credentials)
    wegvakahn2 = []
    wegvakahn3 = []
    # first check if the unit is already downloaded
    for w in bufferedroads:
        unit = w[1]
        rbbox = getroundedbboxcoords(w[3])
        name = w[0]
        for base in ['ahn2','ahn3']:
            aras = getrasterfromwcs(dct, base, rbbox,temppath,'_'.join([name,base]))
    