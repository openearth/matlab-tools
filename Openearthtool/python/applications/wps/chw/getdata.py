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
from math import atan2, degrees
from collections import Counter

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
            logging.info(' '.join(['retrieving data from',layer,'from',host]))
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

def difheight(l,r):
    #This difheight is necessary for determining slope, this is done only on land, so only values > 0 (MSL) are used
    #r = np.random.randint(10, size=50) #Range of random numbers, max size of array
    Cellcount = r.size
    transect_length = l.length #drawn transect length
    length_of_one_cell = transect_length/Cellcount
    
    logging.info(': '.join(['The following heights have been found',str(r)]))
    
    try:
        firstZero = np.where(r>=0)[0][0]
        if firstZero == []: #Checks whether any value exists or not in the first place
            raise ValueError()
        remaining_cells_after_zero = r.size - firstZero
        total_length_after_zero = remaining_cells_after_zero * length_of_one_cell
    # it sounds logical to have a zero as first item in the array, above we find the first 
    # a bit of a problem is at the moment that the cellsize is > 500 m
    # for now we choose 3 cells
        if total_length_after_zero >= 500:
            values_greater_than_zero = r[firstZero:(firstZero+2)] #At 30m resolution, 15 cells is approx 30m (33m)
            index_of_500m_mark = int(500/length_of_one_cell)
            difheight = np.mean(values_greater_than_zero)
            length_x = (len(r)-firstZero) * length_of_one_cell
            length_x = index_of_500m_mark * length_of_one_cell
        elif total_length_after_zero < 500:
            values_greater_than_zero = r[firstZero:]
            #print("Length is less than 500m")
            index_of_500m_mark = r.size # if the transect is after the 0-marker, is smaller than 500m than the final point in the array is the furthest point is thus used as the height in order to calculate the angle of the triangle. 
            difheight = np.mean(values_greater_than_zero)
            length_x = (len(r)-firstZero) * length_of_one_cell
            length_x = index_of_500m_mark * length_of_one_cell
        rads = atan2(difheight,length_x)
        degs = degrees(rads)
    except: # if no zero value is found, pass
        logging.info ('!!!---Check what you intersect, DTM intersect contains no zeroes. Assumed to not have height difference and slope.---!!!')
        difheight = 0
        degs = 0  


    return (difheight,degs)
    
