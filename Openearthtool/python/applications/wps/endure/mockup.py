# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2019 Deltares
#       Joan Sala, Gerrit Hendriksen
#
#       joan.salacalero@deltares.nl, gerrit.hendriksen@deltares.nl
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
#
# This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
# OpenEarthTools is an online collaboration to share and manage data and
# programming tools in an open source, version controlled environment.
# Sign up to recieve regular updates of this function, and to contribute
# your own tools.

# $Id: 3dDEM.py 14134 2018-01-31 07:01:10Z sala $
# $Date: 2018-01-31 08:01:10 +0100 (Wed, 31 Jan 2018) $
# $Author: sala $
# $Revision: 14134 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/endure/3dDEM.py $
# $Keywords: $

# core
import os
import operator
import logging
import ConfigParser
import time as tt

# modules
import types
import simplejson as json
import StringIO
from pywps.Process import WPSProcess

from utils import *

"""
This is a redesigned WPS for the endure application
"""

# Default config file (relative path)
CONFIG_FILE=os.path.join(os.path.dirname(os.path.realpath(__file__)), 'config.txt')

class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="mockup",
                            title="Sea level rise effects",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Select one of the study areas. Fill in the scenario parameters and click on a transect.
                                        Please read the tab SCIENCE in the info section of this website. This informative page gives more information on the science behind the tools.
                                        NOTE! This tool shows effects for 2 dune profiles in the Ducth Part, please press the shortcut key NL - Bergen aan Zee in upper left corner of the map canvas.""",
                            grassLocation=False)

        # Inputs
        self.location = self.addLiteralInput(identifier="location",
                                              title="Select a location and press execute",
                                              abstract="input=mapselection",
                                              type=type(""),
                                              uoms=["point"])

        self.sealevelrise = self.addLiteralInput(identifier="sealevelrise",
                                            title="Sea level rise [meters]",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=['1 meter', '2 meters'],
                                            default='1 meter')

        self.returnperiod = self.addLiteralInput(identifier="returnperiod",
                                            title="Return period [1/years]",
                                            abstract="input=dropdownmenu",
                                            type=type(""),
                                            allowedValues=['100 years', '1000 years'],
                                            default='100 years')

        # Outputs
        self.json = self.addComplexOutput(identifier="json",
                                          title="Returns list of values for specified xy",
                                          abstract="""Returns list of values for specified xy""",
                                          formats=[{"mimeType": "text/plain"},  # 1st is default
                                                   {'mimeType': "application/json"}]) 

    def execute(self):
        # Read configuration file
        PLOTS_DIR, APACHE_DIR, ENGINE = readConfig(CONFIG_FILE)

        # Outputs prepare
        outdata = StringIO.StringIO()
        values = {}
        data_error = False  
        
        try:
            # Inputs check
            returnp = self.returnperiod.getValue().split(' ')[0]
            sealevel = self.sealevelrise.getValue().split(' ')[0]
            location_info = json.loads(self.location.getValue())
            (xin,yin) = location_info['x'], location_info['y']
            
            # convert coordinates to latlon
            logging.info('''Input Coordinates {} {} in epsg={}'''.format(xin,yin,'3857'))             
            (lon,lat) = change_coords(xin, yin, epsgin='epsg:3857', epsgout='epsg:4326')

            # Select transect [closest] 
            fields = 'transect,scenario,SLR,RP,regime,description,lon1,lon2,lat1,lat2,bruun,dhigh,dlow,beachslope,accomodation,SSL,Hs,Tp,regimepngname_current,resultpngname_current,regimepngname_SLR,resultpngname_SLR,wavepngname,desc_regime_slr' 
            table = 'endure_transects'  
            where = 'slr = \'{slr}\' and rp = \'{rp}\''.format(slr=sealevel, rp=returnp)
            logging.info('INFO: where statement {}'.format(where))
            transect, scenario, SLR, RP, regime,description, lon1, lon2, lat1, lat2, bruun, dhigh, dlow, beachslope, accomodation, SSL, Hs, Tp, regimepngname_current, resultpngname_current,regimepngname_SLR, resultpngname_SLR, wavepngname, desc_regime_slr, distclick = queryPostGISClosestPoint(ENGINE, lon, lat, fields, table, where)
            logging.info('INFO: selected transect with id={}'.format(transect))

            # Generate html
            fname = str(tt.time()).replace('.','')+'.html'
            temp_html = os.path.join(PLOTS_DIR, fname)
            generateHtml(temp_html, regimepngname_current, resultpngname_current, regimepngname_SLR, resultpngname_SLR, wavepngname, description, SSL, beachslope, bruun, dhigh, Hs, Tp,desc_regime_slr)   
        except:
            data_error = True
            pass

        # Output prepare
        values = {}
        if data_error:
            values['error_html'] = "<p>Please click on the Select on map button to specify the location.</p>"
        else:                
            values['url_plot'] = APACHE_DIR + fname
            values['plot_xsize'] = 700
            values['plot_ysize'] = 500
            values['title'] = 'Selected scenario: Sea level rise of {} and a return period of {}'.format(self.sealevelrise.getValue(), self.returnperiod.getValue())
            values['wkt_linestr'] = 'LINESTRING ({x0} {y0}, {x1} {y1})'.format(x0=lon1, x1=lon2, y0=lat1, y1=lat2)

        json_str = json.dumps(values)
        outdata.write(json_str)
        self.json.setValue(outdata)       

        return

