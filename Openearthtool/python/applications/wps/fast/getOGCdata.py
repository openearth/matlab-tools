# -*- coding: utf-8 -*-
"""
Created on Wed Jun 15 07:44:57 2016
 
@author: oet
"""

# -*- coding: utf-8 -*-
"""
Created on Wed Nov 18 14:01:45 2015

@authors:
WCS/Linesect: Maarten Pronk (maarten.pronk@deltares.nl)
WPS integration: Gerrit Hendriksen (gerrit.hendriksen@deltares.nl)
WPS integration: Joan Sala Calero (joan.salacalero@deltares.nl)
"""

# STANDARD MODULES
import types
import json
from StringIO import StringIO
from os import path
from random import choice
import string
import re
import logging
import struct
import time
import fnmatch

# NON STANDARD MODULES
from scipy.stats import linregress
from osgeo import gdal,ogr
from pyproj import Proj, transform
import owslib.wcs as ogcwcs

from owslib.wcs import WebCoverageService
from owslib.wms import WebMapService
import sqlfunctions
import pyproj
import json
import numpy as np
import scipy.ndimage as spi
from shapely import wkt
import tempfile
from shapely.geometry import *
import owslib.wfs as ogcwfs
import geojson
import math
import os

# unicode to array function
from fast_plots import *

#from datetime import datetime as dtm

'''
All unused modules, preserved for the sake of documentation
import netCDF4 as netcdf
import subprocess
import shutil
from scipy.interpolate import interp1d
import datetime
'''

DEBUG = False # uncomment to debug

# Default db access
cf = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'pgconnection.txt')

class P:
    """Point gives you shortest perp line to wfs line layer."""
    def __init__(self,c,crs,host,layer,sampling=1):
        if DEBUG: logging.debug('p_init',c)
        self.p = wkt.loads(c) # tuple of coordinates
        
        # closest shore - buffer 0.3 degree around the point
        self.bb = self.p.buffer(0.3).bounds         
        self.wfs = ogcwfs.WebFeatureService(host) # wfs service connected
        self.gf = self.wfs.getfeature(typename=[layer],bbox=self.bb,outputFormat='application/json') # Get closest shore
        self.fc = geojson.loads(self.gf.read())
        self.ld = {}
        if DEBUG: 
            logging.info('*******************************************************')
            logging.info(self.fc)
            logging.info('*******************************************************')

    def reald(self,crs='WGS84'):
        """Returns real distance in meters based on WGS84 input."""
        l = self.l
        geod = pyproj.Geod(ellps='WGS84')#crs
        coords = l.coords[0]+l.coords[1]
        _, _, distance = geod.inv(*coords)
        return np.float64(distance)

    def lines(self):
        """Return dict with lines with the length of the line as keys, based on the nearest point
        on line from given point. Nearest point with given point gives perpendicular line."""
        for f in self.fc['features']:
            s = shape(f['geometry']) # cast to geometry
            ip = s.interpolate(s.project(self.p)) # shapely interpolate -> closest point
            l = LineString([self.p,ip])
            self.ld[l.length] = l
            
    def selext(self):
        """Select shortes line and extends it to 2000m, based on pythagoras abc."""
        self.sl = min(self.ld.keys()) # select shortest linestring
        
        self.l = self.ld[self.sl] # and name it l
        """startpoint is the point on the intersected line (OSM Coastline), this point is starting point"""
        rl = self.reald() # real length in meters
        a = self.l.coords[1][0]-self.l.coords[0][0] # A
        b = self.l.coords[1][1]-self.l.coords[0][1] # B
        
        af = b / a # ratio between b and a, to rewrite pythagoras to a2+(af*a)2
        f = 1000.0/rl # ratio of extension
        ab2 = np.square(f*self.sl)
        temp = ab2 / (1+math.pow(af,2))
        na = math.sqrt(temp) # output is always positive!
        nb = na * af # output is always positive!
        if a < 0: # direction of extension, based on original input
            na = -abs(na)
        else: na = abs(na)
        if b < 0:
            nb = -abs(nb)
        else: nb = abs(nb)
        #ls = LineString([(self.l.coords[0][0], self.l.coords[0][1]), (self.l.coords[0][0]+na,self.l.coords[0][1]+nb)])
        """create line from coordinate on intersection line in both directions"""
        ls = LineString([(self.l.coords[1][0]-na,self.l.coords[1][1]-nb), (self.l.coords[1][0]+na,self.l.coords[1][1]+nb)])
        
        return ls.wkt

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
        #_, self.format, self.identifier = self.layer.keywords
        self.cx, self.cy = map(int,self.layer.grid.highlimits)
        self.crs = self.layer.boundingboxes[0]['nativeSrs']
        self.bbox = self.layer.boundingboxes[0]['bbox']
        self.lx,self.ly,self.hx,self.hy = map(float,self.bbox)
        self.resx, self.resy = (self.hx-self.lx)/self.cx, (self.hy-self.ly)/self.cy
        self.width = self.cx
        self.height = self.cy
        
    def getw(self):
        """Downloads raster and returns filename of written GEOTIFF in the tmp dir."""
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
        if DEBUG: logging.info(fn)
        f = open(fn,'wb')
        f.write(gc.read())        
        f.close()
        return fn

class LS:
    """Intersection on grid line"""
    def __init__(self,awkt,crs,host,layer,sampling=1):
       #if DEBUG: logging.info('LS __init__')
        self.wkt = awkt
        self.crs = crs
        self.gs = WCS(host,layer) # Initiates WCS service to get some parameters about the grid.
        self.sampling = sampling
        logging.info('--------------------------------------------------')
        logging.info(awkt)
        logging.info(crs)
        logging.info(host+layer)
        logging.info(sampling)
        logging.info('--------------------------------------------------')

    def line(self):
        if DEBUG: 
            logging.info('LS line')
            logging.info(self.wkt)
        """Creates WCS parameters and sample coordinates for cells in raster based on line input."""
        self.ls = wkt.loads(self.wkt)
        self.ax, self.ay, self.bx, self.by = self.ls.bounds
        # TODO http://stackoverflow.com/questions/13439357/extract-point-from-raster-in-gdal
        
        """if first x is larger than second, coordinates will be flipped during process of defining bounding box !!!!
           next lines introduce a boolean flip variable used in the last part of this proces"""
        flipx = False
        flipy = False
        ax, bx = self.ls.coords.xy[0]
        ay, by = self.ls.coords.xy[1]
        
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
        if self.crs == 4326:
            geod = pyproj.Geod(ellps='WGS84') # hardcoded, should be changed
            _,_,self.length = geod.inv(self.ax,self.ay,self.bx,self.by) # length in meters
        else:
            # should be 2k or so
            self.length = 2000
        
        # coordinates minus coordinates of raster, start from 0,0
        self.ax = self.ax - self.gs.lx 
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
        self.xlist = np.linspace((self.ax/self.gs.resx)-min(self.x1,self.x2), (self.bx/self.gs.resx)-min(self.x1,self.x2), num=self.subdiv)
        self.ylist = np.linspace((self.ay/self.gs.resy)-min(self.y1,self.y2), (self.by/self.gs.resy)-min(self.y1,self.y2), num=self.subdiv)
        
    def intersect(self):
        """Returns values of line intersection on downlaoded geotiff from wcs."""
        #TODO: this gives y as integer, should be float
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
        self.values = spi.map_coordinates(self.ra, self.coords, order=0, mode='nearest')

        # Fill nodata values.
        nodata = self.raster.GetRasterBand(1).GetNoDataValue()
        self.values = np.where(self.values == nodata, None, self.values)
        return self.values

    def json(self):
        """Returns JSON with world x,y coordinates and values."""
        self.xco = np.linspace(self.ax+self.gs.lx,self.bx+self.gs.hx,len(self.values))
        self.yco = np.linspace(self.ay+self.gs.ly,self.by+self.gs.hy,len(self.values))
        # note that this is not a real representation at ALL, just for testing.
        self.distances = map(float, np.linspace(0,len(self.values),len(self.values)) * (self.length / len(self.values)))
        return json.dumps(zip(self.distances,self.values))
        #return json.dumps(zip(self.xco,self.yco,avalues))