def main(wktline,acrs,chw):
    # for every layer in the list collect information
    #wktline = 'LINESTRING(-76.296 9.225, -76.128 9.043)'
    #acrs=4326
    chw = False # chw True works on the OpenEarth stack, else it is the local virtual machine
    #logging.info(':'.join(['wktline',wktline]))
    #logging.info(':'.join(['acrs',str(acrs)]))
    
    cf = r'C:\pywps\pywps_processes\pgconnection.txt'
    credentials = sqlfunctions.get_credentials(cf)    

    dctlayers = {}
    if chw:
        dctlayers['topography.contours'] = ['geom','contour','line']
        dctlayers['topography.contours10']= ['geom','contour','line']
        dctlayers['ecology.coral_reefs']= ['geom','gridcode','polygon','corals']
        dctlayers['geology.glim_v01_export']= ['geom','xx','polygon','geological_layout']
    else:
        # the values are, geometry field, code field, feature class, layer name
        dctlayers['ecology."wcmc-010-mangroveusgs2011-ver1-3"']= ['geom','grid_code','polygon','flora_fauna']
        dctlayers['ecology.coral_reefs']= ['geom','presence','polygon','corals']
        dctlayers['geology.glim_v01_export']= ['geom','xx','polygon','geological_layout']
        dctlayers['sediment.accretion'] = ['geom','status','polygon','sediment']
        dctlayers['coast.estuaries'] = ['geom','label','polygon','estuaries']
        dctlayers['risk.roads'] = ['geom','length','line','roads']
        dctlayers['geology.barrier_islands'] = ['geom','name','line','barrier_islands']
        dctlayers['coast.diva_points_with_cyclone_risk'] = ['geom','bcyclone','point','storm_climate']
        dctlayers['coast.wave_exposure'] = ['geom','ts_exposure','point','wave_exposure']
        dctlayers['coast.tidal_range'] = ['geom','exposure','point','tidal_range']
        dctlayers['coast.surge_levels_diva'] = ['geom','rp00100','point','surge_levels']
        dctlayers['coast.global_rivermouths'] = ['geom','river_name','point','rivermouths']
        dctlayers['risk.gar_expanded'] = ['geom', 'tot_val, tot_pob','point','risk']

    dctresults = {}    
    astr = []
    dctwcs = {}
    if not chw:
        dctwcs['Global_Base_Maps:SRTM30_GEBCO'] = ['http://fast.openearth.eu/geoserver/Global_Base_Maps/ows?','slope']
        dctwcs['global:Globcover2009 V2.3'] = ['http://deltaresdata.openearth.nl/geoserver/global/wcs?','landcover']
    else: #Perhaps add or statements to prevent having to change all
        dctwcs['topography:topography'] = ['http://localhost:9090/geoserver/wcs?','slope']
        dctwcs['vegetation:landcover'] = ['http://localhost:9090/geoserver/wcs?','landcover']
        
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
            veglist = []

            for veg in v: #Checks and re-assigns vegetation classes coming from the linesect
                if veg < 160:
                    veglist.append('Vegetated')
                elif veg >= 160 and veg < 170:
                    veglist.append('Mangrove')
                elif veg >= 170 and veg < 190:
                    veglist.append('Marsh/tidal flat')
                elif veg >= 190:
                    veglist.append('Not vegetated')
                    
            #Using the count function, finds the most commonly occurring class along the linesect        
            try:
                #np.unique(vgs[:5], return_inverse=False)<-- Was, now replaced with standard Python functions
                vegs = (veg for veg in veglist)
                vegcount = Counter(vegs)
                vegcount = vegcount.most_common()
                logging.info(vegcount)
                #This block loops over the most common class until it 
                for i in range(0,(len(vegcount))):
                    logging.info(vegcount[0-i][0])
                    if 'vegetated' not in vegcount[0-i][0]:
                        vegtype = vegcount[0-i][0]
                if not vegtype:
                    vegtype = vegcount.most_common(1)[-0]
                    logging.info[vegtype]
                dctresults[dctwcs[raster][1]] = vegtype
                logging.info(': '.join(['Dominant vegetation type of MODIS dataset',vegtype]))
                vegcheck =  False #variable referenced after CHW SQL function as vegtype must be one of the classes. This displays it correctly in the viewer.
            except:
                logging.info('!!!---No vegetation types found in the dataset, assuming that the area is not vegetated---!!!')
                vegcheck = True
                vegtype = 'Not vegetated'
                dctresults[dctwcs[raster][1]] = vegtype
            #anf.write('#'.join([layer,','.join(map(str, vgs))])+'\r\n')
#            anf.write('#'.join([raster,vegtype])+'\r\n')
            #astr.append([raster,vegtype])
        else:
#            anf.write('#'.join([raster,','.join(map(str, r))])+'\r\n')
            astr.append([raster,','.join(map(str, r))])
        if raster == 'topography:topography' or raster == 'Global_Base_Maps:SRTM30' or raster == 'Global_Base_Maps:SRTM30_GEBCO':
            slope = difheight(l,r)
            dctresults[dctwcs[raster][1]] = "{0:.1f}".format(slope[1])
