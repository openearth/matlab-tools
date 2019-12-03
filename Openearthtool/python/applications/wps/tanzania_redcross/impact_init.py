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
from fast_plots import bokeh_fast_plot

# utils functions
from impact_query_utils import *

DEBUG = False # uncomment to debug

class Process(WPSProcess):
    def __init__(self):
        WPSProcess.__init__(self,
            identifier = "impact_init", # must be same, as filename
            title="Impact Query WPS",
            version = "0.1",
            storeSupported = "true",
            statusSupported = "true",
            abstract="Returns json dump of values of the performed query.")


        self.outjson = self.addComplexOutput(identifier="outjson",
                                          title="Output result in JSON format",
                                          abstract="""Query results returned per row""",
                                          formats=[{"mimeType": "text/plain"},  # 1st is default
                                                   {'mimeType': "application/json"}])

    ## ++++++++++++++++++++++++++++++++++++++++ ##
    ## ================= MAIN ================= ##
    ## ++++++++++++++++++++++++++++++++++++++++ ##
    def execute(self):
        
        exe_dir = os.path.dirname(os.path.realpath(__file__))
        conf_file = os.path.join(exe_dir, './IMPACT_DB/impact_init.json')  
        with open(conf_file) as json_data:
            values = json.load(json_data)

        # Output finalize        
        logging.info('OUTPUTS [impact_init]: {}'.format(values))   
        json_output = StringIO.StringIO()
        json_str = json.dumps(values)
        json_output.write(json_str)
        self.outjson.setValue(json_output) 

        return        
    