def calcslope(wkt,crs,host,layer):
    """Calculate slope of profile

    For a given slope, calculate the slope (dy/dx)
    between a minimum (maxdepth) and maximum (msl).

    Arguments:
        profile {list} -- [[x,y],[x,y]]

    Keyword Arguments:
        maxdepth {number} -- lowest value for dy (default: {-50})
        msl {number} -- maximum value for dy (default: {5})

    Returns:
        slope {int} -- dy/dx or None
    """
    maxdepth=-50
    msl=0
    profile = find_layer_geoserver(wkt,crs,host,layer)

    # Split profile into x and y
    x = [x[0] for x in profile]
    y = [y[1] for y in profile]
    if DEBUG: logging.debug("y profile min {} y profile max {}".format(min(y),max(y)))
    
    # find out direction of general slope
    if y[0] > y[-1]:  # \ becomes /
        y = y[::-1]
        x = x[::-1]
    else:  # /
        pass

    # find point above maxdepth
    a=0
    for i, height in enumerate(y):
        if height > maxdepth:
            a = i
            break

    # find next point above msl
    b=0
    for i, height in enumerate(y):
        if height >= msl:
            b = i
            break

    if DEBUG: 
        logging.debug("x slope min {} max {}".format(x[a],x[b]))
        logging.debug("y slope min {} max {}".format(y[a],y[b]))

    # absolute difference of profile
    dx = abs(abs(x[a]) - abs(x[b]))
    dy = abs(y[b] - y[a])
    if DEBUG: logging.debug("dy is {}, type = {}".format(dy,type(dy)))
    # slope with min length #commJTD: this will never occur within this if loop
    if float(dy) < 0.0000001:
        if DEBUG: logging.info("dy is zero")
        dy = 0.1
    if DEBUG: logging.debug("dy is {}".format(dy))
    slope = dx / dy
    if DEBUG: logging.info("Slope dx {} / dy {} : {}".format(dx, dy, slope))
    yslopemin=y[a]

    return slope, profile, yslopemin

def misafexpert(wktpoint,crs):
    # DB connect
    cf = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'pgconnection_fast.txt')    
    credentials = sqlfunctions.get_credentials(cf)
    
    # Look for closes transect ()
    sql = """SELECT fastid, ST_Distance(st_pointfromtext('{wkt}','{epsg}'),geom) as distance
            FROM expert_transects
            WHERE ST_Distance(st_pointfromtext('{wkt}','{epsg}'),geom) < {buff}
            ORDER BY distance
            LIMIT 1
            """.format(wkt=wktpoint,epsg=crs, buff=0.01) # 1km approx in degrees
    
    res = sqlfunctions.executesqlfetch(sql, credentials)
    
    # If found call info about transect
    if not(len(res)):
        return False
    # TRANSECT DB info    
    else:
        if DEBUG: logging.info('Result = '+ str(res))
        transectid, iden = res[0]
        if DEBUG: logging.info('Selected transect = '+transectid)        
        return misafexperttransect(transectid, credentials)

def energyLossPer(hs_nearshore, hs_levee):
	# E=(rho*g*H^2)/16, where rho=1024kg/m3, g=9.81 and H=hs_nearshore (incoming energy) and H=hs_levee (resulting energy))	
	rho = 1024.
	g = 9.81
	E_nearshore = math.pow(rho*g*hs_nearshore,2)/16.
	E_levee = math.pow(rho*g*hs_levee,2)/16.

	# x1=100%*(E_nearshore – E_levee_veg)/E_nearshore) 
	return 100.*(E_nearshore-E_levee)/E_nearshore

def expertransectQuery(credentials, transectid, condition, returnperiod):
    sql = """select ST_AsText(geom),id,hs_nearshore,hs_levee_bare,vegtype,rch_q01_bare,rch_q1,rch_q1_bare,vegetation_width,rch_q01,hs_offshore,tpeak,zs0,hs_levee,xaxis,hrms,waterlevel,src_vegpresence,src_bathymetry,src_topography,conf_vegpresence,conf_bathymetry,conf_topography,conf_bcwaves,conf_bcsurge,conf_vegprops,plotx0,plotxend,vegpresence_xbeach,xaxis_xbeach,bedlevel_xbeach
            from public.expert_transects et
            join public.transectresults t on t.transectid = et.id
            where fastid = '{id}'
            and {cond} and returnperiod = {rp}
            """.format(id=transectid, cond=condition, rp=returnperiod)
    return sqlfunctions.executesqlfetch(sql, credentials)

def misafexperttransect(transectid, credentials):
         
    # select values of a given transect (vegetation and no vegetation)
    res = expertransectQuery(credentials, transectid, '(vegtype = 2 or vegtype = 6)', '100')
    res_noveg = expertransectQuery(credentials, transectid, '(vegtype = 0 or vegtype = 4)', '100')
    # No data recieved
    rs = dict()
    if not(len(res)):
        rs['msg'] = 'No data available for selected transect ( '+transectid+')'
        return rs
       
    # Extract values
    lwkt,idt,hs_nearshore,hs_levee_bare,vegtype,rch_q01_bare,rch_q1,rch_q1_bare,vegetation_width,rch_q01,hs_offshore,tpeak,zs0,hs_levee,xaxis,hrms,waterlevel,src_vegpresence,src_bathymetry,src_topography,conf_vegpresence,conf_bathymetry,conf_topography,conf_bcwaves,conf_bcsurge,conf_vegprops,plotx0,plotxend,vegpresence_xbeach,xaxis_xbeach,bedlevel_xbeach = res[0]
    _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,hrms_noveg,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_ = res_noveg[0]

    logging.info('------- TRANSECT ---------')
    logging.info(idt)
    logging.info('--------------------------')

    # Slope    
    forelen=len(unicode_to_array(hrms)[0])    
    linres=linregress(unicode_to_array(xaxis_xbeach)[0][0:forelen], unicode_to_array(bedlevel_xbeach)[0][0:forelen])
    rs['slope'] = "%.1f"%(abs(1.0/linres.slope))  # slope    

    # Energy Loss
    ener_per_veg = "%.1f"%(energyLossPer(hs_nearshore, hs_levee))
    ener_per_noveg = "%.1f"%(energyLossPer(hs_nearshore, hs_levee_bare))

    # Report
    rs['linestr'] = lwkt
    rs['linestr_foreshore'] = lwkt # The same since we zoom to foreshore
    rs['rch_q01'] = rch_q01
    rs['hs_offshore'] = hs_offshore
    rs['tpeak'] = tpeak
    rs['zs0'] = zs0
    rs['hs_levee'] = hs_levee
    rs['hrms'] = hrms
    rs['hrms_noveg'] = hrms_noveg
    rs['waterlevel'] = waterlevel

    # context
    rs['hs_nearshore'] = hs_nearshore
    rs['hs_levee_bare'] = hs_levee_bare
    rs['vegtype'] = vegtype
    rs['rch_q01_bare'] = rch_q01_bare
    rs['rch_q1'] = rch_q1
    rs['rch_q1_bare'] = rch_q1_bare
    rs['vegetation_width'] = vegetation_width
    rs['returnperiod'] = 100 # storm (predefined)
    rs['waveloss_veg'] = ener_per_veg
    rs['waveloss_noveg'] = ener_per_noveg

    # Layer sources
    rs['src_vegpresence'] = src_vegpresence
    rs['src_bathymetry'] = src_bathymetry
    rs['src_topography'] = src_topography
    
    # Confidence values
    rs['conf_vegpresence'] = '0'
    rs['conf_bathymetry'] = '0'
    rs['conf_topography'] = '0'
    rs['conf_waves'] = '0'
    rs['conf_surge'] = '0'
    rs['conf_vegproperties'] = '0'
    
    # Plot xo/xend
    rs['plotx0'] = plotx0 # for plotting
    rs['plotxend'] = plotxend # for plotting

    # Values xBeach
    rs['vegpresence_xbeach'] = vegpresence_xbeach
    rs['xaxis_xbeach'] = xaxis_xbeach
    rs['bedlevel_xbeach'] = bedlevel_xbeach

    ## Table sensitivity
    sql = """select vegtype, returnperiod, rch_q01,zs0, hs_offshore, "T_peak"
            from public.expert_transects et
            join public.transectresults t on t.transectid = et.id
            where fastid = '{id}'            
            """.format(id=transectid)
    sens_table = sqlfunctions.executesqlfetch(sql, credentials)
    logging.info(sens_table)
    rs['sensitivity_table'] = sens_table
    
    # Determine contribution of vegetation based on vegtype
    vpresence = 1
    vcontribution = 0
    try:
	    if (abs(hs_levee_bare - hs_levee)/hs_levee_bare) > 0.2:
	        vcontribution = 1
    except:
    	pass

    convals = {}
    convals['vegetation'] = vpresence
    convals['contribution'] = vcontribution
    rs['convals'] = convals

    return rs

    