#            anf.write('#'.join([raster,str(slope[0])])+'\r\n')
    for layer in dctlayers.keys():
        ftype = dctlayers[layer][2]
        if ftype == 'polygon':
            if layer == 'geology.glim_v01_export':
                if slope[1] <= 1.6:
                    op = 'lt'
                else:
                    op = 'ge'
                strSql = """select category from {t} 
                         join public.lut_lithology on litcode = {lut}
                         where st_intersects ({fld},ST_LineFromText('{line}',4326))
                         and operator = '{o}'""".format(t=layer,fld=dctlayers[layer][0], line=wktline ,lut = dctlayers[layer][1], o=op)
            else:
                #strSql = "select %s from %s where st_intersects (%s,st_makeenvelope(%f,%f, %f,%f,4326))" % (dctlayers[layer][1],layer,dctlayers[layer][0],abbox[0], abbox[1], abbox[2], abbox[3])
                strSql = """select %s from %s where st_intersects (%s,ST_LineFromText('%s',4326))""" % (dctlayers[layer][1],layer,dctlayers[layer][0],wktline)
        elif ftype == 'line':
            if layer == 'risk.roads':
                strSql = """
                    select Sum(ST_Length(ST_Intersection(ST_Transform(rds.{geom},3857),ST_Buffer(ST_Transform(ST_LineFromText('{line}',4326), 3857),100))))
                    from {tbl} As rds
                    where type = 'primary' or type = 'secondary' or type = 'trunk'
                    """.format(tbl = layer, geom = dctlayers[layer][0], line = wktline)
            elif layer == 'risk.roads':
                strSql = """
                    select Sum(ST_Length(ST_Intersection(ST_Transform(rds.{geom},3857),ST_Buffer(ST_Transform(ST_LineFromText('{line}',4326), 3857),100))))
                    from {tbl} As rds
                    where type = 'primary' or type = 'secondary' or type = 'trunk'
                    """.format(tbl = layer, geom = dctlayers[layer][0], line = wktline)
            else:
                strSql = """select %s from %s where st_intersects (%s,ST_LineFromText('%s',4326))""" % (dctlayers[layer][1],layer,dctlayers[layer][0],wktline)
        elif ftype == 'point':
            if layer == 'coast.global_rivermouths':
                strSql = """select {fld}
                            from {tbl}
                            where ST_Dwithin(ST_Transform({geom}, 3857), ST_Transform(ST_LineFromText('{line}',4326), 3857), length*5) and length != -9999""".format(fld = dctlayers[layer][1], tbl = layer, geom = dctlayers[layer][0], line = wktline)
                            #where st_dwithin(st_transform({fg} ,3857),st_transform(ST_LineFromText('{l}',4326) ,3857) ,10000)
                            #;""".format(fld=dctlayers[layer][1],tbl = layer,fg = dctlayers[layer][0],l=wktline)
            #order by st_distance{fg},ST_EndPoint(ST_lineFromText('{l}',4326)) limit 1
            elif layer == 'risk.colombia_gar_coastal': #selects population, capital stock and distance from drawn line to nearest point
                strSql = """select {flds}, ST_Distance(ST_Transform(geom,3857),ST_Transform(ST_LineFromText('{line}',4326),3857))
                            from {tbl}
                            where ST_Dwithin(ST_Transform({geom},3857), ST_Line_Interpolate_Point(ST_Transform(ST_LineFromText('{line}',4326),3857),0.5),5000)
                            order by st_distance({geom},ST_LineFromText('{line}',4326)) limit 1""".format(flds=dctlayers[layer][1],tbl = layer, geom = dctlayers[layer][0], line = wktline)
            else:
                strSql = """select {fld} 
                            from {tbl} 
                            order by st_distance({geom},ST_LineFromText('{line}',4326)) limit 1""".format(fld=dctlayers[layer][1],tbl = layer, geom = dctlayers[layer][0], line = wktline)
        try: #corals are defined first and immediately upon return as it previously collided on the surge levels definition
            a = sqlfunctions.executesqlfetch(strSql,credentials)           
#           #logging.info(layer, [result for result in a])
            #astr.append([layer,','.join(map(str, a))])
#            anf.write('#'.join([layer,','.join(map(str, a))])+'\r\n')
            # if layer is sea_levels, then the result is number, this will be converted to string
            if dctlayers[layer][3] == 'surge_levels':
                if len(a) <1:
                    dctresults[dctlayers[layer][3]]='no data'
                else:
                    dctresults[dctlayers[layer][3]]=str(a[0][0])
                    if dctlayers[layer][3] == 'flora_fauna':
                        dctresults['flora_fauna'] = 'mangrove'
            elif dctlayers[layer][3] == 'risk':
                dctresults['risk'] = a         
            else:
                if len(a) <1:
                    dctresults[dctlayers[layer][3]]='no data'
                else:
                    dctresults[dctlayers[layer][3]]=a[0][0]
        except:
