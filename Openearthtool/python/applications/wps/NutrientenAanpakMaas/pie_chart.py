# -*- coding: utf-8 -*-
"""
Created on Fri Feb 01 17:31:17 2019

@author: Lilia Angelova 
"""

# core
import os
import operator
import math
import tempfile
import logging
import ConfigParser
import time

# modules
import types
import simplejson as json
import StringIO
from pywps.Process import WPSProcess

  #Self libraries
from pie_chart_plot import *
from utils import *

"""
This is a redesigned WPS for the NutrientenAanpakMaas application
"""

class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="pie_chart",
                            title="Taartdiagram",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Maak een taartdiagram van de bronnenverdeling van N en P. Selecteer eerst een vanggebied van een KRW-lichaam.""",
                            grassLocation=False)

        self.location = self.addLiteralInput(identifier="location",
                                              title="Please select a location and click Execute",
                                              abstract="input=mapselection",
                                              type=type(""),
                                              uoms=["point"])


        self.json = self.addComplexOutput(identifier="json",
                                          title="Returns list of values for specified xy",
                                          abstract="""Returns list of values for specified xy""",
                                          formats=[{"mimeType": "text/plain"},  # 1st is default
                                                   {'mimeType': "application/json"}]) 

    # Execute wps service to get tseries
    def execute(self):
        # Outputs prepare
        outdata = StringIO.StringIO()
        values = {}

        # Read config
        PLOTS_DIR, APACHE_DIR = readConfig()

        # Inputs check
        location = self.location.getValue()    

        # Error messaging
        okparams, msg, x, y = check_location(location)
        if not(okparams):            
            logging.info(msg)            
            values['error_html'] = msg
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return

        # change to epsg of database        
        (xk,yk) = change_coords(x, y, epsgin='epsg:3857', epsgout='epsg:28992')
          
        #color palletes based on colorbrewer        
        color_dict = {"act_bem":"#8dd3c7", "afw_ov":"#ffffb3", "antrop":"#bebada", "buitenl":"#fb8072", "dep_op":"#80b1d3", "his_bem":"#fdb462", "landb_bovens":"#b3de69",
        "landb_ov": "#fccde5", "nat_bovens":"#c0bb8f", "nlev_bod":"#bc80bd", "overst":"#ccebc5", "rijkswat":"#ffed6f", "rwzi_afw":"#F1DBB9", "rwzi":"#24b5a1",
        "ua_kwel":"#7591b0", "ua_nat":"#d090a9" , "combin": "#D3D3D3"}
        
        #database queries (gid should come from the wps depending on the user selection)
        n_query = "SELECT * FROM wur.data_zomer_n where ST_Within(ST_PointFromText('POINT({} {})','{}'), geom)".format(xk, yk, 28992) 
        p_query = "SELECT * FROM wur.data_zomer_p where ST_Within(ST_PointFromText('POINT({} {})','{}'), geom)".format(xk, yk, 28992)
        name_query =  "SELECT aquarein_p FROM wur.data_zomer_p where ST_Within(ST_PointFromText('POINT({} {})','{}'), geom)".format(xk, yk, 28992)
            
        #sql    
        cf = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'pgconnection.txt')            
        engine = sql_engine(cf) 
        

        try:            
            #Nitrogen
            n_data = engine.execute(n_query)
            name_plot = engine.execute(name_query).fetchone()
            nitrogen = Pie_plot("Stikstof", "n", n_data, engine, color_dict) 
            p_n = nitrogen.plot()
            
            #Phosphorus 
            p_data = engine.execute(p_query)
            nitrogen = Pie_plot("Fosfor", "p", p_data, engine, color_dict) 
            p_p = nitrogen.plot()
           
            # #combine both plots in one layout
            p = row(p_n,p_p)
            tmpfile = getTempFile(PLOTS_DIR)
            output_file(tmpfile)
            save(p)
            
        except:
            values['error_html'] = 'Geen gegevens beschikbaar voor deze locatie.'
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return    
            
              
        # Send back result JSON
        values['url_plot'] = APACHE_DIR + os.path.basename(tmpfile)
        values['plot_xsize'] = 1020
        values['plot_ysize'] = 500
        values['title'] = "Bronnenverdeling " + str(name_plot)[3:-3]
        json_str = json.dumps(values)
        outdata.write(json_str)
        self.json.setValue(outdata)  
        return 