def edu2expResult(context, confidence, convals, conditions, transect):
    rs = dict()

    # Old names
    rs['convals'] = { "contribution" : convals['contribution'], "vegetation" : convals['vegetation']}

    # Compatibility with expert transect
    rs['vegetation_width'] = "%.1f"%float(context['vegwidth'][0])
    rs['zs0'] = "%.1f"%float(context['water_level'][0]) # water_level_m
    rs['vegtype'] = int(context['vegtype'][0]) # vegetation_type
    rs['hs_levee'] = "%.1f"%float(float(math.sqrt(2.0)*float(context['hrms_veg1'][0]))) # sqrt(2)*hrms_enveg (sqrt(2) because of difference in H_significant and H_rootmeansquare    
    rs['hs_levee_bare'] = "%.1f"%float("%.2g"%float(math.sqrt(2.0)*float(context['hrms_veg0'][0])))  # sqrt(2)*hrms_enveg0    
    rs['tpeak'] = "%.1f"%float(float(context['trep_s'][0]))  # trep_s
    rs['hs_nearshore'] = "%.1f"%float(context['Hs_in'][0]) # Hs_in
    rs['slope'] = "%d"%(int(context['slope'])) # Slope
    
    # Values only available for Xbeach transect results
    rs['rch_q01_bare'] = "%.1f"%float(float(math.sqrt(2.0)*float(context['Rc_noveg'][0]))) # Rc_noveg
    rs['rch_q01'] = "%.1f"%float(float(math.sqrt(2.0)*float(context['Rc_veg'][0]))) # Rc_noveg

    # Return period
    rs['returnperiod'] = context['storm'][0] # storm 

    # Hardcode must change
    rs['src_vegpresence'] = confidence['src_vegpresence']
    rs['src_bathymetry'] = confidence['src_bathymetry']
    rs['src_topography'] = confidence['src_topography']
    rs['src_vegproperties'] = confidence['src_vegproperties']
    rs['conf_topography'] = confidence['conf_topography']
    rs['conf_vegpresence'] = confidence['conf_vegpresence']
    rs['conf_bathymetry'] = confidence['conf_bathymetry']
    rs['conf_waves'] = confidence['conf_waves']
    rs['conf_surge'] = confidence['conf_surge']
    rs['conf_vegproperties'] = confidence['conf_vegproperties']

    # Conditions
    rs['beginforeshore'] = conditions['beginforeshore']
    rs['endforeshore'] = conditions['endforeshore']
    rs['plotx0'] = conditions['plotx0']
    rs['plotxend'] = conditions['plotxend']
    rs['waterlevel'] = context['water_level'][0]
    rs['surge'] = context['surge'][0]
    rs['hrms'] = context['hrms_veg0'][0]
    rs['vegpresence_xbeach'] = str(conditions['veg'])
    rs['bedlevel_xbeach'] = str(conditions['elev'])
    rs['xaxis_xbeach'] = str(conditions['xaxis'])    
    
    # dummy values
    rs['sensitivity_table'] = [(0, 100, -99999, -99999, -99999, -99999), (1, 100, -99999, -99999, -99999, -99999), (2, 100, -99999, -99999, -99999, -99999), (3, 100, -99999, -99999, -99999, -99999), (0, 1000, -99999, -99999, -99999, -99999), (1, 1000, -99999, -99999, -99999, -99999), (2, 1000, -99999, -99999, -99999, -99999), (3, 1000, -99999, -99999, -99999, -99999), (0, 10, -99999, -99999, -99999, -99999), (1, 10, -99999, -99999, -99999, -99999), (2, 10, -99999, -99999, -99999, -99999), (3, 10, -99999, -99999, -99999, -99999)]
    rs['linestr'] = transect
    rs['linestr_foreshore'] = cut_transect(transect, conditions['beginforeshore'], conditions['endforeshore'])

    return rs

def cut_transect(linestr, begX,endX):
	""" For a given transect
	get subselection [beginforeshore, endforeshore] to plot in the interface
	2Km fixed transect
	"""
	line = wkt.loads(linestr)	
	modulus = 2000 					
	ratio_beg = begX/modulus
	ratio_end = endX/modulus

	x0 = line.coords[0][0] + ratio_beg*(line.coords[1][0] - line.coords[0][0])
	x1 = line.coords[0][0] + ratio_end*(line.coords[1][0] - line.coords[0][0])
	y0 = line.coords[0][1] + ratio_beg*(line.coords[1][1] - line.coords[0][1])
	y1 = line.coords[0][1] + ratio_end*(line.coords[1][1] - line.coords[0][1])
	sublinestr = 'LINESTRING ({} {}, {} {})'.format(x0,y0,x1,y1)

	logging.info('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^')
	logging.info('Original  = {}'.format(linestr))
	logging.info('Foreshore = {}'.format(sublinestr))
	logging.info('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^')

	return sublinestr


def find_diva_profiles(line_wkt, limit=2):
    """ For a given point
    find nearest DIVA profiles.

    Also see
    https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/sql/diva_from_pg.py
    """

    line = wkt.loads(line_wkt)
    wktpoint = line.centroid
    if DEBUG: logging.info(wktpoint)

    cf = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'pgconnection_diva.txt')
    credentials = sqlfunctions.get_credentials(cf)

    # select diva segment closest to a certain point
    sql = """SELECT * FROM oceanographic.surge_levels_diva_segments
            ORDER BY ST_Distance(st_pointfromtext('{wkt}',4326),geom)
            LIMIT {l}""".format(wkt=wktpoint,l=limit)

    profiles = sqlfunctions.executesqlfetch(sql, credentials)

    return profiles


def era_return_periods(line_wkt): #obsolete from dec 2016
    """ For a given point
    find nearest significant wave height derived from era-interim for a fixed return period (1/10 years)

    Also see
    https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/sql/diva_from_pg.py
    """
    line = wkt.loads(line_wkt)
    wktpoint = line.centroid
    
    cf = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'pgconnection_diva.txt')
    credentials = sqlfunctions.get_credentials(cf)

    # select diva segment closest to a certain point
    sql = """SELECT rpid, returnperiod FROM oceanographic.erareturnperiods
            order by ST_Distance(st_pointfromtext('{wkt}',4326),geom)
            limit 1""".format(wkt=wktpoint)
    #TODO: presently, the table with wave heights seems to be the yearly max (i.e. not 1/10 year); replace by new table with Hs and Tp for multiple return periods        
    rpid, hsig0 = sqlfunctions.executesqlfetch(sql, credentials)[0]

    if DEBUG: logging.info('hsig0: '+str(hsig0))
    return hsig0

def divaworldwaves_return_periods(line_wkt, returnperiod):
    """ For a given point
    find nearest significant wave height and peak period derived from era-interim for a given return period 

    Also see
    https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/sql/diva_from_pg.py
    """
    line = wkt.loads(line_wkt)
    wktpoint = line.centroid
    
    cf = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'pgconnection_diva.txt')
    credentials = sqlfunctions.get_credentials(cf)

    colpostfix = find_nearest(np.array([1,2,5,10,25,50,100,250,500,1000]), float(returnperiod))
    columnameH = ''.join(['hs_',str(colpostfix),'_m'])
    if DEBUG: logging.info("hs column hs_{}".format(str(colpostfix)))

    # select diva segment closest to a certain point
    sql = """SELECT {columname} FROM oceanographic.diva_worldwaves
            order by ST_Distance(st_pointfromtext('{wkt}',4326),geom)
            limit 1""".format(columname=columnameH,wkt=wktpoint)
    hsig0 = sqlfunctions.executesqlfetch(sql, credentials)[0]

    columnameT = ''.join(['tp_',str(colpostfix),'_s'])
    if DEBUG: logging.info("returnperiod column tp_{}".format(str(colpostfix)))

    # select diva segment closest to a certain point
    sql = """SELECT {columname} FROM oceanographic.diva_worldwaves
            order by ST_Distance(st_pointfromtext('{wkt}',4326),geom)
            limit 1""".format(columname=columnameT,wkt=wktpoint)
    waveperiod = sqlfunctions.executesqlfetch(sql, credentials)[0]

    if DEBUG: 
        logging.info('hsig0: '+str(hsig0))
        logging.info('waveperiod: '+str(waveperiod))
    return hsig0, waveperiod
    
