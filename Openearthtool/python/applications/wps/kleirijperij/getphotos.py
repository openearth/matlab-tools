# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
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

# $Id: getphotos.py 15004 2018-12-21 09:50:58Z groen_fe $
# $Date: 2018-12-21 01:50:58 -0800 (Fri, 21 Dec 2018) $
# $Author: groen_fe $
# $Revision: 15004 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/kleirijperij/getphotos.py $
# $Keywords: $

# core
import os
import math
import tempfile
import logging
import time
import datetime

# modules
import sqlfunctions
import simplejson as json
import StringIO
from pywps.Process import WPSProcess
from types import FloatType
from types import StringType

"""
This is a redesigned WPS for the Kleirijperij application.

if it runs on localhost then:
getcapabilities:  http://localhost/cgi-bin/pywps.cgi?request=GetCapabilities&service=wps&version=1.0.0
describe process: http://localhost/cgi-bin/pywps.cgi?request=DescribeProcess&service=wps&version=1.0.0&identifier=waterbodems_regis
execute:          http://localhost/cgi-bin/pywps.cgi?&service=wps&request=Execute&version=1.0.0&identifier=waterbodems_regis&datainputs=[linestr={%20"type":%20"FeatureCollection",%20"features":%20[%20{%20"type":%20"Feature",%20"properties":%20{%20"id":%20null%20},%20"geometry":%20{%20"type":%20"LineString",%20"coordinates":%20[%20[%2083831.092144669499,%20448452.68563390407%20],%20[%2083958.355731735704,%20448428.40837328951%20],%20[%2084101.003099671972,%20448430.12129659101%20],%20[%2084247.216841408226,%20448418.68480195443%20],%20[%2084347.366886706994,%20448334.90273034602%20],%20[%2084437.90036527536,%20448234.41033133975%20],%20[%2084524.658347761986,%20448132.09910295915%20],%20[%2084624.369683701385,%20448016.50065624306%20],%20[%2084727.680250018995,%20447889.61876790464%20],%20[%2084823.542831033759,%20447766.58495800826%20],%20[%2084908.650886898482,%20447679.27150645608%20]%20]%20}%20}%20]%20}]
"""

class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="getphotos",
                            title="Toon foto's per datum",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Toon de fotos die gemaakt zijn op locatie per datum.""",
                            grassLocation=False)

        # PostgreSQL access
        cf = r'D:\pywps\pywps_processes\connection.txt'
        credentials = sqlfunctions.get_credentials(cf)

        # sqlfunctions.py
        getDates = """SELECT DISTINCT datum FROM public.photos ORDER BY datum ASC"""
        listDates = sqlfunctions.executesqlfetch(getDates,credentials)
        f = '%Y-%m-%d'
        dates = []

        # convert to readable data for the viewer
        for i in listDates:
            date = i[0]
            date = str(date)
            dates.append(date)

        logging.info('''FROM DATABASE [photos]: available dates for photos are {}'''.format(dates))

        self.photodate = self.addLiteralInput(
                    identifier="datum",
                    title="Kies datum",
                    abstract="input=dropdownmenu",
                    type=type(""),
                    allowedValues=dates,
                    default="2018-07-12")
                                             
        self.json = self.addComplexOutput(identifier="json",
                                          title="Returns list of values (lithology in case of Geotop in m below surface level) for specified xy",
                                          abstract="""For every geotop lithology top, bottom, lithology and hex colour is given. Origin of Geotop is http://www.dinodata.nl/opendap/""",
                                          formats=[{"mimeType": "text/plain"},  # 1st is default
                                                   {'mimeType': "application/json"}])


    def execute(self):

        # PostgreSQL access
        cf = r'D:\pywps\pywps_processes\connection.txt'
        logging.info('connection text found')
        credentials = sqlfunctions.get_credentials(cf)

        # Output prepare
        json_output = StringIO.StringIO()
        values = {}
        
        # Input date
        inputdate = self.photodate.getValue()
        logging.info('''INPUT [getphotos]: date = {}'''.format(inputdate))

        # Create view
        # sqlfunctions.py
        createView = """CREATE OR REPLACE VIEW public.photo_view AS (SELECT datum, vak, geom, string_agg(path, ',') as path FROM photos WHERE datum = '{}' group by datum, vak, geom);""".format(inputdate)
        new_view = sqlfunctions.perform_sql(createView,credentials)

        # Publish on geoserver
        # create layer in geoserver .. randomness 
        # WMS handleWMS refresh map, open new layer, delete layer
        rnd=int(time.time())
        wmslayer = 'photos:photo_view'
        
        # 
        values['wmslayer'] = wmslayer     
        
        # Output finalize        
        json_str = json.dumps(values, use_decimal=True)
        logging.info(json_str)
        json_output.write(json_str)
        self.json.setValue(json_output)

        return