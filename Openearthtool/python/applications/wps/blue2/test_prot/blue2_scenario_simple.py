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
from pywps.Process import WPSProcess

# Relative
from coords import *
from utils import *
from utils_geoserver import *

# Scenario generation
from scenario_generation.Main import ws_savings_irrig_n2
from scenario_generation.functions import *

"""
This is a redesigned WPS for the Blue2 application

if it runs on localhost then:
getcapabilities:  http://localhost/cgi-bin/pywps.cgi?request=GetCapabilities&service=wps&version=1.0.0
describe process: http://localhost/cgi-bin/pywps.cgi?request=DescribeProcess&service=wps&version=1.0.0&identifier=info_nhiflux
execute:          http://localhost/cgi-bin/pywps.cgi?&service=wps&request=Execute&version=1.0.0&identifier=info_nhiflux&datainputs=[geom={%20%22type%22:%20%22FeatureCollection%22,%20%22features%22:%20[%20{%20%22type%22:%20%22Feature%22,%20%22properties%22:%20{},%20%22geometry%22:%20{%20%22type%22:%20%22Point%22,%20%22coordinates%22:%20[%204.3689751625061035,%2052.01105825338195%20]%20}%20}%20]%20}]
"""

class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="blue2_scenario_simple",
                            title="Blue2 scenario generation",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Generate a new scenario and a preview""",
                            grassLocation=False)

        self.typescenario = self.addLiteralInput(identifier="typescenario",
                                            title="Select a scenario type",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=['BAU', '+10%', '+25%', '+50%', '+75%', 'MTFR'],
                                            default='+50%') 

        self.spatialscale = self.addLiteralInput(identifier="spatialscale",
                                            title="Select a spatial scale",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=['Waterbody', 'NUTS2'],
                                            default='NUTS2')

        self.previewtype = self.addLiteralInput(identifier="previewtype",
                                            title="Select a preview type",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=['cost analysis', 'performance improvement'],
                                            default='cost analysis')


        self.json = self.addComplexOutput(identifier="json",
                                          title="Returns list of values for specified xy",
                                          abstract="""Returns list of values for specified xy""",
                                          formats=[{"mimeType": "text/plain"},  # 1st is default
                                                   {'mimeType': "application/json"}]) 
 
    def execute(self):
        # Read config
        cf = readConfig()

        # DB connections
        engine = create_engine('postgresql+psycopg2://'+cf.get('PostGIS', 'user')
            +':'+cf.get('PostGIS', 'pass')+'@'+cf.get('PostGIS', 'host')+':'+str(cf.get('PostGIS', 'port'))
            +'/'+cf.get('PostGIS', 'db_generation'), strategy='threadlocal')
        engine_temp = create_engine('postgresql+psycopg2://'+cf.get('PostGIS', 'user')
            +':'+cf.get('PostGIS', 'pass')+'@'+cf.get('PostGIS', 'host')+':'+str(cf.get('PostGIS', 'port'))
            +'/'+cf.get('PostGIS', 'db_temp'), strategy='threadlocal')

        # Outputs prepare
        outdata = StringIO.StringIO()
        values = {}

        # Inputs check
        typescenario = self.typescenario.getValue() 
        spatialscale = self.spatialscale.getValue() 
        previewtype = self.previewtype.getValue()
      
        logging.info('''INPUT [blue2_scenario_simple]: typescenario={} spatialscale={}'''.format(typescenario, spatialscale))

        # Call Ramboll script
        cost, improvement = ws_savings_irrig_n2(engine, typescenario)

        # Just for naming
        try:
            typescenario_str = re.findall(r'\d+', typescenario)[0]
        except:
            typescenario_str = typescenario

        # Upload new layer to GeoServer        
        if previewtype == 'cost analysis':
            tmptable='cost_{}_{}'.format(typescenario_str, spatialscale)   
            sld_style = 'tempresults_cost'         
            res=SendToDatabase(engine_temp, cost, tmptable, 'tempresults', 'cost')
            logging.info('Generating cost analysis map on {}'.format(tmptable))            
        else:
            tmptable='perf_{}_{}'.format(typescenario_str, spatialscale) 
            sld_style = 'tempresults_perf'
            res=SendToDatabase(engine_temp, improvement, tmptable, 'tempresults', 'improv')
            logging.info('Generating performance improvement map on {}'.format(tmptable))

        if res != -1:
            # Add geometry column
            updateGeometries(engine_temp, tmptable, 'nuts2', 'nuts_id', tableId='is_n2_nuts2')

        # Add geoserver postgis layer
        wmslayer = geoserverTempLayer(cf, tmptable, sld_style, 3035)
           
        # Setup outputs
        values = {}
        values['wmslayer'] = wmslayer
                
        # Send back JSON
        json_str = json.dumps(values, use_decimal=True)
        logging.info('''OUTPUT [blue2_scenario_simple]: {}'''.format(json_str))
        outdata.write(json_str)
        self.json.setValue(outdata)

        return