def surge_return_periods(line_wkt,rp=10):
    """ For a given point
    find nearest surgelevel based on return periods in surge table

    Also see
    https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/sql/diva_from_pg.py
    """
    line = wkt.loads(line_wkt)
    wktpoint = line.centroid

    cf = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'pgconnection_diva.txt')
    credentials = sqlfunctions.get_credentials(cf)

    # select diva segment closest to a certain point
    sql = """SELECT gid, rp000{rp} FROM oceanographic.surge_levels_diva
            order by ST_Distance(st_pointfromtext('{wkt}',4326),geom)
            limit 1""".format(wkt=wktpoint,rp=rp)
            
    res = sqlfunctions.executesqlfetch(sql, credentials)
    surge = 0
    if (res != None):
        gid, surge = res[0]
        
    if DEBUG: logging.info('Surge: '+str(surge))
    return surge

def vegetation(vegGEE, linestr, crs, host, layer, beginforeshore, endforeshore):
    """
    GLOBCOVER and CORINE LAND COVER
    -1 no vegetation
    1 intertidal vegetation
    2 does not occur in globcover
    3 water
    4 inland marsh
    5 broadleaved forest
    6 mangrove forest
    """
    
    # General assumption
    lwkt = wkt.loads(linestr)
    center_lat=(lwkt.coords[0][1] + lwkt.coords[1][1])/2.0
    mangrove_land = (center_lat < 30.0 and center_lat > -30.0)

    # Get vegetation data
    lstveg = [1,2,3,4,5,6]
    vegCor=find_layer_geoserver(linestr, crs, host, layer)    
    try:
    	xvegC,vegC = zip(*vegCor)
    except:
    	xvegC,vegC = [], [] # empty set

    # Absolutely no vegetation, no need to continue
    if vegC==[] or vegCor==[]:
    	return -1, 0, [], []

    # Merge Globcover/vegGEE to obtain more resolution
    v=[]
    for vG in vegGEE:
         if not(vG[1] is None): # Vegetation found in GEE	
         	globcov=vegC[nearest(xvegC, vG[0])]
         	if globcov is None or globcov == 3:
         		if mangrove_land: 
         			v.append([vG[0], 5]) # Hole in Globcover/Corine + equatorial -> assume broadlevel (Mindert/Jasper)
         		else:
         			v.append([vG[0], 1]) # Hole in Globcover/Corine + outside equator -> assume salt marsh (Mindert/Jasper)
         	else:
         		v.append([vG[0], globcov])

    # Process vegetation (only on the shore)
    # 200m added to foreshore since Globcover does not enough resolution
    vegt=[]
    xvegt=[]
    for p in v:
    	if p[0] >= beginforeshore and p[0] <= endforeshore and not(p[1] is None) and (p[1]==1 or p[1]>3): # vegetated foreshore (1,4,5)
    		vegt.append(p[1])
    		xvegt.append(p[0])

    # Foreshore vegetation - one pixel vs more than one
    if len(vegt) == 0:
    	vegwidth = 0
    	vegtype = -1
    elif len(vegt) == 1:
    	vegwidth = 300 # corine resolution approx 
    	vegtype = vegt[0]
    else:
    	vegwidth = max(xvegt) - min(xvegt)
    	vegtype = getmostoccurring(vegt)

    # Jasper equatorial recipe (we will change it someday)
    logging.info(vegtype)
    if vegtype == 5 and mangrove_land:
    	vegtype = 6

    return vegtype, vegwidth, vegCor, lstveg

def getmostoccurring(lst):
    """Gets most occuring vegetation type in transect"""
    count = {}
    items = []
    for av in lst:
        count[av] = lst.count(av)
    
    for k, a in count.items():
        if a == max(count.values()):
            items.append(k)
    return items[0]

def find_nearest(array, value):
    """Finds nearest value in array. 
    taken from stack^ question 2566412"""
    idx = (np.abs(array - value)).argmin()
    return array[idx]

def getattenuation(slope, veg_width, veg_type, sigwaveheigth, waveperiod, water_level): 
    """Lookup value in bayesianfasttable.

    Returns value of row with specified foreshore parameters.
    Based on input variables.

    Arguments:
        slope {[type]} -- [description]
        veg_width {[type]} -- [description]
        veg_type {[type]} -- [description]
        sigwaveheight {[type]} -- significant waveheight
        waveperiod {[type]} -- wave period
        water_level {[type]} -- water_level (surge + tide combined)

    """
    cf = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'pgconnection_fast.txt')
    credentials = sqlfunctions.get_credentials(cf)

    # Find nearest value in table for SLOPE
    sql = "SELECT DISTINCT(slope_m_1m) FROM public.bayesianresults_new"
    slopes = sqlfunctions.executesqlfetch(sql, credentials)
    #slopes = [s[0] for s in slopes]
    slope_ = find_nearest(np.array(slopes), slope)
    if DEBUG: logging.info("Slope is {}, nearest {}".format(slope, slope_))

    # Find nearest value for HS_IN
    sql = "SELECT DISTINCT(hs0_m) FROM public.bayesianresults_new"
    hs_ins = sqlfunctions.executesqlfetch(sql, credentials)
    #hs_ins = [hs_in[0] for hs_in in hs_ins]
    sigwaveheigth_ = find_nearest(np.array(hs_ins), sigwaveheigth)
    if DEBUG: logging.info("Hs in {}, nearest {}".format(sigwaveheigth, sigwaveheigth_))

    # Find nearest value for Trep_s representative wave period
    waveconS=np.array([7., 15., 30.])                  #wave steepness (H/L=max 7), as used to create Bayesian table
    TrepS=np.array([7., 15., 30.]) #dummy       
    for i in range(0, len(waveconS)):
        TrepS[i]=math.sqrt(2*math.pi*waveconS[i]*sigwaveheigth_/9.81)    
    t_intable=find_nearest(TrepS,waveperiod)
    sql = "SELECT DISTINCT(trep_s) FROM public.bayesianresults_new"
    trep = sqlfunctions.executesqlfetch(sql, credentials)
    #hs_ins = [hs_in[0] for hs_in in hs_ins]
    trep_ = find_nearest(np.array(trep), t_intable)
    if DEBUG: 
        logging.info(trep)
        logging.info(t_intable)
        logging.info('---------------------------')
        logging.info("Trep in {}, nearest {}".format(waveperiod, trep_))

    # Find nearest value for waterlevel
    sql = "SELECT DISTINCT(water_level_m) FROM public.bayesianresults_new"
    wls = sqlfunctions.executesqlfetch(sql, credentials)
    wl_ = find_nearest(np.array(wls), float(water_level))
    if DEBUG: logging.info("Water level in {}, nearest {}".format(water_level, wl_))
    
    # find nearest value for vegwidth
    #TODO find the column to get the hrms waveheigt based on vegwidth
    #TODO get column based on the name, hrms_100, hrms_250, hrms_500, hrms_1000, hrms_2000
    #TODO the difference between the vegwidth related to the 
    colpostfix = find_nearest(np.array([100,250,500,1000,2000]), float(veg_width))
    columname = ''.join(['hrms_',str(colpostfix),'_m'])
    if DEBUG: logging.info("hrms column hrms_{}".format(str(colpostfix)))
    
    # find nearest value for vegetation type
    sql = "SELECT DISTINCT(vegetation_type) FROM public.bayesianresults_new"
    vts = sqlfunctions.executesqlfetch(sql, credentials)
    vt_ = find_nearest(np.array(vts), veg_type)
    if DEBUG: logging.info("Vegtype in {}, nearest {}".format(veg_type, vt_))

    # Calculate relative wave reduction when vegetation present; based on input parameters
    #TODO: query for Hrms_vegxxx where xxx=vegwidth + make Hrms_vegxxx and Hrms_vegxxxx without veg available outside this funtion to enable calculation of required crest height
    sql = "SELECT {} FROM public.bayesianresults_new WHERE \
    slope_m_1m={} AND vegetation_type={} AND hs0_m={} AND water_level_m={} and trep_s={}".format(columname,slope_[0], vt_[0], sigwaveheigth_[0], wl_[0],trep_[0])
    if DEBUG: logging.debug(sql)
    hrms_endveg = sqlfunctions.executesqlfetch(sql, credentials)[0][0]
    hrms_endveg = max(hrms_endveg, 0.001)
    
    # calculate relative wave reduction when vegetation absent;  based on input parameters for zero vegetation
    sql = "SELECT {} FROM public.bayesianresults_new WHERE \
    slope_m_1m={} AND vegetation_type={} AND hs0_m={} AND water_level_m={} and trep_s={}".format(columname,slope_[0], 0, sigwaveheigth_[0], wl_[0],trep_[0])
    if DEBUG: logging.debug(sql)
    hrms_endveg0 = sqlfunctions.executesqlfetch(sql, credentials)[0][0]
    hrms_endveg0 = max(hrms_endveg0, 0.001)
    
    # Attenuation factor
    # return an array with result and derived parameters (slope, waterelevel, return period)
    if DEBUG: 
        logging.info("HRMS with vegetation {}".format(hrms_endveg))
        logging.info("HRMS without vegetation {}".format(hrms_endveg0))

    if hrms_endveg0/hrms_endveg > 1.2:
        return ["1",slope_,wl_,sigwaveheigth_,hrms_endveg,hrms_endveg0,trep_]
    else:
        return ["0",slope_,wl_,sigwaveheigth_,hrms_endveg,hrms_endveg0,trep_]

