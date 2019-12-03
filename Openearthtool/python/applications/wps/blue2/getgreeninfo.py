# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares
#       Joan Sala
#
#       joan.salacalero@deltares.nl
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

# core
import os
import operator
import math
import tempfile
import logging
import ConfigParser
import time
import datetime as dt

# modules
import types
import simplejson as json
import StringIO
from pywps.Process import WPSProcess

# Relative
from coords import *
from utils import *
from utils_thresholds import *
from utils_geoserver import *

# Scenarios/Variables file
schema = 'green'
scenarios, divisions, variables, epsg, sld_style, thr_map = readNaming(schema)

class Process(WPSProcess):
    def __init__(self):
        
        WPSProcess.__init__(self,
                            identifier="getgreeninfo",
                            title="WFD/GREEN results explorer [maps/tables]",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Inspect model results from JRC's model GREEN. Generate maps and tables from the available data.""",
                            grassLocation=False)

        self.typescenario = self.addLiteralInput(identifier="a-typescenario",
                                            title="Scenario",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=sorted(scenarios.keys()))

        self.division = self.addLiteralInput(identifier="b-division",
                                            title="Geographical scale",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=sorted(divisions.keys()))                                            

        self.variable = self.addLiteralInput(identifier="c-variable",
                                            title="Parameter",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=sorted(variables.keys()))

        self.outputtype = self.addLiteralInput(identifier="f-outputtype",
                                            title="Output type",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=['Model results', 'Indexation by thresholds'],
                                            default='Model results')                                   

        self.exportxls = self.addLiteralInput(identifier="g-exportxls",
                                            title="Export table (Excel xls)",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=['Yes', 'No'],
                                            default='No')

        self.json = self.addComplexOutput(identifier="json",
                                          title="Returns list of values for specified xy",
                                          abstract="""Returns list of values for specified xy""",
                                          formats=[{"mimeType": "text/plain"},  # 1st is default
                                                   {'mimeType': "application/json"}]) 

    # Execute function
    def execute(self):
        # Read config
        cf = readConfig()

        # Outputs prepare
        outdata = StringIO.StringIO()
        values = {}

        # Inputs check
        exportxls = (self.exportxls.getValue() == 'Yes')
        output_type = self.outputtype.getValue()
        [division, division_id] = divisions[self.division.getValue()]
        scenario = scenarios[self.typescenario.getValue()]
        varnamestr = self.variable.getValue()
        variable = variables[varnamestr]
        t0 = None
        t1 = None
        seltable = '''{}_{}_{}_{}'''.format(division, 'green', scenario, variable)
        sld_style = '''{}_{}'''.format(cf.get('GeoServer', 'tmpstore'), variable)
        logging.info('''INPUT [getGREENinfo]: table={}'''.format(seltable))        

        # Threshold selection []
        df_thr = None        
        try: 
            if 'threshold' in output_type:
                if variable in thr_map:                
                    df_thr = getThresholds(cf, variable, division, division_id, thr_map[variable]) 
                    logging.info('INFO: Thresholds loaded for {} - {}'.format(variable, thr_map[variable]))
                else:                
                    raise ValueError('Threshold values not available for the selected variable. Variables with available thresholds are indicated with [*thr]')
                    
            # Step 0 - Get temporary table   
            tmptable, df = calculateLayer(cf, df_thr, seltable, variable, division, division_id, schema, t0, t1, output_type, timeseries=False)
        except Exception as e:            
            values['error_html'] = str(e)
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return        

        # Step 1
        # Add geoserver postgis layer
        if 'thresholds' in output_type:
            sld_style = 'blue2_goodstatus'
        else:                                
            sld_style = geoserverTempStyle(varnamestr, cf, df, variable, tmptable) 

        try:                            
            wmslayer = geoserverTempLayer(cf, tmptable, sld_style, epsg)
        except:                        
            values['error_html'] = 'GeoServer layer upload failed. Please try again'
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return      

        # Step 2 - Write excel file
        if exportxls:
            basename = 'Scenario_{}_{}.xlsx'.format(scenario, dt.datetime.now().strftime('%Y-%m-%d_%H-%M-%S'))
            fullpath = os.path.join(cf.get('Bokeh','plots_dir'), basename)
            writer = pd.ExcelWriter(fullpath)                
            df.to_excel(writer, 'Analyse {}'.format(scenario))
            writer.save()
            values['url_data'] = cf.get('Bokeh', 'apache_dir') + basename

        # Setup outputs        
        values['wmslayer'] = wmslayer                    

        # Send back JSON
        json_str = json.dumps(values)
        #logging.info('''OUTPUT [getGREENinfo]: {}'''.format(json_str))
        outdata.write(json_str)
        self.json.setValue(outdata)

        return
