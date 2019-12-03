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
from bokeh_plots import *
from coords import *
from utils import *
from utils_geoserver import *
from utils_thresholds import *

# Scenarios/Variables file
schema = 'mmf'
scenarios, divisions, variables, epsg, sld_style, thr_map = readNaming(schema)

class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="getmmftrends",
                            title="MSFD/MMF results explorer [trends/time-series]",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Inspect and compare model results from JRC's model MMF. Generate time-series and analyse trends.""",
                            grassLocation=False)

        self.division = self.addLiteralInput(identifier="b-division",
                                            title="Geographical scale",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=sorted(divisions.keys())) 

        self.variable = self.addLiteralInput(identifier="c-variable",
                                            title="Parameters",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=sorted(variables.keys()),
                                            default="[*thr] total chlorophyll [mgchla/m**3]")

        self.outputtype = self.addLiteralInput(identifier="d-outputtype",
                                            title="Output type",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=['Model results', 'Indexation by thresholds'],
                                            default='Model results')

        self.t0 = self.addLiteralInput(identifier="e-t0",
                                            title="Start date [year-month]",
                                            abstract="input=dateTime",
                                            type=type(""),
                                            default='1990-02')

        self.t1 = self.addLiteralInput(identifier="f-t1",
                                            title="End date [year-month]",
                                            abstract="input=date",
                                            type=type(""),
                                            default='2018-01')        

        self.location = self.addLiteralInput(identifier="g-location",
                                             title="Please select a location and click Execute",
                                             abstract="input=mapselection",
                                             type=type(""),
                                             uoms=["point"])

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
        PLOTS_DIR = cf.get('Bokeh', 'plots_dir')
        APACHE_DIR = cf.get('Bokeh', 'apache_dir')

        # Outputs prepare
        outdata = StringIO.StringIO()
        values = {}

        # Inputs check
        exportxls = (self.exportxls.getValue() == 'Yes')
        [division, division_id] = divisions[self.division.getValue()]
        varnamestr = self.variable.getValue()
        variable = variables[varnamestr]
        scenario = 'AllBAU19902017'
        seltable = '''{}_{}_{}_{}'''.format(division, scenario, 'mmf', variable)
        output_type = self.outputtype.getValue()
        t0 = self.t0.getValue()
        t1 = self.t1.getValue()        
        logging.info('''INPUT [getmmftrend]: table={}'''.format(seltable))
           
        # Step 1 - Get closest geometry and its threshold
        try:
            location_info = json.loads(self.location.getValue())
            (xin,yin) = location_info['x'], location_info['y']
            (x,y) = change_coords(xin, yin, epsgin='epsg:3857', epsgout='epsg:{}'.format(epsg)) 
            logging.info('''INPUT [getlisfloodtrend]: x={}, y={}'''.format(x, y))
            idfound, wktfound = getClosestDivision(cf, x, y, division, division_id, epsg)             
        except:            
            values['error_html'] = 'Please select a location on the map in order to perform the analysis. This can be achieved via the \'Select on Map\' button'
            json_str = json.dumps(values)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return
          
        # Step 2 - Threshold and timeseries selection [depends on output type]
        df_thr = None

        if 'threshold' in output_type:
            if variable in thr_map:                
                df_thr = getThresholds(cf, variable, division, division_id, thr_map[variable]) 
                logging.info('INFO: Thresholds loaded for {} - {}'.format(variable, thr_map[variable]))
            else:                
                values['error_html'] = 'Threshold values not available for the selected variable'
                json_str = json.dumps(values)
                outdata.write(json_str)
                self.json.setValue(outdata)
                return  
                
        # Step 0 - Get all time series   
        time, data = getTimeSeries(idfound, cf, df_thr, seltable, variable, division, division_id, schema, t0, t1, output_type) 

        # Step 2 - generate tseries plot
        tmpfile = TempFile(PLOTS_DIR)
        plot_Tseries_Multi(idfound, data, time, variable, tmpfile, idfound, output_type)

        # Step 3 - generate csv if needed
        if exportxls:            
            basename = '{}_{}_{}_tseries.xlsx'.format(idfound, scenario, dt.datetime.now().strftime('%Y-%m-%d_%H-%M-%S'))
            fullpath = os.path.join(cf.get('Bokeh','plots_dir'), basename)
            writer = pd.ExcelWriter(fullpath)  
            df = pd.DataFrame({'time': time, 'value': data[idfound]})
            df.to_excel(writer, 'Time-series {}'.format(idfound))
            writer.save()
            values['url_data'] = cf.get('Bokeh', 'apache_dir') + basename

        # Setup outputs        
        values['url_plot'] = APACHE_DIR + os.path.basename(tmpfile)
        values['plot_xsize'] = 820
        values['plot_ysize'] = 420
        values['title'] = 'MMF time-series'  
        values['wktenvelope'] = wktfound  
        values['wmslayer'] = 'DIVISION:{}'.format(division)

        # Send back JSON
        json_str = json.dumps(values)
        #logging.info('''OUTPUT [getmmftrend]: {}'''.format(json_str))
        outdata.write(json_str)
        self.json.setValue(outdata)

        return