# Change linesect coordinates
def change_coords(px, py, epsgin='epsg:4326', epsgout='epsg:3857'):
    outProj = Proj(init=epsgout)
    inProj = Proj(init=epsgin)
    return transform(inProj,outProj,px,py) 

# Based on simplified osm coastlines    
def water_or_land_wgs84(pwkt, srid=4326):
    # DB credentials
    cf = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'pgconnection_coastal.txt')
    credentials = sqlfunctions.get_credentials(cf)

    # Get Box that contains point      
    strSql = """select gid from public.land_polygons where ST_Contains(geom, ST_PointFromText('{wkt}',{srid}))""".format(wkt=pwkt,srid=srid)    
    try:
        a = sqlfunctions.executesqlfetch(strSql, credentials)         
    except Exception:
        logging.info(''.join(['sql failed',strSql]))

    # Box was found get vegetation value
    if len(a):
    	logging.info('Click on Land')
        return True # land       
    logging.info('Click on Water')
    return False # water      

# Latlon 4236 layer (no transformation required)
def find_layer_geoserver(linestr, crs, host, layer):  
    # Query layer and return results
    l = LS(linestr, crs, host, layer)
    l.line()
    l.intersect()
    data = json.loads(l.json())  
    # Remove None
    data = [x for x in data if x[1] is not None]
    return data

# For layers are defined in different epsg
def find_layer_changecoords_geoserver(linestr, crs, crswcs, host, layer):
    # Convert linestr projection
    lwkt = wkt.loads(linestr)
    (cx0,cy0) = change_coords(lwkt.coords[0][0], lwkt.coords[0][1], epsgout='epsg:{}'.format(crswcs))
    (cx1,cy1) = change_coords(lwkt.coords[1][0], lwkt.coords[1][1], epsgout='epsg:{}'.format(crswcs))
    linestr_epsg="""LINESTRING ({x0} {y0}, {x1} {y1})""".format(x0=cx0,y0=cy0,x1=cx1,y1=cy1)
    
    # Query layer and return results
    l = LS(linestr_epsg, 3857, host, layer)
    l.line()
    l.intersect()
    data = json.loads(l.json())    
    
    # Checkout the NaN percentage
    nans = 0.0
    for d in data:
        if d[1] is None:       nans+=1.
        elif np.isnan(d[1]):   nans+=1.

    return data, int(nans/float(len(data))*100) # Percentage of NaN

def find_coastal_table(slope, veg_width, veg_type, ret, water_level, att_threshold=0.436): #obsolete since dec 2016
    """Lookup value in bayesianfasttable.

    Returns value of row with specified foreshore parameters.
    Based on input variables.

    Arguments:
        slope {[type]} -- [description]
        veg_width {[type]} -- [description]
        veg_type {[type]} -- [description]
        ret {[type]} -- [description]
        water_level {[type]} -- [description]

    Keyword Arguments:
        att_threshold {number} -- [description] (default: {0.436})
    """
    cf = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'pgconnection_fast.txt')
    credentials = sqlfunctions.get_credentials(cf)

    # Find nearest value in table for SLOPE
    sql = "SELECT DISTINCT(slope) FROM public.bayesianresults_new"
    slopes = sqlfunctions.executesqlfetch(sql, credentials)
    #slopes = [s[0] for s in slopes]
    slope_ = find_nearest(np.array(slopes), slope)
    if DEBUG: logging.info("Slope is {}, nearest {}".format(slope, slope_))

    # Find nearest value for HS_IN
    sql = "SELECT DISTINCT(hs_in) FROM public.bayesianresults_new"
    hs_ins = sqlfunctions.executesqlfetch(sql, credentials)
    #hs_ins = [hs_in[0] for hs_in in hs_ins]
    ret_ = find_nearest(np.array(hs_ins), ret)
    if DEBUG: logging.info("Hs in {}, nearest {}".format(ret, ret_))

    # Find nearest value for waterlevel
    sql = "SELECT DISTINCT(water_level) FROM public.bayesianresults_new"
    wls = sqlfunctions.executesqlfetch(sql, credentials)
    wl_ = find_nearest(np.array(wls), float(water_level))
    if DEBUG: logging.info("Water level in {}, nearest {}".format(water_level, wl_))
    
    # find nearest value for vegwidth
    sql = "SELECT DISTINCT(vegwidth) FROM public.bayesianresults_new"
    vws = sqlfunctions.executesqlfetch(sql, credentials)
    vw_ = find_nearest(np.array(vws), float(veg_width))
    if DEBUG: logging.info("Veg width in {}, nearest {}".format(veg_width, vw_))
    
    # find nearest value for vegetation type
    sql = "SELECT DISTINCT(vegtype) FROM public.bayesianresults_new"
    vts = sqlfunctions.executesqlfetch(sql, credentials)
    vt_ = find_nearest(np.array(vts), veg_type)
    if DEBUG: logging.info("Vegtype in {}, nearest {}".format(veg_type, vt_))

    # Calculate relative wave reduction when vegetation present; based on input parameters
    # query for Hrms_vegxxx where xxx=vegwidth + make Hrms_vegxxx and Hrms_vegxxxx without veg available outside this funtion to enable calculation of required crest height
    sql = "SELECT (hrms_veg0 - hrms_veg1)/hrms_veg0 FROM public.bayesianresults_new WHERE \
    slope={} AND vegwidth={} AND vegtype={} AND hs_in={} AND water_level={}".format(slope_[0], vw_[0], vt_[0], ret_[0], wl_[0])
    if DEBUG: logging.debug(sql)
    att = sqlfunctions.executesqlfetch(sql, credentials)[0][0]
    
    # calculate relative wave reduction when vegetation absent;  based on input parameters for zero vegetation
    sql = "SELECT (hrms_veg0 - hrms_veg1)/hrms_veg0 FROM public.bayesianresults_new WHERE \
    slope={} AND vegwidth={} AND vegtype={} AND hs_in={} AND water_level={}".format(slope_[0], vw_[0], 0, ret_[0], wl_[0])
    if DEBUG: logging.debug(sql)
    att0 = sqlfunctions.executesqlfetch(sql, credentials)[0][0]
    
    # Attenuation factor
    # return an array with result and derived parameters (slope, waterelevel, return period)
    if DEBUG: 
        logging.info("Attenuation factor with vegetation {}".format(att))
        logging.info("Attenuation factor without vegetation {}".format(att0))

    if att > att_threshold:
        return ["1",slope_,wl_,ret_,att,att0]
    else:
        return ["0",slope_,wl_,ret_,att,att0]

