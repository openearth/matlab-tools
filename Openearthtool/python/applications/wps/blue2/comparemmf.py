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
        
        WPSProcess.__init__(self,
                            identifier="comparemmf",
                            title="MSFD/MMF scenario comparison",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Compare scenario results from JRC's model MMF per marine region. Obtain difference in parameter values, cost effectiveness and relative increments.""",
                            grassLocation=False)

        self.typescenarioref = self.addLiteralInput(identifier="aa-typescenarioref",
                                            title="Reference scenario",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=scenarios.keys(),
                                            default=scenarios.keys()[0])

        self.typescenariosec = self.addLiteralInput(identifier="ab-typescenariosec",
                                            title="Second scenario",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=scenarios.keys(),
                                            default=scenarios.keys()[1])
        '''
        self.division = self.addLiteralInput(identifier="b-division",
                                            title="Geographical scale",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            default="NUTS level 1 - Member states")
        '''
        self.variable = self.addLiteralInput(identifier="c-variable",
                                            title="Parameter",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=variables.keys())
                                              
        self.t0 = self.addLiteralInput(identifier="d-t0",
                                            title="Start date [year-month]",
                                            abstract="input=dateTime",
                                            type=type(""),
                                            default='1990-01')

        self.t1 = self.addLiteralInput(identifier="e-t1",
                                            title="End date [year-month]",
                                            abstract="input=date",
                                            type=type(""),
                                            default='2018-12')  
                            
        self.previewtype = self.addLiteralInput(identifier="g-previewtype",
                                            title="Preview type",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=['Difference [parameter]', 'Relative increment [%]', 'Cost effectiveness [eur]'],
                                            default='Difference [parameter]')

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
        values['error_html'] = 'Results for this function are not available yet'
        json_str = json.dumps(values)
        outdata.write(json_str)
        self.json.setValue(outdata)

        return
