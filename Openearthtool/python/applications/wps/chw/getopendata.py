# -*- coding: utf-8 -*-
"""
Created on Wed Nov 18 14:01:45 2015

@authors:
WCS/Linesect: Maarten Pronk (maarten.pronk@deltares.nl)
Hazard code generation: Alex Levering (alex.levering@deltares.nl)
"""

# STANDARD MODULES
from os import path
import string
from random import choice
import tempfile
from StringIO import StringIO
import logging

# NON STANDARD MODULES
import owslib.wcs as ogcwcs
import sqlfunctions
import pyproj
import json
import numpy as np
import scipy.ndimage as spi
import matplotlib.pyplot as plt 
from osgeo import gdal
from shapely import wkt

'''
All unused modules, preserved for the sake of documentation
import netCDF4 as netcdf
import subprocess
import shutil
from scipy.interpolate import interp1d
import datetime
'''

cf = 'C:\pywps\pywps_processes\pgconnection.txt'

class WCS:
    """WCS object to get metadata etc and to get grid."""
    def __init__(self,host,layer):
        self.id = layer
        logging.info(' '.join(['trying to get',layer,'from',host]))
        try:
            self.wcs = ogcwcs.WebCoverageService(host,version='1.0.0')
        except:
            logging.error("WCS host unavailable")   
        self.layer = self.wcs[self.id]
        _, self.format, self.identifier = self.layer.keywords
        self.cx, self.cy = map(int,self.layer.grid.highlimits)
        self.crs = self.layer.boundingboxes[0]['nativeSrs']
        self.bbox = self.layer.boundingboxes[0]['bbox']
        self.lx,self.ly,self.hx,self.hy = map(float,self.bbox)
        self.resx, self.resy = (self.hx-self.lx)/self.cx, (self.hy-self.ly)/self.cy
        self.width = self.cx
        self.height = self.cy
        
    def getw(self):
        """Downloads raster and returns filename of written GEOTIFF in the tmp dir."""
#        print self.cx,
#        print self.bbox
#        print self.width
#        print self.height
        gc = self.wcs.getCoverage(identifier=self.id,
                                  bbox=self.bbox,
                                  format='GeoTIFF',
                                  crs=self.crs,
                                  width=self.width,
                                  height=self.height)
        # random unique filename
        tmpdir = tempfile.gettempdir()
        filename = ''.join(choice(string.ascii_uppercase + string.digits) for _ in range(7))+'.tif'
        fn = path.join(tmpdir,filename)
        f = open(fn,'wb')
        f.write(gc.read())
        gc.close()
        f.close()
        return fn