def calc_RCH(hrms_endveg, trep):
    ''' calculates required crest height of a levee, given wave conditions at dike toe (Hm0 and spectral period Tmm10), following Eurotop (2007)
    #input variables PC-Overslag (assumed constant for now, representative of simple, weakish levee)
    #for meaning and setting of variables see D5.4 Prototype linkage of general rules engineering requirements of dike design
    #output corresponds to PC-overslag output for same settings (tested for all 3 Em ranges)
    @author: dijks_jr, based on matlab script of Amaury CamarenaDeltares, CSW.''' 
    tanA = 0.3333 #seaward slope steepness
    yb = 1 #factor for berm
    yB = 1 #factor for oblique wave attack
    yv = 1 #factor for crest elements
    yf = 1 #roughness coefficient outer slope
    a = 4.3
    b = 2.3
    c = -0.68
    g = 9.81 #gravitational acceleration
    q=0.001 #overtopping criterion (m3/m2/s) (0.1 l/s/m2 is very conservative)
    
    #transform XBoutput to right parameters:
    #TODO extract correct parameters from XB using a spectrum
    Hm0=max(0.05, math.sqrt(2)*hrms_endveg)
    Tmm10=max(0.99,trep/1.1)
    
    #wave breaker param. (depending on the input wave conditions)
    Lm = (g*Tmm10**2)/(2*math.pi)
    Sm = Hm0/Lm #wave steepness
    Em = tanA/math.sqrt(Sm) #breaker parameter

    if Em <=5:
        #mild slopes/steep waves; Equation 1.7
        Rc_17 = ((Em * Hm0 * yb * yf * yB * yv)/-a) * math.log( (q/math.sqrt(g*Hm0**3)) * (math.sqrt(tanA)/0.067) * (1/(yb*Em)))
        Rc_11 = 0.067/(math.sqrt(tanA)) * yb * Em * math.exp(-a * (Rc_17 / (Em*Hm0 * yb * yf *yB * yv)))
        Rc_12 = 0.2 *  math.exp(-b * (Rc_17/ (Hm0 * yf * yB)))       
        if Rc_11<=Rc_12:
            Rc_f = Rc_17
        elif Rc_11>Rc_12:
            #Equation 1.8
            Rc_18 = ((Hm0 * yf * yB)/-b) * math.log((q/math.sqrt(g*Hm0**3)) * (1/0.2))
            Rc_f = Rc_18  
    
    elif Em >=7:
        #steep slopes/long waves; Equation 1.9
        Rc_19 = -yf * yB * Hm0 * (0.33+0.022 * Em) * math.log((q/math.sqrt(g*Hm0**3)) * (1/10**c))
        Rc_f = Rc_19
    
    else: #not mild, not steep: linear interpolation
        #Equation 1.7
        Rc_17i = ((Em * Hm0 * yb * yf * yB * yv)/-a) * math.log( (q/math.sqrt(g*Hm0**3)) * (math.sqrt(tanA)/0.067) * (1/(yb*Em)))
        Rc_11i = 0.067/(math.sqrt(tanA)) * yb * Em *math.exp(-a * (Rc_17i / (Em*Hm0 * yb * yf *yB * yv)))
        Rc_12i = 0.2 *  math.exp(-b * (Rc_17i/ (Hm0 * yf * yB)))  
        if Rc_11i<=Rc_12i:
            Rc_fi = Rc_17i
        elif Rc_11i>Rc_12i:
            #Equation 1.8
            Rc_18i = ((Hm0 * yf * yB)/-b) * math.log((q/math.sqrt(g*Hm0**3)) * (1/0.2))
            Rc_fi = Rc_18i    
        #Equation 1.9
        Rc_19i = -yf * yB * Hm0 * (0.33 + 0.022*Em) * math.log((q/math.sqrt(g*Hm0**3)) * (1/10**c))
        Rc_f = (Em-5)/(7-5)*(Rc_19i-Rc_fi)+Rc_fi

    return Rc_f   
        
def reproject_linestr(lwkt,epsgin, epsgout):
    ls = wkt.loads(lwkt)
    outProj = Proj(init=epsgout)
    inProj = Proj(init=epsgin)
    x1,y1 = transform(inProj,outProj,ls.bounds[0],ls.bounds[1])
    x2,y2 = transform(inProj,outProj,ls.bounds[2],ls.bounds[3])    
    return LineString([(x1,y1),(x2,y2)]).wkt

def checkcoverage(url, location):
    wcs = WebCoverageService(url,version='1.0.0')
    wcs.identification.type
    wcs.identification.title

    lstlayer = list(wcs.contents)
    dctlayers = {}
    for l in lstlayer:
        layer = wcs[l]
        if len(layer.boundingboxes) != 0:
            srid = layer.boundingboxes[0]['nativeSrs']
            projbox = Proj(init=srid)
            projpoint = Proj(init=':'.join(['EPSG',str(location[4])]))
            x0,y0 = transform(projpoint, projbox, location[0],location[1])
            x1,y1 = transform(projpoint, projbox, location[2],location[3])
            bbox = layer.boundingboxes[0]['bbox']
            polygon = Polygon([(bbox[0], bbox[1]), (bbox[0], bbox[3]), (bbox[2], bbox[3]),(bbox[0],bbox[3])])
            point0 = Point(x0,y0)
            point1 = Point(x1,y1)
            if point0.within(polygon) and point1.within(polygon):
                dctlayers[l] = srid
    return dctlayers

def get_confidence_wms(layername, wms_url='http://fast.openearth.eu/geoserver/wms?service=WMS&version=1.1.0'):
    wms = WebMapService(wms_url)
    layers = list(wms.contents)
    att = -1
    try:
        for layer in layers:
            if layer == layername:
                att = wms[layer].attribution['title'].replace('\"','')
    except:
        pass # default is -1
    return att    
    
def checkBestLayer(line_wkt, epsg, pattern='DTM', wcsurl = 'http://fast.openearth.eu/geoserver/ows'):
        # location is x,y,srid
        ls = wkt.loads(line_wkt)
        location = [ls.bounds[0], ls.bounds[1], ls.bounds[2], ls.bounds[3], epsg]  # st(x,y) end(x,y) epsg

        # All layers available for that location
        dctlayers = checkcoverage(wcsurl, location)

        # Layer decision (get the best data possible)
        sel_layer = 'undef'
        sel_conf = 99  # The lower the confidence value the better [0,1,2]

        for patt in pattern.split(','):
            regexp = '*{al}*'.format(al=patt)
            layerF = fnmatch.filter(dctlayers, regexp)
            if len(layerF) > 0:
                conf = get_confidence_wms(layerF[0])

                if int(conf) < int(sel_conf):
                    sel_layer = layerF[0]  # get the best layer to get data from
                    sel_conf = conf  # update threshold

        # No data found, no update
        if sel_layer == 'undef':
            return (None, None)

        return (sel_layer, sel_conf)    

def NoneforNan(vect):
	return np.array(vect, dtype=np.float).tolist()

# Combine intertidal information + SRTM into a single elevation profile    
def stichingElevation(GEE_elevation, SRTM_elevation, surge): 
    newprofile=[]
    intertidalmask=[]
    srtmdist, srtmelev = zip(*SRTM_elevation)
    geedist, geeelev = zip(*GEE_elevation)
    
    # Check GEE_elevation dataset to see quality    
    # 0] Avoid fake profile [0 is NaN value used unfortunately, MSL, transparent on map]
    # 1] Steep profile in SRTM indicates also that intertidal should not work
    # If so, we skip and use SRTM for foreshore estimations
    mean_gee = abs(np.nanmean(geeelev))
    stdv_gee = abs(np.nanstd(geeelev))   
    diff_slope = abs(max(srtmelev)-min(srtmelev))
    avoid_intertidal = ((mean_gee < 0.1) and (stdv_gee < 0.1)) or (diff_slope > 75)
    if avoid_intertidal:
        GEE_elevation = SRTM_elevation
        geedist = srtmdist
        geeelev = srtmelev
        logging.info('################################################################')
        logging.info('Skipping flat intertidal data or very steep coastline, no intertidal use')
        logging.info('Mean[intertidal] = {} and Stdev[intertidal] = {}'.format(mean_gee, stdv_gee))
        logging.info('Diff[SRTM] = {}m'.format(diff_slope))
        logging.info('################################################################')

    # Slope calculated from intertidal only if enough values after removing NaN    
    x=[]
    y=[]
    beginforeshore = 0.0
    for xe,ye in GEE_elevation:   
        if not(ye is None):
            if ~np.isnan(ye):
                if beginforeshore == 0.0: beginforeshore = xe # first intertidal value
                x.append(xe)
                y.append(ye)

    # Usign intertidal elevation only is 20% transect coverage
    if len(y) > 20: 
        # around 300meters [280 = 400] of the total 2km
        slope, intercept, r_value, p_value, std_err = linregress(x, y)
        yslopemin = min(y)
        # Merging elevation
        ind=0
        N=len(geeelev)
        patch_thr=5        
        # Caring about gaps
        while (ind < N-1):
            # GAP in data
            hole_len=0          
            while (np.isnan(geeelev[ind+hole_len]) and ind+hole_len < N-1):
                hole_len+=1
            if hole_len > patch_thr: # big hole (take srtm)             
                for p in SRTM_elevation[nearest(srtmdist, geedist[ind]):nearest(srtmdist, geedist[ind+hole_len])]: 
                	newprofile.append(p)                	                
            # next
            ind+=hole_len
            # DATA patch
            data_len=0
            while (not(np.isnan(geeelev[ind+data_len])) and ind+data_len < N-1):                
                data_len+=1
            if data_len > patch_thr: # big data (take intertidal)
                for p in GEE_elevation[ind:ind+data_len]: 
                	newprofile.append(p)
                	intertidalmask.append(p[0])                	
            # next                  
            ind+=data_len

        # Sometimes... rarely, stiching creates one separate outlier
        lstx=0
        for n in newprofile:
        	if n[0] < lstx:	
        		newprofile.remove(n)
        		logging.info('Removing: ' + str(n))
        	lstx = n[0]
    else: 
    # not enough intertidal data, just SRTM
        newprofile = SRTM_elevation
        slope, intercept, r_value, p_value, std_err = linregress(srtmdist, srtmelev)
        yslopemin = min(srtmelev)
        beginforeshore = 0 # to avoid begin>end situations (no intertidal)

    # End foreshore (closest point to surge)
    x,y = zip(*newprofile)
    endforeshore = get_endforeshore(x, y, float(surge))    

    # Merged
    return newprofile, slope, yslopemin, beginforeshore, endforeshore, avoid_intertidal, intertidalmask

