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
schema = 'mmf'
scenarios, divisions, variables, epsg, sld_style, thr_map = readNaming(schema)

class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="getmmfinfo",
                            title="MSFD/MMF results explorer [maps/tables]",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Inspect model results from JRC's model MMF. Generate maps and tables from the available data.""",
                            grassLocation=False)


        self.division = self.addLiteralInput(identifier="b-division",
                                            title="Geographical scale",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=sorted(divisions.keys())) 

        self.variable = self.addLiteralInput(identifier="c-variable",
                                            title="Parameter",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=sorted(variables.keys()),
                                            default="[*thr] total chlorophyll [mgchla/m**3]")

        self.t0 = self.addLiteralInput(identifier="d-t0",
                                            title="Start date",
                                            abstract="input=dateTime",
                                            type=type(""),
                                            default='1990-02')

        self.t1 = self.addLiteralInput(identifier="e-t1",
                                            title="End date",
                                            abstract="input=date",
                                            type=type(""),
                                            default='2018-01')

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
        varnamestr = self.variable.getValue()
        variable = variables[varnamestr]
        t0 = self.t0.getValue()
        t1 = self.t1.getValue()
        scenario = 'AllBAU19902017'
        seltable = '''{}_{}_{}_{}'''.format(division, scenario, 'mmf', variable)
        sld_style = '''{}_{}'''.format(cf.get('GeoServer', 'tmpstore'), variable)

        logging.info('''INPUT [getmmfinfo]: table={}'''.format(seltable))
        logging.info('''INPUT [getmmfinfo]: style={}'''.format(sld_style))

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
            tmptable, df = calculateLayer(cf, df_thr, seltable, variable, division, division_id, schema, t0, t1, output_type)      
        except Exception as e:            
            values['error_html'] = str(e)
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return        
        
        # Step 1
        try:
            # Add geoserver postgis layer
            if 'thresholds' in output_type:
                sld_style = 'blue2_goodstatus'
            else:                                
                sld_style = geoserverTempStyle(varnamestr, cf, df, variable, tmptable)                             
            wmslayer = geoserverTempLayer(cf, tmptable, sld_style, epsg)
        except:                        
            values['error_html'] = 'GeoServer layer upload failed. Please try again'
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return 

        # Step 2 - Write excel file
        if exportxls:
            scenario = 'MSFD'
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
        #logging.info('''OUTPUT [getmmfinfo]: {}'''.format(json_str))
        outdata.write(json_str)
        self.json.setValue(outdata)

        return
