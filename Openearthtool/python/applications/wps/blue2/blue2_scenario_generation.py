# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
#       Gerrit Hendriksen, Joan Sala
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
import types
import simplejson as json
import StringIO
import re
import datetime as dt
from pywps.Process import WPSProcess
from openpyxl import load_workbook

# Relative
from coords import *
from utils import *
from utils_geoserver import *

# Scenario generation
from scenario_generation.Main import *
from scenario_generation.functions import *

# Scenarios file
templatefname = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'Scenario_Generation_template.xlsx')
with open(os.path.join(os.path.dirname(os.path.realpath(__file__)), 'blue2_naming.json')) as f:
    data = json.load(f)
    translation = data['scenario_generation']

class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="blue2_scenario_generation",
                            title="Main function to generate Blue2 scenarios",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Select a combination of modes [urban, waste, irrigation, cso]""",
                            grassLocation=False)

        self.inputJson = self.addLiteralInput(identifier="inputJson",
                                            title="Configuration for the scenario generation",
                                            abstract="JSON based configuration",
                                            type=type("")) 

        self.json = self.addComplexOutput(identifier="json",
                                          title="Returns list of values for specified xy",
                                          abstract="""Returns list of values for specified xy""",
                                          formats=[{"mimeType": "text/plain"},  # 1st is default
                                                   {'mimeType': "application/json"}]) 
 
    def execute(self):
        # Read config
        cf = readConfig()

        # Outputs prepare
        outdata = StringIO.StringIO()
        values = {}

        # Parse JSON
        inputs = json.loads(self.inputJson.getValue())
        logging.info('''INPUT [blue2_scenario_generation]: input={}'''.format(inputs))
        
        # Inputs check
        sel=0
        scale = inputs['spatial'] 
        if 'NUTS2' in scale:
            scale = 'NUTS2'
        else:
            scale = 'NUTS0'
        
        region = inputs['region']
        if region == 'Member States':       
            region = 'EU28'
        
        exportxls = (inputs['exportxls'] == 'Yes')
        previewtype = inputs['preview']                             
        scenarios = inputs['types']

        # Prepare Excel file
        basename = 'Scenario_Generation_{}.xlsx'.format(dt.datetime.now().strftime('%Y-%m-%d_%H-%M-%S'))
        fullpath = os.path.join(cf.get('Bokeh','plots_dir'), basename)
        writer = pd.ExcelWriter(fullpath)    
        writer.book = load_workbook(templatefname)

        # Get selected column
        selcolumn = translation[previewtype]

        # For every type of scenario combination
        values = {}
        errmsg = ''

        # Additional costs check [integer format, empty equals zero]
        costs = {}
        for inp in scenarios:
            if inp['cost'].strip() == '':                
                costs[inp['mode']] = 0
            else:
                try:
                    costs[inp['mode']] = float(inp['cost'])
                except:
                    values = {}
                    values['error_html'] = 'The additional investment must be valid integer value'                    
                    json_str = json.dumps(values)
                    outdata.write(json_str)
                    self.json.setValue(outdata)
                    return  # no need to proceed              

        # Scenarios calculation         
        totFrames = []
        avgFrames = []
        minFrames = []
        maxFrames = []
        for inp in scenarios:
            logging.info('SCENARIO = {}'.format(inp))
            if inp['selected']:                
                sel+=1            
                functionname = inp['mode']
                typescenario = inp['type']            
                costscenario = costs[functionname]

                # Call Ramboll script
                rawdata = None                
                if functionname == 'irrigation':                                       
                    rawdata_nuts2, rawdata_nuts0 = ws_savings_irrig(typescenario, costscenario, scale, region)   
                elif functionname == 'urban':
                    rawdata_nuts0 = ws_savings_urban_ms(typescenario, costscenario, scale, region)             
                    rawdata_nuts2 = rawdata_nuts0
                elif functionname == 'waste':
                    rawdata_nuts2, rawdata_nuts0  = nutient_loads(typescenario, costscenario, scale, region)                 
                elif functionname == 'cso':
                    rawdata_nuts2, rawdata_nuts0  = cso_loadings(typescenario, costscenario, scale, region)                    
                else:
                    errmsg = 'The selected scenario type is not implemented'

                # Write to excel
                if 'NUTS2' in scale:
                    rawdata = rawdata_nuts2 
                else:
                    rawdata = rawdata_nuts0 

                # Write to excel                               
                rawdata.to_excel(writer, functionname)
                
                # Write to database                
                if isinstance(rawdata, pd.DataFrame):
                    # Check if it is the preview table
                    if selcolumn in list(rawdata):
                        # Insert to DB
                        tablename = functionname+'_'+str(int(time.time()))
                        logging.info('''OUTPUT [blue2_scenario_generation]: tablename={}'''.format(tablename))                
                        SendToDatabase(rawdata, tablename, 'tempresults', '')

                        # Add geometry column to selected table [fixed member states]
                        if 'NUTS2' in scale and inp['mode'] != 'urban':
                            logging.info('''INFO: scale={} => updating table={} with index={}'''.format(scale, tablename, rawdata.index.name))
                            updateGeometriesNuts2(tablename, 'tempresults', rawdata.index.name)
                        else:                            
                            logging.info('''INFO: scale={} => updating table={} with index={}'''.format(scale, tablename, rawdata.index.name))
                            updateGeometriesMS(tablename, 'tempresults', rawdata.index.name)

                        # Add geoserver postgis layer
                        sld_style = geoserverTempStyle(previewtype, cf, rawdata, selcolumn, tablename, colortable='purple')                                            
                        wmslayer = geoserverTempLayer(cf, tablename, sld_style, 3035, store='tmpstore_gen')                        
                        logging.info('''OUTPUT [blue2_scenario_generation]: wmslayer={} sld_style={}'''.format(wmslayer, sld_style))
                        values['wmslayer'] = wmslayer    

                # Calculate totals                
                totFrames.append(rawdata.sum(numeric_only=True))
                avgFrames.append(rawdata.mean(numeric_only=True))
                minFrames.append(rawdata.min(numeric_only=True))
                maxFrames.append(rawdata.max(numeric_only=True))

        # Add totals to Excel  
        rawdataTot = pd.DataFrame(columns=['Total', 'Min', 'Max', 'Average'])
        rawdataTot['Total'] = pd.concat(totFrames)        
        rawdataTot['Min'] = pd.concat(minFrames)
        rawdataTot['Max'] = pd.concat(maxFrames)  
        rawdataTot['Average'] = pd.concat(avgFrames)             
        rawdataTot.to_excel(writer, 'Summary')
        
        # Preview not available
        if not('wmslayer' in values):
            errmsg = 'Preview not available for the selected scenario generation parameters'

        # Result file with at least one tab
        if exportxls:
            if sel == 0:
                errmsg = 'You need to select at least one module from the 4 options above'
            else:
                # Save Excel file        
                writer.save()
                values['url_data'] = cf.get('Bokeh', 'apache_dir') + basename

        # Error messaging                
        if errmsg != '':
            values['error_html'] = errmsg                   
            
        # JSON reply
        json_str = json.dumps(values)
        logging.info('''OUTPUT [blue2_scenario_generation]: {}'''.format(json_str))
        outdata.write(json_str)
        self.json.setValue(outdata)              
        return