def is_netherlands(linestr):
    lwkt = wkt.loads(linestr)
    ## Het Netherlands
    nl_lonmin = 2.737
    nl_lonmax = 7.432
    nl_latmin = 50.663
    nl_latmax = 53.723
    ## Inside
    b1=(lwkt.coords[0][0] > nl_lonmin and lwkt.coords[0][0] < nl_lonmax)
    b2=(lwkt.coords[0][1] > nl_latmin and lwkt.coords[0][1] < nl_latmax)
    return b1 and b2    

def is_neworleans(linestr):
    lwkt = wkt.loads(linestr)
    ## Lousiana
    nl_lonmin = -90.65
    nl_lonmax = -89.29
    nl_latmin = 29.69
    nl_latmax = 30.50
    ## Inside
    b1=(lwkt.coords[0][0] > nl_lonmin and lwkt.coords[0][0] < nl_lonmax)
    b2=(lwkt.coords[0][1] > nl_latmin and lwkt.coords[0][1] < nl_latmax)
    return b1 and b2

def is_mozambique(linestr):
    lwkt = wkt.loads(linestr)
    ## Mozambique, Beira [POLYGON((34.829894 -19.755443, 34.938212 -19.755443, 34.938212 -19.858806, 34.829894 -19.858806, 34.829894 -19.755443))]
    nl_lonmin = 34.829894
    nl_lonmax = 34.938212
    nl_latmin = -19.858806
    nl_latmax = -19.755443        
    ## Inside
    b1=(lwkt.coords[0][0] > nl_lonmin and lwkt.coords[0][0] < nl_lonmax)
    b2=(lwkt.coords[0][1] > nl_latmin and lwkt.coords[0][1] < nl_latmax)
    return b1 and b2

def is_europe(linestr):
    lwkt = wkt.loads(linestr)
    ## Europe
    eu_lonmin = -23.7
    eu_lonmax = 39.7
    eu_latmin = 36.5
    eu_latmax = 71.0
    ## Inside
    b1=(lwkt.coords[0][0] > eu_lonmin and lwkt.coords[0][0] < eu_lonmax)
    b2=(lwkt.coords[0][1] > eu_latmin and lwkt.coords[0][1] < eu_latmax)
    return b1 and b2     