#            anf.write(' '.join(['something went wrong with layer',layer])+'\r\n')
            pass
    #logging.info(''.join(['lengte lst ',str(len(lst))]))
    
#    anf.close()

    """
    final hazard can be retrieved from table lut_chwcodes, first we check if some exceptions occur and whether overrides need to happen
    These strings are fed into the lut dictionary and used in the SQL query
    Since many exceptions to common class assignment are present in the wheel a long list of exceptions are necessary in addition to the LUT.
    Class assignment begins from the innermost to the outermost circle. Check the wheel and the text I've written here and it should hopefully become clear.
    """

    '''##Geological layout##'''
    if dctresults['corals'] != 'no data' and dctresults['geological_layout'] == 'no data':
        geostr = "lower(geological_layout) = lower('coral island')"
        dctresults['geological_layout'] = 'Coral island'
    elif dctresults['barrier_islands'] != 'no data':
        geostr = "lower(geological_layout) = lower('Barrier')"
        dctresults['geological_layout'] = 'Barrier island'        
    elif dctresults['estuaries'] != 'no data':
        geostr = "lower(geological_layout) = lower('Delta/low estuarine island')"
        dctresults['geological_layout'] = 'Delta/low estuarine island'
    else:
        geostr = "lower(geological_layout) = lower('{}')".format(dctresults["geological_layout"])
    
    '''#Wave exposure##'''
    if dctresults['geological_layout'] == 'Sloping hard rock':
        wavestr = "lower(wave_exposure) = lower('any')"
    else:
        wavestr = "lower(wave_exposure) = lower('{}')".format(dctresults['wave_exposure'])
        

    '''##Tidal climate##'''
    if dctresults['tidal_range'] == 'meso' or dctresults['tidal_range'] == 'macro':
        tidalstr = "lower(tidal_range) = lower('Meso/macro')"
    elif dctresults['geological_layout'] == 'Sloping hard rock':
        tidalstr = "lower(tidal_range) = lower('any')"  
    else:
        tidalstr = "lower(tidal_range) = lower('{}')".format(dctresults["tidal_range"])

    '''##Vegetation##'''
    #Vegetation contains the most exceptions to the standard classes, hence the long list of exceptions.
    #Beginning here, flora & fauna contains information on the presence of mangroves. After this block, it is reclassified to contain the vegetation class corresponding with the conditions & data
    if dctresults['flora_fauna'] != 'no data' or dctresults['landcover'] == 'Mangrove':
        if dctresults['tidal_range'] == 'micro':
            flofaustr = "lower(flora_fauna) = lower('intermittent mangrove')"
            dctresults['flora_fauna'] = 'Intermittent mangrove'
        else:
            dctresults['flora_fauna'] = 'Mangrove'
            flofaustr = "lower(flora_fauna) = lower('Mangrove')"
    elif dctresults['landcover'] == 'Marsh/tidal flat' and dctresults['tidal_range'] == 'micro':
        flofaustr = "lower(flora_fauna) = lower('intermittent marsh')"
        dctresults['flora_fauna'] = 'Intermittent marsh'
    elif dctresults['landcover'] != '':
        flofaustr = "lower(flora_fauna) = lower('{}')".format(dctresults["landcover"])
        dctresults['flora_fauna'] = dctresults['landcover']
    else:
        flofaustr = "lower(flora_fauna) = lower('{}')".format(vegtype)
    if dctresults['geological_layout'] == 'Sloping hard rock' or dctresults['geological_layout'] == 'Flat hard rock':
        if dctresults['corals'] != 'no data': #Handles corals that are present in Flat & sloping hard rock coasts
            flofaustr = "lower(flora_fauna) = lower('corals')"
            dctresults['flora_fauna'] = 'Corals'
        else:
            flofaustr = "lower(flora_fauna) = lower('any')"
            #print 'any'
    #This block overrides the protected wave class if mangroves or marshes are not found, as the wheel states that it's not possible
    #To have any other type of vegetation in such a case.
      
    '''##Sediment balance##'''
    if dctresults['sediment'] != 'no data':
        sedstr = "lower(sediment_balance) = lower('surplus')"
    else:
        sedstr = "lower(sediment_balance) = lower('balance/deficit')"
        dctresults['sediment'] = 'Balance/deficit'

    #EXCEPTIONS TO SEDIMENT BECAUSE OF GEOLOGICAL LAYOUT - add beaches when they become available
    if dctresults['geological_layout'] == 'Flat hard rock': #takes care of the 'any' value.
        if dctresults['wave_exposure'] == 'Protected':
            sedstr = "lower(sediment_balance) like '%%'"
        else:
            sedstr = "lower(sediment_balance) = lower('No beach')"
    elif dctresults['geological_layout'] == 'Sloping hard rock':
        sedstr = "lower(sediment_balance) = lower('No beach')"
        
   
    '''##Sediment balance##'''
   #Storm climate exceptions
    if dctresults['geological_layout'] == 'Sloping hard rock':
       dctresults['storm_climate'] = 'any'
       stormstr = "lower(storm_climate) = lower('any')"
    else:
       stormstr = "lower(storm_climate) = lower('{}')".format(dctresults["storm_climate"])
    
    '''Missing classes: Beach/nobeach, coral islands------------------------------------------------------------------------------------------------'''

    #This dict contains the variables for the LUT, the previous way this was written didn't work
    lutdict ={
    'gl':geostr,
    'we':wavestr,
    'tr':tidalstr,
    'ff':flofaustr,
    'sb':sedstr,
    'sc':stormstr
    }

    #First, this block checks whether the readily assigned value can be used or whether 'any' should be used.
    strSql = """select code,erosion
            from lut_chwcodes
            where {lookup[gl]}
            and {lookup[we]}
            and {lookup[tr]}
            ;""".format(lookup=lutdict)          
    tidalclass = sqlfunctions.executesqlfetch(strSql,credentials)

    if tidalclass == []:    
        tidalstr = "lower(tidal_range) = lower('any')"
        lutdict['tr'] = tidalstr
    
    #This next block of code manually accounts for the classes 'FR-19' and 'FR-20' as they use marsh/mangrove
    if dctresults['geological_layout'] == 'Flat hard rock':
        if dctresults['wave_exposure'] == 'Protected':
            if tidalclass == []: #Uses the previously defined check to find the 'any' tidal range
                if dctresults['flora_fauna'] == 'Mangrove' or dctresults['landcover'] == 'Marsh/tidal flat':
                    flofaustr = "lower(flora_fauna) = lower('Marsh/mangrove')"
                    lutdict['ff'] = flofaustr
                else:
                    dctresults['flora_fauna'] == 'Not vegetated'
                    flofaustr = flofaustr = "lower(flora_fauna) = lower('Not vegetated')"
                    lutdict['ff'] = flofaustr
    '''
    It was chosen specifically not to do it in one SQL string, as it would obscure what's going on. So here's the rundown:
    Foremost, it checks whether all values correspond to the assigned strings. If that's not the case, it checks for variations
    on the coastal environments.
    It first checks whether the RETURNED class is not vegetated. If that's not the case, it checks any.
    Afterwards, in the second if statement, it checks the returned class for vegetated and any afterwards.
    '''
    #Before anything else, it checks if a rivermouth has been found. If that's the case, it automatically assigns 'TSR' and negates the other statements 
    if dctresults['rivermouths'] != 'no data':  
        strSql = """select code,erosion
        from lut_chwcodes
        where code = 'TSR'"""
        result = sqlfunctions.executesqlfetch(strSql,credentials)  
        if result != []:
            dctresults['coastenv']= result[0][0]
            dctresults['erosion']= result[0][1]
            dctresults['geological_layout'] = 'Rivermouth'
        else:
            dctresults['notif'] = 'TSR not found in table, check the lookup table'
    else:   
        strSql = """select code,erosion
            from lut_chwcodes
            where {lookup[gl]}
            and {lookup[we]}
            and {lookup[tr]}
            and {lookup[ff]}
            and {lookup[sb]}
            and {lookup[sc]}
            ;""".format(lookup=lutdict) 
        result = sqlfunctions.executesqlfetch(strSql,credentials)  
        if result != []:
            dctresults['coastenv']= result[0][0]
            dctresults['erosion']= result[0][1]
    
        elif dctresults['flora_fauna'] == 'Not vegetated':
            strSql = """select code,erosion
                from lut_chwcodes
                where {lookup[gl]}
                and {lookup[we]}
                and {lookup[tr]}
                and lower(flora_fauna) = lower('not vegetated')
                and {lookup[sb]}
                and {lookup[sc]}
                ;""".format(lookup=lutdict)
            result = sqlfunctions.executesqlfetch(strSql,credentials)  
            if result != []:
                dctresults['coastenv']= result[0][0]
                dctresults['erosion']= result[0][1]
            else:
                strSql = """select code,erosion
                from lut_chwcodes
                where {lookup[gl]}
                and {lookup[we]}
                and {lookup[tr]}
                and lower(flora_fauna) = lower('any')
                and {lookup[sb]}
                and {lookup[sc]}
                ;""".format(lookup=lutdict)
            result = sqlfunctions.executesqlfetch(strSql,credentials)  
        elif dctresults['flora_fauna'] != 'Not vegetated': #Checks if it is supposed to be 'vegetated' where the class is currently any vegetation type other than not vegetated
            strSql = """select code,erosion
                from lut_chwcodes
                where {lookup[gl]}
                and {lookup[we]}
                and {lookup[tr]}
                and lower(flora_fauna) = lower('vegetated')
                and {lookup[sb]}
                and {lookup[sc]}
                ;""".format(lookup=lutdict)
            result = sqlfunctions.executesqlfetch(strSql,credentials)  
            if result != []:
                dctresults['coastenv']= result[0][0]
                dctresults['erosion']= result[0][1]
            else: #check for 'any' after 'vegetated' did not suit the condition
                strSql = """select code,erosion
                    from lut_chwcodes
                    where {lookup[gl]}
                    and {lookup[we]}
                    and {lookup[tr]}
                    and lower(flora_fauna) = lower('any')
                    and {lookup[sb]}
                    and {lookup[sc]}
                    ;""".format(lookup=lutdict)
                result = sqlfunctions.executesqlfetch(strSql,credentials)
                # in some occastions, for instance in the bay of Turbo (Colombia, atlantic coast near Panama)
                # flara_fauna = 'any' does not occur in LUT. Perhaps ommision in the LUT.
                if result == []:
                    strSql = """select code,erosion
                    from lut_chwcodes
                    where {lookup[gl]}
                    and {lookup[we]}
                    and {lookup[tr]}
                    --and lower(flora_fauna) = lower('any')
                    and {lookup[sb]}
                    and {lookup[sc]}
                    ;""".format(lookup=lutdict)
                result = sqlfunctions.executesqlfetch(strSql,credentials)
                    
        if result != []:
            dctresults['coastenv']= result[0][0]
            dctresults['erosion']= result[0][1]
            if vegcheck == True:
                dctresults['flora_fauna'] = 'No vegetation (no data found)' #Displays 'no data' on the viewer if the result is assumed to be no vegetation upon finding no data.
        #If no result can be calculated it stores an error and returns all empty fields except for the coastal environment and erosion             
        elif dctresults['geological_layout'] != 'no data':
            dctresults['coastenv']= 'Result does not match any CHW classes'
            dctresults['erosion']= 'No result'
        #If there is simply no geology data it returns a no-data all across
        else:
            dctresults['coastenv']= 'No geology data is available'
            dctresults['erosion']= 'No results'
            
    logging.info('Result of the query:{}'.format(strSql))
    logging.info(': '.join(['Possible coastal environments & erosion hazard', str(result)]))           
    '''formatting of returned results'''
    #Hazard processing - adjusts the integer of the hazard to a more readable format
    #This was implemented in a rush, can probably be written more elegantly but there's no time for now
    try:
        if dctresults['erosion'] == 1:
            dctresults['erosion'] = "1 (low)"
        elif dctresults['erosion'] == 2:
            dctresults['erosion'] = "2 (moderate)"
        elif dctresults['erosion'] == 3:
            dctresults['erosion'] = "3 (high)"
        elif dctresults['erosion'] == 4:
            dctresults['erosion'] = "4 (very high)"
    except:
        dctresults['erosion'] = 'no data'
    #Measurement processing added on 20160905▀
    try:  
        strSql = """select * from public.lut_measures
                    where code = '{}'""".format(dctresults['coastenv'])
        values = sqlfunctions.executesqlfetch(strSql,credentials)
        values = values[0]
        #logging.info(strSql)
        measures = ['code',
                    'breakwaters',
                    'groynes',
                    'jetties',
                    'revetments',
                    'seawalls',
                    'dikes',
                    'stormsurgebarriers',
                    'beachnourishment',
                    'duneconstab',
                    'cliffstab',
                    'wetlandrest',
                    'floodwarning',
                    'floodproofing',
                    'coastalzoning',
                    'groundwatermgmt',
                    'fluvsedmgmt',
                    'riskindication',]
        #logging.info('measures',measures)        
        logging.info('measure values',values)
        dctmeasures = dict(zip(measures, values))
        #logging.info('measure dict',dctmeasures)
    except:
        logging.info("Failed to process measures")

    #Risk processing - returns all values in a visibly pleasant format 
    try:
        dctresults['capital_stock'] = int(dctresults['risk'][0][0]*1000000)
        dctresults['capital_stock'] = "{:,}".format(dctresults['capital_stock'])
        dctresults['capital_stock'] = str(dctresults['capital_stock']).replace(",",".")
        dctresults['capital_stock'] = "Usd. {},-".format(dctresults['capital_stock'])
    except:
        dctresults['capital_stock'] = "no data"
    try:
        dctresults['population'] = int(dctresults['risk'][0][1])
        dctresults['population'] = "{:,}".format(dctresults['population'])
        dctresults['population'] = str(dctresults['population']).replace(",",".") 
        dctresults['population'] = '{} inhabitants'.format(dctresults['population'])
    except:
        dctresults['population'] = "no data"
    try:
        dctresults['gar_distance'] = int(dctresults['risk'][0][2])
        dctresults['gar_distance'] = "{:,}".format(dctresults['gar_distance'])    
        dctresults['gar_distance'] = str(dctresults['gar_distance']).replace(",",".")        
        dctresults['gar_distance'] = "{} meters".format(dctresults['gar_distance'])
    except:
        dctresults['gar_distance'] = "no data"        
        
    try:
        dctresults['roads'] = int(dctresults['roads'])
        dctresults['roads'] = "{:,}".format(dctresults['roads'])
        dctresults['roads'] = str(dctresults['roads']).replace(",",".")  
        dctresults['roads'] = '{} meters'.format(dctresults['roads'])
    except:
        dctresults['roads'] = '0 meters'
    # Classify capital stock -- added on 20160905♥
    try:
        #if dctresults['risk'] != 
        tot_capstock = int(dctresults['risk'][0][0]*1000000)
        if  tot_capstock >= 100000000 and tot_capstock <= 1000000000:
            dctmeasures['riskindication'] = 'Medium'
        elif tot_capstock >= 1000000000:
            dctmeasures['riskindication'] = 'High'
        else:
            dctmeasures['riskindication'] = 'Low'      
    except:
        dctmeasures['riskindication'] = 'nodata'
    logging.info('dctmeasures',dctmeasures)
    
    #Merging dictionaries to send them in one go
    dctresults = dict(dctresults.items() + dctmeasures.items())
    
    """ io2 contains all values for environments description of the table """
    io2 = StringIO() 
    json.dump(dctresults,io2)
    logging.info(type(io2.getvalue()))
    
    """io contains all values for the graph"""
    io = StringIO() 
    json.dump(astr, io)
    logging.info(str(astr))
    logging.info(type(io.getvalue()))
    
    return (io, io2)