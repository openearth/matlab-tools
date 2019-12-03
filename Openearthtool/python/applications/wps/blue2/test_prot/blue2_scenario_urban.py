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
from scenario_generation.Main import *
from scenario_generation.functions import *

# Scenarios file
naming = {}
schema = 'urban'
with open(os.path.join(os.path.dirname(os.path.realpath(__file__)), 'blue2_naming.json')) as f:
    data = json.load(f)
    translation = data[schema]

class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="blue2_scenario_urban",
                            title="Urban water savings scenario generation",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Please choose an urban water scenario to be generated. Specify at which spatial scale and the type of analysis. Click on Execute to proceed.""",
                            grassLocation=False)

        self.typescenario = self.addLiteralInput(identifier="typescenario",
                                            title="Urban Water Savings",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=['BAU', '+10%', '+25%', '+50%', '+75%', 'MTFR'],
                                            default='+50%')    

        self.spatialscale = self.addLiteralInput(identifier="spatialscale",
                                            title="Spatial scale",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=['NUTS2', 'NUTS0'])

        self.previewtype = self.addLiteralInput(identifier="previewtype",
                                            title="Select type of analysis",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=['Urban water savings investment distribution [eur]', 
                                            'Urban water savings performance improvement [%]',
                                            'Total urban water abstraction efficiency [%]',
                                            'Estimated population equivalent improvement [Residents]'])


        self.json = self.addComplexOutput(identifier="json",
                                          title="Returns list of values for specified xy",
                                          abstract="""Returns list of values for specified xy""",
                                          formats=[{"mimeType": "text/plain"},  # 1st is default
                                                   {'mimeType': "application/json"}]) 
 
    def execute(self):
        # Read config
        cf = readConfig()

        # DB connections
        postgres_db = {'drivername': 'Blue2',
           'database': cf.get('PostGIS', 'db_generation'),
           'username': cf.get('PostGIS', 'user'),
           'password': cf.get('PostGIS', 'pass'),
           'host': cf.get('PostGIS', 'host'),
           'port': cf.get('PostGIS', 'port')
        }
        engine = create_engine('postgresql+psycopg2://'+cf.get('PostGIS', 'user')
            +':'+cf.get('PostGIS', 'pass')+'@'+cf.get('PostGIS', 'host')+':'+str(cf.get('PostGIS', 'port'))
            +'/'+cf.get('PostGIS', 'db_generation'), strategy='threadlocal')        

        # Outputs prepare
        outdata = StringIO.StringIO()
        values = {}

        # Inputs check
        typescenario = self.typescenario.getValue() 
        spatialscale = 'NUTS0' #self.spatialscale.getValue() 
        previewtype = self.previewtype.getValue()      
        logging.info('''INPUT [blue2_scenario_irrigation]: typescenario={} spatialscale={}'''.format(typescenario, spatialscale))

        # Call Ramboll script
        ws_cost, ws_improvement, ws_total_efficiency, ws_pop_eq, results = ws_savings_urban_ms(postgres_db, typescenario, spatialscale)
        column = translation[previewtype]
        rawdata = results[column]
        
        # Write to database
        tablename = column+'_'+str(int(time.time()))
        logging.info('''OUTPUT [blue2_scenario_irrigation]: tablename={}'''.format(tablename))
        res=SendToDatabase(rawdata, tablename, 'tempresults', column)
           
        # Add geometry column [fixed member states]
        updateGeometries(engine, tablename, 'nuts_rg_01m_2013_3035_levl_0', 'nuts_id', tableId='nuts_0', geomschema='public')

        # Add geoserver postgis layer
        wmslayer = geoserverTempLayer(cf, tablename, 'tempresults_{}'.format(column), 3035, store='tmpstore_gen')
        values = {}
        values['wmslayer'] = wmslayer
                
        # Save CSV
        basename = 'export_{}.csv'.format(tablename)
        fullpath = os.path.join(cf.get('Bokeh','plots_dir'), basename)
        results.to_csv(fullpath, sep=';')
        values['url_data'] = cf.get('Bokeh', 'apache_dir') + basename

        # Send back JSON
        json_str = json.dumps(values, use_decimal=True)
        logging.info('''OUTPUT [blue2_scenario_irrigation]: {}'''.format(json_str))
        outdata.write(json_str)
        self.json.setValue(outdata)

        return