# Main entry point for educational transects
def misafeeducational(awkt, crs, geoserver_host='http://fast.openearth.eu/geoserver/wcs?', geoserver_coastlines="http://deltaresdata.openearth.nl/geoserver/global/wfs?", 
	lay_elev="Global_Base_Maps:merit_gebco", lay_veg="Global_Base_Maps:Globcover_reclass", lay_coastlines="global:OSMCoastLines", lay_vegpresence='FAST_global_imagery:GEE_vegetation', lay_intertidal="FAST_global_imagery:GEE_intertidal_elev"):
    # check if water or land
    is_land = water_or_land_wgs84(awkt.replace('"',''))
    if is_land:  # No need to proceed
        logging.error('Landclick detected')
        return [], [], [], [], [], 'landclick_err'
    
    # create a 2000m line with the passed point
    p = P(awkt.replace('"',''),crs, geoserver_coastlines, lay_coastlines)
    p.lines()
    if len(p.ld) == 0:  # No match found
        logging.error('No shore 2km perpendicular transect found')
        return [], [], [], [], [], 'transect_err'
    lwkt = p.selext()
    logging.info('Transect: {}'.format(lwkt))

    # get water level (tide and surge)
    surge = surge_return_periods(lwkt,rp=10)  
    logging.info('surge 1 in 10 years: ' + str(surge))

    # Netherlands better data
    isNL=is_netherlands(lwkt)
    isNO=is_neworleans(lwkt)
    isMZ=is_mozambique(lwkt)
    if (isNL):
        lay_intertidal = 'Global_Base_Maps:nl_ahn_vaklodingen_uc'
        intGEE = find_layer_geoserver(lwkt, crs, geoserver_host, lay_intertidal)
        intGEE_nan = 0
        profile = intGEE
    elif (isNO):
        lay_intertidal = 'Global_Base_Maps:Louisiana_Coastal_DEM'
        intGEE = find_layer_geoserver(lwkt, crs, geoserver_host, lay_intertidal)
        intGEE_nan = 0
        profile = intGEE      
    elif (isMZ):
        lay_intertidal = 'Global_Base_Maps:Beira_CDEM'
        intGEE = find_layer_geoserver(lwkt, crs, geoserver_host, lay_intertidal)
        intGEE_nan = 0
        profile = intGEE
    else:
        # Get intertidal elevation GEE
        intGEE, intGEE_nan = find_layer_changecoords_geoserver(lwkt, crs, 3857, geoserver_host, lay_intertidal)
        if DEBUG: 
            logging.info('intertidalGEE elevation: ' + str(intGEE))
            logging.info('intertidalGEE coverage: ' + str(intGEE_nan)+'%')

        # get elevation profiles GEBCO/SRTM
        profile = find_layer_geoserver(lwkt, crs, geoserver_host, lay_elev)
    
    # Determine slope-total, negative slopes are undetected clicks on the coast
    xp, yp = zip(*profile)
    slope, intercept, r_value, p_value, std_err = linregress(xp, yp)
    if slope < -0.1:
        logging.error('Negative slope')
        return [], [], [], [], [], 'negative_slope'

    # Determine slope and combine elevation profiles
    profile, slope, yslopemin, beginforeshore, endforeshore, avoid_intertidal, intertidalmask = stichingElevation(intGEE, profile, surge)   
    if DEBUG:
        logging.info('STICHING profile: ' + str(profile)) 
        logging.info('STICHING slope: ' + str(slope)) 
        logging.info('STICHING yslopemin: ' + str(yslopemin)) 
        logging.info('STICHING begin-shore: ' + str(beginforeshore))
        logging.info('STICHING end-shore: ' + str(endforeshore))
    
    # Find GEE - vegpresence
    vegGEE, vegGEE_nan = find_layer_changecoords_geoserver(lwkt, crs, 3857, geoserver_host, lay_vegpresence)
    if DEBUG: 
        logging.info('vegGEElocal: ' + str(vegGEE))
        logging.info('vegGEE coverage: ' + str(vegGEE_nan)+'%')
   
    # Hs and Tp from ERA - get wave height and period for returnperiod (1/years) of choice
    returnperiod=10
    hsig0, waveperiod = divaworldwaves_return_periods(lwkt, returnperiod)
    logging.info('Tp from ERA ' + str(waveperiod))    
    logging.info('Hs from ERA ' + str(hsig0))
    logging.info('return period (years) ' + str(returnperiod))
    logging.info('yslopemin ' + str(yslopemin))
      
    # determine maximum wave height based on actual water depth
    maxwavecrit=0.55    
    hsig=min(hsig0[0], abs(maxwavecrit*(float(surge)-yslopemin)))

    # get vegetation type and with / Europe-> Corine / Rest -> Globcover
    if is_europe(lwkt):	
    	lay_veg = 'Global_Base_Maps:EU_Corine_Reclass'
    veg_type,veg_width,v,lstveg = vegetation(vegGEE, lwkt, crs, geoserver_host, lay_veg, beginforeshore, endforeshore)
    if DEBUG: 
        logging.info('vegtype ',veg_type)
        logging.info('veg_width ',veg_width)
        logging.info('v ',v)
        logging.info('lstveg ',lstveg)

    # introduce sigwaveheight and waveperiod from new ERA table with waveheight and -periods
    b = getattenuation(abs(1.0/slope), veg_width, veg_type, hsig0, waveperiod, surge)
    if DEBUG: 
        logging.info(b)

    # calculate required crest height with and without veg:
    Rc_veg = calc_RCH(float(b[4]), float(waveperiod[0]))     # b[4]= hrms_endveg
    Rc_noveg = calc_RCH(float(b[5]), float(waveperiod[0]))   # b[5]= hrms_endveg0

    # Not used anymore (Jasper)
    # b = find_coastal_table(slope, veg_width, veg_type, hsig, surge)
    # if DEBUG: logging.info([b])

    # Slope control infinity
    slp=abs(1.0/slope)
    if slp == float('Inf'): slp = 10000000000

    # formatting 2 decimals
    context={}
    context['slope'] = slp
    context['surge'] = [("%.2g"%float(surge)),'m +MSL']    
    context['vegtype'] = [veg_type,'']
    context['vegwidth'] = ["%d"%(veg_width),'m']     
    context['water_level'] = [("%.2g"%float(surge)),'m +MSL']
    context['Hs_in'] = [("%.2g"%float(hsig)),'m ']
    context['hrms_veg0'] = [("%.2g"%float(b[5])),'m']
    context['hrms_veg1'] = [("%.2g"%float(b[4])),'m']
    context['percentage'] = [("%.2g"%float(b[5]/b[4])),'%']
    context['storm'] = [str(returnperiod), 'year']
    context['trep_s'] = [("%.2g"%float(b[6])),'s']
    context['Rc_noveg'] = [("%.2g"%float(Rc_noveg)),'m']
    context['Rc_veg'] = [("%.2g"%float(Rc_veg)),'m']
    logging.info(context)

    if b[0] == '0':
        context['favourable'] = ['lower','']    
    else:
        context['favourable'] = ['higher','']

    # todo --> confidence should be based on the layers used red, orange, green
    confidence = {}

    # Layer source names
    confidence['src_bathymetry'] = lay_intertidal + ' and ' + lay_elev
    confidence['src_topography'] = lay_intertidal + ' and ' + lay_elev    	
    confidence['src_vegpresence'] = lay_vegpresence
    confidence['src_vegproperties'] = lay_veg
    
    # Layer Confidence defaults [Colors 0,1,2]
    confidence['conf_topography'] = '1'.replace('\"','')
    confidence['conf_vegpresence'] = '0'.replace('\"','')
    confidence['conf_bathymetry'] = '1'.replace('\"','')
    confidence['conf_waves'] = '2'.replace('\"','')
    confidence['conf_surge'] = '2'.replace('\"','')
    confidence['conf_vegproperties'] = '2'.replace('\"','')
    if intGEE_nan>80 or avoid_intertidal: # 20% intertidal coverage
        confidence['conf_bathymetry'] = '2'.replace('\"','')
        confidence['conf_topography'] = '2'.replace('\"','')
        confidence['src_bathymetry'] = lay_elev
        confidence['src_topography'] = lay_elev
    
    # Netherlands precise AHN
    if (isNL or isNO):
        confidence['conf_bathymetry'] = '0'.replace('\"','')
        confidence['conf_topography'] = '0'.replace('\"','')
        confidence['src_bathymetry'] = lay_intertidal
        confidence['src_topography'] = lay_intertidal

    # Store elevation (x,h) values 
    conditions = {}
    conditions['beginforeshore'] = beginforeshore
    conditions['endforeshore'] = endforeshore
    conditions['profile'] = profile
    conditions['elev'] = []
    conditions['xaxis'] = []
    for x,h in profile:
        conditions['xaxis'].append(x)
        conditions['elev'].append(h)

    # Vegetation type/class profile (above sea level)
    if len(v):
        xv, veg = zip(*v)
        vegprofile = []
        if len(veg) > 0: 
            for x,h in profile:
                if veg[nearest(xv, x)] in lstveg:
                    vegprofile.append([x, h])
                else:
                    vegprofile.append([x, -999999])        
        conditions['vegetation_t'] = vegprofile
        conditions['veg_t'] = veg
    else:
        conditions['vegetation_t'] = []
        conditions['veg_t'] = []

    # Vegetation presence yes/no profile (above sea level)
    dist,elev = zip(*profile)   
    vegprofileGEE = []
    if len(vegGEE) > 0:
        for xv,vegp in vegGEE:
            ind=0
            # Get closest values
            for xp,yh in profile:
                if xv < xp: break # found
                ind+=1            
            # Get height value (linear estimation)
            try:
                if ind == 0:
                    hinterp = elev[ind]
                else:               
                    hinterp = elev[ind-1] + float(elev[ind] - elev[ind-1]) * (xv-dist[ind-1])/(dist[ind]-dist[ind-1])
            except:
                hinterp = elev[ind-1]

            # Append height or NaN (plotting)
            if vegp is None:    vegprofileGEE.append([xv, -999999])
            else:               vegprofileGEE.append([xv, hinterp])

    conditions['vegetation'] = vegprofileGEE
    conditions['veg'] = 0

    if DEBUG: 
        logging.info('Vegetation (Glob): ' + str(vegprofileGEE))
        logging.info('Vegetation (GEE): ' + str(vegp))
        
    # Plot xo-xend
    conditions['plotx0'] = max(dist[0], vegGEE[0][0])
    conditions['plotxend'] = min(dist[-1], vegGEE[-1][0])
    conditions['intertidalmask'] = intertidalmask

    # determine contribution of vegetation based on vegtype
    if veg_width == 0: 
        vpresence = 0
        vcontribution = 0
    else:
        vpresence = 1
        vcontribution = b[0]
    convals = {}
    convals['vegetation'] = vpresence
    convals['contribution'] = vcontribution
        
    # TODO: check whether this is stable for all input values, e.g. 0
    if vpresence == 1 and len(b)>7: # safety check
        Rc_veg = calc_RCH(b[7], waveperiod) #b[7]= hrms_endveg
        if DEBUG: logging.info('Required Crest Height with veg: ' + str(Rc_veg))

    return context, confidence, convals, conditions, lwkt, 'ok'

def nearest(array, value):
    """Returns first index of the array closest to given value."""
    return np.abs(np.array(array) - value).argmin()

def nearest_last(array, value):
    """Returns last index closest to a given value. """    
    return -1 + len(array) - np.abs(np.array(array[::-1]) - value).argmin()

def get_endforeshore(dist, elev, surge):
    """Returns Intersection between profile and surge"""
    i=0
    while i<len(elev)-1:
    	if(elev[i]>=surge): break
    	i+=1    
    return dist[i]

if __name__ == "__main__":
    #vals = misafeeducational("POINT(4.8317 5.4821)",4326)
    #vals = misafeeducational("POINT(4.9474 53.2741)",4326)    
    #vals = misafeeducational("POINT(3.722 51.354)",4326) #for testing field sites: Paulina, NL
    #vals = misafeeducational("POINT(0.117 53.492)",4326) #Donna Nook, UK
    #vals = misafeeducational("POINT(0.948 51.679)",4326) #Tillingham, UK
    #vals = misafeeducational("POINT(-6.174 36.515)",4326) #Cadiz, ES
    #vals = misafeeducational("POINT(28.94 44.75)",4326) #Jurilovca, RO
    #vals = misafeeducational("POINT(-6.2299 36.5476)", 4326) #near Cadiz, with intertidalveg 
    #vals = misafeeducational("POINT(1.1787128448485824 41.06964555376804)", 4326)
    #b = getattenuation(250, 500, 1, 2, 5, 5)    
    #context,confidence,convals,conditions,lwkt = misafeeducational("POINT(7.0809513329773015 43.56489007776877)",4326)    
    #misafexperttransect("POINT(28.94 44.75)",4326)    
    vals = misafeeducational("POINT(-55.356196 5.967 )",4326) #NW of Paramaribo, mangroves
    
    # Performance test
    #vals = misafeeducational("POINT(28.90509670722107 44.59416834292302)", 4326)
    vals = misafexpert("POINT(0.94382 51.67968)",4326)
    print vals
    print 'DONE'    
