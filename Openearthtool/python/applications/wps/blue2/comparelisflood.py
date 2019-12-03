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
schema = 'lisflood'
scenarios, divisions, variables, epsg, sld_style, thr_map = readNaming(schema)
timeperiods = readNamingTimeperiods(schema)
sortedscen = sorted(scenarios.keys())

class Process(WPSProcess):
    def __init__(self):
        
        WPSProcess.__init__(self,
                            identifier="comparelisflood",
                            title="WFD/LISFLOOD scenario comparison",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Compare scenario results from JRC's model LISFLOOD per member state. Obtain difference in parameter values, cost effectiveness and relative increments.""",
                            grassLocation=False)

        self.typescenarioref = self.addLiteralInput(identifier="aa-typescenarioref",
                                            title="Reference scenario",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=sortedscen,
                                            default=sortedscen[1])

        self.typescenariosec = self.addLiteralInput(identifier="ab-typescenariosec",
                                            title="Second scenario",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=sortedscen,
                                            default=sortedscen[2])

        self.variable = self.addLiteralInput(identifier="c-variable",
                                            title="Parameter",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=sorted(variables.keys()),
                                            default='[*thr] Wei Cns')  # The only one with a threshold available


        self.timeperiod = self.addLiteralInput(identifier="d-timeperiod",
                                            title="Timespan selection [begin-end]",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=sorted(timeperiods.keys()),
                                            default=sorted(timeperiods.keys())[0])
                  
        self.previewtype = self.addLiteralInput(identifier="g-previewtype",
                                            title="Preview type",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=['Difference [parameter]', 'Relative increment [%]', 'Cost effectiveness [eur]'],
                                            default='Difference [parameter]')

        self.exportxls = self.addLiteralInput(identifier="h-exportxls",
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
        #[division, division_id] = divisions[self.division.getValue()]
        division, division_id = "nuts0", "nuts_id" # Fixed
        scenario1 = scenarios[self.typescenarioref.getValue()]
        scenario2 = scenarios[self.typescenariosec.getValue()]
        variable = variables[self.variable.getValue()]
        timep = timeperiods[self.timeperiod.getValue()]
        t0 = timep[0]
        t1 = timep[1]
        previewtype = self.previewtype.getValue()
        seltable1 = '''{}_{}_{}_{}'''.format(division, 'LISFLOOD', scenario1, variable)
        seltable2 = '''{}_{}_{}_{}'''.format(division, 'LISFLOOD', scenario2, variable)        
        logging.info('''INPUT [comparelisflood]: table1={}'''.format(seltable1))
        logging.info('''INPUT [comparelisflood]: table2={}'''.format(seltable2))        

        # Decide column name
        if 'Difference' in previewtype:
            colname = 'parameter_difference'
        elif 'Cost' in previewtype:
            colname = 'cost_effectiveness'            
        else:
            colname = 'relative_increment'

        # Decide costs [to be defined yet]
        c1 = 'cost_mtf'
        if 'BAU' in scenario1: c1 = 'cost_bau'
        c2 = 'cost_mtf'
        if 'BAU' in scenario2: c2 = 'cost_bau'

        # Threshold selection 
        df_thr = None
        try:        
            # Step 0 - Get temporary table [scenario calculations]
            tmptable1, df1 = calculateLayer(cf, df_thr, seltable1, variable, division, division_id, schema, t0, t1, 'results')
            tmptable2, df2 = calculateLayer(cf, df_thr, seltable2, variable, division, division_id, schema, t0, t1, 'results')      
        except:            
            values['error_html'] = 'The current selection did not return any result. Please check that there is data on both scenarios for the given time period'
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return        

        logging.info(df1)
        logging.info(' -------------------- ')
        logging.info(df2)

        # Step 1 - Compute difference        
        tmptable, df = compareScenarios(cf, df1, df2, previewtype, division, division_id, c1, c2)

        # Step 2 - Write excel file
        if exportxls:
            basename = 'Scenario_Comparison_{}.xlsx'.format(dt.datetime.now().strftime('%Y-%m-%d_%H-%M-%S'))
            fullpath = os.path.join(cf.get('Bokeh','plots_dir'), basename)
            writer = pd.ExcelWriter(fullpath)                
            df.to_excel(writer, 'Comparison')
            writer.save()
            values['url_data'] = cf.get('Bokeh', 'apache_dir') + basename

        # Step 3 - Add geoserver postgis layer
        try:         
            sld_style = geoserverTempStyle(previewtype, cf, df, colname, tmptable)                             
            wmslayer = geoserverTempLayer(cf, tmptable, sld_style, epsg)
        except:                        
            values['error_html'] = 'GeoServer layer upload failed. Please try again'
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return      

        # Setup outputs        
        values['wmslayer'] = wmslayer                  

        # Send back JSON
        json_str = json.dumps(values)
        logging.info('''OUTPUT [comparelisflood]: {}'''.format(json_str))
        outdata.write(json_str)
        self.json.setValue(outdata)

        return