class LS:
    """Intersection on grid line"""
    def __init__(self,wkt,crs,host,layer,sampling=1):
       #logging.info('LS __init__')
        self.wkt = wkt
        self.crs = crs
        self.gs = WCS(host,layer) # Initiates WCS service to get some parameters about the grid.
        self.sampling = sampling
                
    def line(self):
       #logging.info('LS line')
        """Creates WCS parameters and sample coordinates for cells in raster based on line input."""
        
        self.ls =  wkt.loads(self.wkt)
        self.ax, self.ay, self.bx, self.by = self.ls.bounds
        # TODO http://stackoverflow.com/questions/13439357/extract-point-from-raster-in-gdal
        
        """if first x is larger than second, coordinates will be flipped during process of defining bounding box !!!!
           next lines introduce a boolean flip variable used in the last part of this proces"""
        flipx = False
        flipy = False
        ax, bx = self.ls.coords.xy[0]
        ay, by = self.ls.coords.xy[1]
        #logging.info(';'.join([str(ax),str(ay),str(bx),str(by)]))
        if ax >= bx:
            flipx = True
        if ay >= by:
            flipy = True
        
        """get raster coordinates"""

        self.ax = self.ax - self.gs.lx # coordinates minus coordinates of raster, start from 0,0
        self.ay = self.ay - self.gs.ly
        self.bx = self.bx - self.gs.lx
        self.by = self.by - self.gs.ly
        self.x1, self.y1 = int(self.ax // self.gs.resx), int(self.ay // self.gs.resy)
        self.x2, self.y2 = int(self.bx // self.gs.resx)+1, int(self.by // self.gs.resy)+1
        self.gs.bbox = (self.x1*self.gs.resx+self.gs.lx,
                        self.y1*self.gs.resy+self.gs.ly, 
                        self.x2*self.gs.resx+self.gs.lx, 
                        self.y2*self.gs.resy+self.gs.ly)
        self.gs.width = abs(self.x2-self.x1) # difference of x cells
        self.gs.height = abs(self.y2-self.y1)

        """ here we go back to our line again instead of calculating bbox for wcs request."""
        self.ax, self.bx = self.ls.coords.xy[0]
        self.ay, self.by = self.ls.coords.xy[1]
        geod = pyproj.Geod(ellps='WGS84') # hardcoded, should be changed
        _,_,self.length = geod.inv(self.ax,self.ay,self.bx,self.by) # length in meters
       #logging.info('length ' + str(self.length))
        self.ax = self.ax - self.gs.lx # coordinates minus coordinates of raster, start from 0,0
        self.ay = self.ay - self.gs.ly
        self.bx = self.bx - self.gs.lx
        self.by = self.by - self.gs.ly   
        
        if flipx and flipy: # who draws these lines?
            # top right to bottom left
           #logging.info("Both flipped")        
            self.x2, self.y2 = int(self.bx // self.gs.resx), int(self.by // self.gs.resy)
            self.x1, self.y1 = int(self.ax // self.gs.resx)+1, int(self.ay // self.gs.resy)+1
        elif flipx:
            # bottom right to top left
           #logging.info("X flipped")        
            self.x2, self.y1 = int(self.bx // self.gs.resx), int(self.ay // self.gs.resy)
            self.x1, self.y2 = int(self.ax // self.gs.resx)+1, int(self.by // self.gs.resy)+1
        elif flipy:
            # top left to bottom right
           #logging.info("Y flipped")        
            self.x1, self.y2 = int(self.ax // self.gs.resx), int(self.by // self.gs.resy)
            self.x2, self.y1 = int(self.bx // self.gs.resx)+1, int(self.ay // self.gs.resy)+1
        else: 
            # normal
           #logging.info("Normal line")        
            self.x1, self.y1 = int(self.ax // self.gs.resx), int(self.ay // self.gs.resy)
            self.x2, self.y2 = int(self.bx // self.gs.resx)+1, int(self.by // self.gs.resy)+1

        # From upperright to lower left x values become negative
        # Subdivide the line into sampling points of the raster.
        # Takes longest dimension and uses number of cells * sampling as the
        # number of subdivisions.
        # Grid of subdivions is pixel grid - 0.5 
        self.subdiv = int(max(self.gs.width, self.gs.height)) * self.sampling
        self.xlist = np.linspace((self.ax/self.gs.resx)-min(self.x1,self.x2)-0.5, (self.bx/self.gs.resx)-min(self.x1,self.x2)-0.5, num=self.subdiv)
        self.ylist = np.linspace((self.ay/self.gs.resy)-min(self.y1,self.y2)-0.5, (self.by/self.gs.resy)-min(self.y1,self.y2)-0.5, num=self.subdiv)
        
    def intersect(self):
        """Returns values of line intersection on downlaoded geotiff from wcs."""
        self.fn = self.gs.getw() # filename of just downloaded geotiff
        gdal.UseExceptions()
        try:
            self.raster = gdal.Open(self.fn)
        except:
            logging.error("Raster probably empty, check what you intersect!")
        # Gets raster and flips it to positive dimensions so 0,0 is lower left.
        self.ra = np.array(self.raster.GetRasterBand(1).ReadAsArray())[::-1]
        # Scipy needs transposed array, weird.
        self.coords = np.array(zip(self.ylist,self.xlist)).T
        # See http://docs.scipy.org/doc/scipy/reference/generated/scipy.ndimage.interpolation.map_coordinates.html
        # Order is order of spline interpolation, between 0-5
        # Mode is what happens if cell is requested outside of raster.
        self.values = spi.map_coordinates(self.ra, self.coords, order=3, mode='nearest')
        
        # Fill nodata values.
        nodata = self.raster.GetRasterBand(1).GetNoDataValue()
        self.values = np.where(self.values == nodata, None, self.values)
        return self.values

    def plot(self):
        """Plots values, x as distance, y as values. Only local, not in wps."""
        if len(self.values) > 0:
            self.distances = map(float, np.linspace(0,len(self.values),len(self.values)) * (self.length / len(self.values)))
            self.profile_data = [list(a) for a in zip(self.distances, self.values)]
            plt.plot(self.distances, self.values)
            
    def json(self):
        """Returns JSON with world x,y coordinates and values."""
        self.xco = np.linspace(self.ax+self.gs.lx,self.bx+self.gs.hx,len(self.values))
        self.yco = np.linspace(self.ay+self.gs.ly,self.by+self.gs.hy,len(self.values))
        # note that this is not a real representation at ALL, just for testing.
        self.distances = map(float, np.linspace(0,len(self.values),len(self.values)) * (self.length / len(self.values)))
        return json.dumps(zip(self.distances,self.values))
        #return json.dumps(zip(self.xco,self.yco,avalues))

def vegdict():
    dctveg = {}
    dctveg[11]=["Post-flooding or irrigated croplands",'vegetated']
    dctveg[14]=["Rainfed croplands",'vegetated']
    dctveg[20]=["Mosaic cropland (50-70%) / Vegetation (grassland, shrubland, forest) (20-50%)",'vegetated']
    dctveg[30]=["Mosaic Vegetation (grassland, shrubland, forest) (50-70%) / Cropland (20-50%)",'vegetated']
    dctveg[40]=["Closed to open (>15%) broadleaved evergreen and/or semi decidous forest (>5m)",'vegetated']
    dctveg[50]=["Closed (> 40%) broadleaved decidous forest (>5m)",'vegetated']
    dctveg[60]=["Open (15 - 40%) broadleaved decidous forest (>5m)",'vegetated']
    dctveg[70]=["Close (> 40%) needleleaved evergreen forest (>5m)",'vegetated']
    dctveg[90]=["Open (15 - 40%) needleleaved evergreen forest (>5m)",'vegetated']
    dctveg[100]=["Closed to open (>15%) mixed broadleaved and needleleaved forest (>5)",'vegetated']
    dctveg[110]=["Mosaic Forest/Shrubland (50-70%) / Grassland (20-50%)",'vegetated']
    dctveg[120]=["Mosaic Grassland (50-70%)/Forest/Shrubland (20-50%)",'vegetated']
    dctveg[130]=["Closed to open (>15%) shrubland (<5m)",'vegetated']
    dctveg[140]=["Closed to open (>15%) grassland",'vegetated']
    dctveg[150]=["Sparse (>15%) vegetation (woody vegetation, shrubs, grassland)",'vegetated']
    dctveg[160]=["Closed (>40%) broadleaved forest regularly flooded - Fresh water",'vegetated']
    dctveg[170]=["Closed (>40%) broadleaved semi-deciduous and/or evergreen forest regularly flooded - Saline water",'vegetated']
    dctveg[180]=["Close to open (>15%) vegetation (grassland, shrubland, woody vegetation) on regularly flooded or waterlogged soil - Fresh, brackish or saline water",'intermittent marsh']
    dctveg[190]=["Artificial surfaces and associated areas (urban areas > 50%)",'urban']
    dctveg[191]=["Other urban areas (??)",'urban']
    dctveg[200]=["Bare areas",'urban']
    dctveg[210]=["Water bodies",'water']
    dctveg[213]=["Inland waterbodies (??)",'water']
    dctveg[214]=["Other waterbodies (??)",'water']
    dctveg[220]=["Permanent snow and ice",'ice']
    dctveg[230]=["No data (burn ares, c○louds, ...",'no data']
    
    return dctveg

def main(wktline,acrs):
    cf = r'C:\pywps\pywps_processes\pgconnection.txt'
    credentials = sqlfunctions.get_credentials(cf)    

    dctlayers = {}
    dctlayers['ecology."wcmc-010-mangroveusgs2011-ver1-3"']= ['geom','grid_code','polygon','flora_fauna']
    dctlayers['ecology.coral_reefs']= ['geom','presence','polygon','corals']
    dctlayers['geology.glim_v01_export']= ['geom','xx','polygon','geological_layout']
    dctlayers['sediment.accretion'] = ['geom','status','polygon','sediment']
    dctlayers['coast.estuaries'] = ['geom','label','polygon','estuaries']
    dctlayers['risk.roads'] = ['geom','length','line','roads']
    dctlayers['coast.diva_points_with_cyclone_risk'] = ['geom','bcyclone','point','storm_climate']
    dctlayers['coast.wave_exposure'] = ['geom','ts_exposure','point','wave_exposure']
    dctlayers['coast.tidal_range'] = ['geom','exposure','point','tidal_range']
    dctlayers['coast.surge_levels_diva'] = ['geom','rp00100','point','surge_levels']
    dctlayers['coast.global_rivermouths'] = ['geom','river_name','point','rivermouths']
    dctlayers['risk.colombia_gar_coastal'] = ['geom', 'tot_val, tot_pob','point','risk']

    astr = []
    dctwcs = {}
    io_veg = StringIO() 
    io_elev = StringIO()
    io_geol = StringIO()
    io_surge = StringIO() 
    io_coralreef = StringIO() 
    io_wave = StringIO() 
    io_mangrove = StringIO() 
    io_cyclone = StringIO() 
    io_tidal = StringIO() 
    
    dctwcs['Global_Base_Maps:SRTM30_GEBCO'] = ['http://fast.openearth.eu/geoserver/Global_Maps/ows?','slope']
    dctwcs['global:Globcover2009 V2.3'] = ['http://deltaresdata.openearth.nl/geoserver/global/wcs?','landcover']
        
    #vegdct = vegdict()
    for raster in dctwcs.keys():    
        # first get the data for eacht raster over de WKTLINE, this is l. The resulting array with data derived for l is r (r = l.intersect())
        l = LS(wktline,acrs,dctwcs[raster][0],raster)
        l.line()
        
        r = l.intersect()
       #logging.info(raster, [result for result in r])
        #astr = '#'.join([layer,','.join(map(str, r))])
        # what to do here, via min/max
        # right now, most common of first 5 not being water
        if raster == 'global:Globcover2009 V2.3' or raster == 'vegetation:landcover':
            v = r[np.where(r!=210)]
#            json.dump(','.join(map(str, v)),io_veg)
            logging.info('#'.join(['veg',','.join(map(str, v))]))
            veglist = []
            if len(v) > 0:
                for veg in v: #Checks and re-assigns vegetation classes coming from the linesect
                    if veg < 160:
                        veglist.append('Vegetated')
                    elif veg >= 160 and veg < 170:
                        veglist.append('Mangrove')
                    elif veg >= 170 and veg < 190:
                        veglist.append('Marsh/tidal flat')
                    elif veg >= 190:
                        veglist.append('Not vegetated')
                        
                    vegs = (veg for veg in veglist)
                    json.dump(','.join(map(str, vegs)),io_veg)
            else:
                vegtype = 'Not vegetated'
                json.dump(vegtype,io_veg)
            
        else:
            astr.append([raster,','.join(map(str, r))])

        if raster == 'topography:topography' or raster == 'Global:srtm30' or raster == 'Global_Maps:SRTM30' or raster == 'Global_Base_Maps:SRTM30_GEBCO':
            json.dump(','.join(map(str, r)),io_elev)

#            anf.write('#'.join([raster,str(slope[0])])+'\r\n')
    for layer in dctlayers.keys():
        logging.info('='.join(['layer',layer]))
        ftype = dctlayers[layer][2]
        if ftype == 'polygon':
            if layer == 'geology.glim_v01_export':
                strSql = """select category from {t} 
                         join public.lut_lithology on litcode = {lut}
                         where st_intersects ({fld},ST_LineFromText('{line}',4326))
                         """.format(t=layer,fld=dctlayers[layer][0], line=wktline ,lut = dctlayers[layer][1])
            else:
                #strSql = "select %s from %s where st_intersects (%s,st_makeenvelope(%f,%f, %f,%f,4326))" % (dctlayers[layer][1],layer,dctlayers[layer][0],abbox[0], abbox[1], abbox[2], abbox[3])
                strSql = """select %s from %s where st_intersects (%s,ST_LineFromText('%s',4326))""" % (dctlayers[layer][1],layer,dctlayers[layer][0],wktline)
        elif ftype == 'point':
            strSql = """select {fld} 
                        from {tbl} 
                        order by st_distance({geom},ST_LineFromText('{line}',4326)) limit 1""".format(fld=dctlayers[layer][1],tbl = layer, geom = dctlayers[layer][0], line = wktline)
        try: #corals are defined first and immediately upon return as it previously collided on the surge levels definition
            a = sqlfunctions.executesqlfetch(strSql,credentials)           
            if layer == 'geology.glim_v01_export':
                logging.info(' '.join(['io_geol ',str(a)]))
                json.dump(','.join(map(str, a)),io_geol)
            if layer == 'coast.surge_levels_diva':
                logging.info(' '.join(['io_surg ',str(a)]))
                json.dump(','.join(map(str, a)),io_surge)
            if layer == 'ecology.coral_reefs':
                logging.info(' '.join(['io_coralreef ',str(a)]))
                json.dump(','.join(map(str, a)),io_coralreef)
            if layer == 'coast.wave_exposure':
                logging.info(' '.join(['io_wave ',str(a)]))
                json.dump(','.join(map(str, a)),io_wave)
            if layer == 'ecology."wcmc-010-mangroveusgs2011-ver1-3"':
                logging.info(' '.join(['io_mangrove ',str(a)]))
                json.dump(','.join(map(str, a)),io_mangrove)
            if layer == 'coast.diva_points_with_cyclone_risk':
                logging.info(' '.join(['io_cyclone ',str(a)]))
                json.dump(','.join(map(str, a)),io_cyclone)
            if layer == 'coast.tidal_range':
                logging.info(' '.join(['io_tidal ',str(a)]))
                json.dump(','.join(map(str, a)),io_tidal)
        except:
            pass

    return io_veg,io_elev,io_geol,io_surge,io_coralreef,io_wave,io_mangrove,io_cyclone,io_tidal
