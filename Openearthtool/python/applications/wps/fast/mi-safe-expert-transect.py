# -*- coding: utf-8 -*-
"""
Created on Thu Feb  5 13:25:03 2015
@author: Joan Sala, Gerrit Hendriksen

Repository information:
Date of last commit:    $Date: 2016-06-13 12:35:31 +0200 (Mon, 13 Jun 2016) $
Revision of last commi: $Revision: 5712 $
Author of last commit:  $Author: hendrik_gt $
URL of source:          $HeadURL: https://repos.deltares.nl/repos/FAST/datamanagement/tools/pointsect.py $
CodeID:                 $ID$
"""

from pywps.Process import WPSProcess
from pywps.Exceptions import *

import random
import string
import json
import os
import logging
import types
import getOGCdata
from fast_plots import bokeh_fast_plot
from shapely import wkt

DEBUG = False # uncomment to debug

class Process(WPSProcess):
    def __init__(self):
        # Configuration
        self.host_url = 'http://dl-053.xtr.deltares.nl/bokeh_plots/'
        self.tmp_dir = '/var/www/html/bokeh_plots'
        
        WPSProcess.__init__(self,
            identifier = "mi-safe-expert-transect", # must be same, as filename
            title="MI-Safe Educational WPS",
            version = "0.1",
            storeSupported = "true",
            statusSupported = "true",
            abstract="Returns json dump of values of grid intersection with line.")

        # INPUTS
        self.point = self.addLiteralInput(identifier = "point",
                                            title = "Point",
                                            type=types.StringType,
                                            default="POINT(43.2,3.4)")

        self.crs= self.addLiteralInput(identifier="crs",
                                           title="EPSG code",
                                           type=types.IntType,
                                          default=4326)
        self.epsg= self.addLiteralInput(identifier="epsg",
                                           title="EPSG code",
                                           type=types.IntType,
                                          default=4326)
        # OUTPUTS
        self.result = self.addLiteralOutput(identifier="result",
                                          title="result",
                                          type=types.StringType,
                                          default = 'No conditions information available.')
        self.plot = self.addLiteralOutput(identifier="plot",
                                  title="Plot HTML",
                                  type=types.StringType,
                                  default = 'No contect information available.')

    def inputs_test(self, point_wkt, crs_int):
        logging.info(''.join(['wktpoint ', point_wkt]))
        logging.info(''.join(['crs     ','epsg: {}'.format(crs_int)]))  
        try:
        	wkt.loads(point_wkt)
        except:        	
        	return False # Not a valid geom, could be attack/sqlinjection    	
    	return True # Valid WKT

    def execute(self):

    	# Check inputs          
        input_ok = self.inputs_test(self.point.getValue(), self.crs.getValue())
        if not(input_ok):
        	errinput = '{ msg: Please provide a valid wkt geometry }'
        	self.result.setValue(errinput)
        	self.plot.setValue(errinput)
        	return

        # Plot slope, veget, waterlev, surge, output_html                
        random_fname = 'fast_exp_' + ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(8)) +'.html'
        temp_file = os.path.join(self.tmp_dir, random_fname) 
        temp_file_summ = temp_file.replace('fast_exp_', 'fast_exp_summary_')        
        plot = dict()        
        plot['url'] = self.host_url + os.path.basename(temp_file) 
        plot['url_summary'] = self.host_url + os.path.basename(temp_file_summ) 
        
        if DEBUG: 
            logging.info(plot['url'])
            logging.info(plot['url_summary'])
        
        # EXPERT TRANSECT
        res = getOGCdata.misafexpert(self.point.getValue(),self.crs.getValue())
        if res != False:
            res['status'] = 'expert'
            if not('msg' in res):
                bp = bokeh_fast_plot(True, res['bedlevel_xbeach'], res['vegpresence_xbeach'], res['waterlevel'], res['hrms'], temp_file, temp_file_summ, surge_noveg=res['hrms_noveg'], xaxis=res['xaxis_xbeach'], plotX0=res['plotx0'], plotXN=res['plotxend'])            
                bp.plot()
                bp.plot_summary()
                 
        # EDUCATIONAL TRANSECT (not found)
        else:
            res = dict()
            err_msg3 = 'The calculation resulted in a negative slope. This is due to unaccurate bathymetry data.'
            err_msg2 = 'The service is temporarily unavailable. Please try again later'
            err_msg1 = 'Unable to build transect, please click closer to the shore, on the water side'
            err_msg = 'You have selected a land location (or land bound lake, lagoon, bay) according to the coastline and land polygons databases. Insufficient data is available for the selected location, please select waterside-location close to a coastline. Switch-on global map layer ’Land polygons (OSM)’ and ‘Coast lines’ in Data tab Global Base Maps to find out more.'
            
            try:
                context, confidence, convals, conditions, transect, errcode = getOGCdata.misafeeducational(self.point.getValue(),self.crs.getValue())
                res['status'] = errcode
                if context == [] or confidence == [] or convals == [] or conditions == [] or transect == []:
                    if errcode == 'landclick_err':
                        res['msg'] = err_msg
                        plot['msg'] = err_msg                        
                    elif errcode == 'negative_slope':
                        res['msg'] = err_msg3
                        plot['msg'] = err_msg3                        
                    else:
                        res['msg'] = err_msg1
                        plot['msg'] = err_msg1                                               
                else:  
                    # Adapt result from educational to expert              
                    res = getOGCdata.edu2expResult(context, confidence, convals, conditions, transect)
                    logging.info("""beginforeshore = '{val}'""".format(val=res['beginforeshore']))
                    logging.info("""endforeshore = '{val}'""".format(val=res['endforeshore']))
                    bp = bokeh_fast_plot(False, conditions['profile'], conditions['vegetation'], res['waterlevel'], res['hs_nearshore'], temp_file, temp_file_summ, wave_levee=res['hs_levee_bare'], wave_levee_veg=res['hs_levee'], plotX0=res['plotx0'], plotXN=res['plotxend'], begX=res['beginforeshore'], endX=res['endforeshore'], imask=conditions['intertidalmask']) # educational plot
                    bp.plot()
                    bp.plot_summary()
                    res['status'] = 'educational'   
            except Exception as e:
                res['msg'] = err_msg2
                plot['msg'] = err_msg2
                res['status'] = 'error'
                logging.error(e)

        if DEBUG: logging.info(res)
        logging.info('RESULT: '+ str(res['status']))
        logging.info("-----------------------------------------------------------------------------------")

        # Return
        self.result.setValue(json.dumps(res))
        self.plot.setValue(plot)
        
        return        
        
def metadata():
  """
    Wave return Period in years (e.g. 1:1 1:10 1:100 etc.) 
    Wave height incoming H0 in meters
    Wave Height at end of foreshore Heb in meters
    Wave Height at end of vegetated foreshore Hey in meters
    Surge Level in meters
    Width foreshore in meters 
    Slope foreshore in meters ( e.g. 1:10, 1:100, 1:1000 etc.)
    Vegetation type e.g. Mangrove, inland marsh etc.
  """

if __name__ == "__main__":
    p = Process()
    p.execute()
