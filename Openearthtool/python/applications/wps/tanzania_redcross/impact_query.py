# -*- coding: utf-8 -*-
"""
Created on Tuesday Nov  11 13:25:03 2017
@author: Joan Sala
"""

from pywps.Process import WPSProcess
from pywps.Exceptions import *

import StringIO
import random
import string
import json
import os
import logging
import tempfile
import types
import getOGCdata
import pandas as pd

# utils functions
from impact_query_utils import *

DEBUG = False # uncomment to debug

class Process(WPSProcess):
    def __init__(self):       
        WPSProcess.__init__(self,
            identifier = "impact_query", # must be same, as filename
            title="Impact Query WPS",
            version = "0.1",
            storeSupported = "true",
            statusSupported = "true",
            abstract="Returns json dump of values of the performed query.")


        self.indata = self.addComplexInput(identifier = "indata", maxmegabites=20,
                                             title = "Input data values as query in JSON format",
                                             formats = [
                                                 {'mimeType': 'text/plain', 'encoding': 'UTF-8'},                                                 
                                                 {'mimeType': 'application/json'}
                                             ])

        self.outjson = self.addComplexOutput(identifier="outjson",
                                          title="Output result in JSON format",
                                          abstract="""Query results returned per row""",
                                          formats=[{"mimeType": "text/plain"},  # 1st is default
                                                   {'mimeType': "application/json"}])

    ## ++++++++++++++++++++++++++++++++++++++++ ##
    ## ================= MAIN ================= ##
    ## ++++++++++++++++++++++++++++++++++++++++ ##
    def execute(self):
        # Read inputs
        exe_dir = os.path.dirname(os.path.realpath(__file__))
        with open(self.indata.getValue(),'r') as f:
            indata_str = f.read()
            logging.info('INPUTS [impact_query]: {}'.format(indata_str))        
        
        # Parameter control check
        err = False
        errmsg = ''
        indata = None
        values = {}

        # Load defaults from config
        conf_file = os.path.join(exe_dir, './IMPACT_DB/impact_init.json')  
        with open(conf_file) as json_data:
            conf = json.load(json_data)['defaults']     
        
        logging.info(conf)
        rainfall_classes = conf['rainfall_classes']
        wetness_classes = conf['wetness_classes']
        rainfall_name = conf['rainfall_name']
        wetness_name = conf['wetness_name']

        # Required params read
        province = ''
        forecast = ''
        wetness = '' 
        try:
            logging.info('----------')
            logging.info(indata_str)
            logging.info('----------')
            indata = json.loads(indata_str)
            logging.info('----------')
            logging.info(indata)
            logging.info('----------')
            province = indata['province']
            forecast = float(indata['forecast'])
            wetness = float(indata['wetness']) 
        except Exception, e:
            errmsg = str(e)
            logging.error(str(e))
            err = True

        if not(err):
            # let's read our impact table            
            impact_file = os.path.join(exe_dir, './IMPACT_DB/merged_24hr_Rainfall.xlsx')            
            data = read_impact_table(impact_file)

            # Sql file creation not needed now
            #sql_file = os.path.join(exe_dir, './IMPACT_DB/merged_24hr_Rainfall.sqlite')
            #data[province].to_sql(sql_file)      
            
            # let's define our classes
            min_val_rainfall, max_val_rainfall = find_class(forecast, rainfall_classes)
            min_val_wet, max_val_wet = find_class(wetness, wetness_classes)

            # query items that belong to this class
            events = query_table(data,
                                 province,
                                 [rainfall_name, wetness_name],
                                 [min_val_rainfall, min_val_wet],
                                 [max_val_rainfall, max_val_wet])
            
            # convert for the frontend [Matthijs requirements]
            events_conv = self.df2json(events)

            # Output            
            values['outdata'] = events_conv
        else:
            values['errmsg'] = errmsg

        # Output finalize        
        logging.info('OUTPUTS [impact_query]: {}'.format(values))   
        json_output = StringIO.StringIO()
        json_str = json.dumps(values)
        json_output.write(json_str)
        self.outjson.setValue(json_output) 

        return        

    # Convert from pandas to json, specific order for the frontend
    def df2json(self, df):
        res = []
        col_names=list(df)
        for index, row in df.iterrows():
            tmp_res = {}
            start_dt = None
            start_dt_str = ""
            end_dt = None
            end_dt_str = ""
            time_str = ""
            for c in col_names:
                if c == "start":
                    start_dt = row[c]
                    start_dt_str = row[c].date().strftime('%B %d, %Y')
                    tmp_res[c] = start_dt_str
                elif c == "end":
                    end_dt = row[c]
                    end_dt_str = row[c].date().strftime('%B %d, %Y')
                    tmp_res[c] = end_dt_str
                elif c == "time": 
                    time_str = row[c].date().strftime('%B %d, %Y')       
                    tmp_res[c] = time_str
                else:
                    ## The rest, Assign
                    tmp_res[c] = str(row[c])

            # Calculate duration
            duration = end_dt - start_dt
            tmp_res['duration'] = str(duration).split(' ')[0] + ' days'

            # Add title
            tmp_res['title'] = time_str

            # Append result
            res.append(tmp_res)
        return res
