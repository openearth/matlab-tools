# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
#       Gerrit Hendriksen, Joan Sala
#
#       gerrit.hendriksen@deltares.nl, joan.salacalero@deltares.nl
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

# $Id: onttrekking.py 14055 2018-01-02 09:09:35Z sala $
# $Date: 2018-01-02 10:09:35 +0100 (Tue, 02 Jan 2018) $
# $Author: sala $
# $Revision: 14055 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/zeeland/onttrekking.py $
# $Keywords: $

# core
import os
import logging
import types

# modules
import simplejson as json
import StringIO
from pywps.Process import WPSProcess

# relative
from coords import *
from regis import regiswps
from opendap_nhi import find_spreidingslengte
from GeoTop import *

# Classes
from onttrekking_outputs import onttrekking_IO
from onttrekking_config import onttrekking_CONF
from onttrekking_run import onttrekking_RUN
from ahn2 import *

# Default templates (relative path)
CONFIG_FILE=os.path.join(os.path.dirname(os.path.realpath(__file__)), 'ONTconfig.txt')

# WPS process class
class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="onttrekking",
                            title="Onttrekkingsconsult Zeeland",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""De tool onttrekkingsconsult Zeeland berekent de verlaging van de grondwaterstand op een door de gebruiker opgegeven locatie.""",
                            grassLocation=False)
                                      
        # INPUTS [parameters]
        self.Q = self.addLiteralInput(identifier="a",
                                            title="Debiet van de onttrekking [m3/d]",
                                            type=types.FloatType, default=50)

        self.t = self.addLiteralInput(identifier="b",
                                            title="Lengte van de onttrekking [d]",
                                            type=types.FloatType, default=30)

        self.Tf = self.addLiteralInput(identifier="c",
                                            title="Bovenkant van het onttrekkingsfilter ten opzichte van maaiveld [m]",
                                            type=types.IntType, default=5)

        self.Lf = self.addLiteralInput(identifier="d",
                                            title="Lengte van het onttrekkingsfilter [m]",
                                            type=types.IntType, default=15)

        self.Sy = self.addLiteralInput(identifier="e",
                                            title="Freatische bergingscoëfficiënt [-]",
                                            type=types.FloatType, default=0.2)

        self.Ss = self.addLiteralInput(identifier="f",
                                            title="Elastische bergingscoëfficiënt [1/m]",
                                            type=types.FloatType, default=0.0001)

        ## XY user click
        self.location = self.addLiteralInput(identifier="location",
                                              title="Plaats de onttrekking door op de groene knop hieronder te klikken en dan een locatie te 'prikken'",
                                              abstract="input=mapselection",
                                              type=type(""),
                                              uoms=["point"],
                                              default="Select a location on the map")

        # OUTPUTS
        self.json = self.addComplexOutput(identifier="json",
                                          title="Returns list of values for specified xy",
                                          abstract="""Returns list of values for specified xy""",
                                          formats=[{"mimeType": "text/plain"},  # 1st is default
                                                   {'mimeType': "application/json"}]) 

    # Parameters check
    def check_location(self, location, epsgin='epsg:3857'):        
        # Valid JSON
        try:
            # Input (coordinates)  
            location_info = json.loads(location)
            (xin,yin) = location_info['x'], location_info['y']
            (x,y) = change_coords(xin, yin, epsgin=epsgin, epsgout='epsg:28992')
            x, y = round(x), round(y)
            logging.info('''Input Coordinates {} {}'''.format(xin,yin))
            logging.info('''RDNEW Coordinates {} {}'''.format(x,y))            
        except:
            return False, '''<p>Selecteer eerst een locatie met de 'Select on map' knop</p>''', -1, -1, -1, -1
                
        # Parameters check OK 
        return True, '', x, y, xin, yin

    # ----------------------------------- #
    # MAIN: Execute WPS function
    # ----------------------------------- #
    def execute(self):
        # Read Config file
        CONF = onttrekking_CONF(CONFIG_FILE)
        self.config = CONF.readConfig()

        # Outputs prepare
        outdata = StringIO.StringIO()
        values = {}

        # Output prepare
        IO = onttrekking_IO(self.config)

        # Inputs check
        location = self.location.getValue() 
        t = self.t.getValue()
        Q = self.Q.getValue()
        Tf = self.Tf.getValue()
        Lf = self.Lf.getValue()
        Ss = self.Ss.getValue()
        Sy = self.Sy.getValue()
        logging.info('''INPUT [onttrekking]: location={}'''.format(str(self.location.getValue)))
        logging.info('''INPUT [onttrekking]: t={} Q={} Tf={} Lf={} Ss={} Sy={}'''.format(t, Q, Tf, Lf, Ss, Sy))

        # Error messaging
        okloc, msg, x, y, xin, yin = self.check_location(location)
        if not(okloc):            
            logging.info(msg)            
            values['error_html'] = msg
            json_str = json.dumps(values, use_decimal=True)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return

        # Ground level
        z = AHN_DAP(x, y)

        # Run model prepare
        RUN = onttrekking_RUN(self.config)

        # Get temporary directory
        tmpdir = RUN.getTempDir()
        name = os.path.basename(tmpdir)

        # Find out right parameters from GeoTop
        geotop = GeoTopOnOpendap('http://www.dinodata.nl/opendap/GeoTOP/geotop.nc').get_all_layers(x, y)
        IO.writeCSV(os.path.join(tmpdir, 'info_geotop.csv'), geotop)

        # Prepare input CSV
        csvfile = RUN.setupInputCSV(tmpdir, x, y, t, Q, Tf, Lf, Ss, Sy, z)

        # Run model + isolines generate
        outputgtif = RUN.runModel(csvfile, tmpdir)
        outputshpiso = raster2isolines(outputgtif) # shp rd_new

        # Insert layer to geoserver
        wmslayer = IO.geoserverUploadGtif(outputgtif, tmpdir)
        zipshp = IO.zipShp(outputshpiso)        
        wmslayeriso = IO.geoserverUploadShp(zipshp, tmpdir)
        IO.geoserverGroupLayers(name, wmslayer, wmslayeriso)

        # Setup outputs
        values = {}
        values['outputgtif'] = outputgtif        
        values['wmslayer'] = wmslayer
        values['wmslayer_isolines'] = wmslayeriso
        
        # BBOX for interface zoom
        values['bbox_rdnew'] = [x, y, x, y]
        values['bbox'] = [xin, yin, xin, yin]

        # Send back JSON
        json_str = json.dumps(values, use_decimal=True)
        logging.info('''OUTPUT [onttrekking]: {}'''.format(json_str))
        outdata.write(json_str)
        self.json.setValue(outdata)
        
        return
