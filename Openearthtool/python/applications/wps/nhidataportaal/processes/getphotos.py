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

# $Id: info_regis.py 12746 2016-05-20 12:35:24Z sala_joan $
# $Date: 2016-08-22 14:35:24 +0200 (Mon, 22 Aug 2016) $
# $Author: sala $
# $Revision: 12746 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/onlinemodelling/info_regis.py $
# $Keywords: $

# core
import os
import math
import tempfile
import logging
import time

# modules
import simplejson as json
import io
from pywps.Process import WPSProcess
from types import FloatType
from types import StringType
import psycopg2
"""
Waterbodems REGIS WPS start script

This is a redesigned WPS for the Waterbodems application, based in infoline_redesigned.

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
                            title="Show photos by date",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Show the photos that are taken within the range of dates you choose from.""",
                            grassLocation=False)

        self.sdate = self.addLiteralInput(identifier="sdate",
                                          title="Selecteer begindatum (YYYY-MM-DD)",
                                          type=StringType, default='2018-07-12')

        self.edate = self.addLiteralInput(identifier="edate",
                                          title="Selecteer einddatum (YYYY-MM-DD)",
                                          type=StringType, default='2018-10-17')

        self.json = self.addComplexOutput(identifier="json",
                                          title="Returns list of values (lithology in case of Geotop in m below surface level) for specified xy",
                                          abstract="""For every geotop lithology top, bottom, lithology and hex colour is given. Origin of Geotop is http://www.dinodata.nl/opendap/""",
                                          formats=[{"mimeType": "text/plain"},  # 1st is default
                                                   {'mimeType': "application/json"}])

    def execute(self):

        # PostgreSQL access
        uname = "oet_data"
        pwd = "wKcw2cTP746rO8tDDcAq"
        host = "tl-pg057.xtr.deltares.nl"
        dbname = "kleirijperij"

        # function the gets the data from a database using connection strings and a string with a SQL command. (From Gerrit)
        def getdata(dbname, host, uname, pwd, strSql):
            conn = psycopg2.connect(
                "dbname="+dbname+" host="+host+" user="+uname+" password="+pwd)

            cur = conn.cursor()
            arr = []

            cur.execute(strSql)
            arr = cur.fetchall()

            conn.close()

            return arr

        # Output prepare
        json_output = io.StringIO()
        values = {}

        # Input line/point
        sdate = self.sdate.getValue()
        edate = self.edate.getValue()
        logging.info('''INPUT: start datum={}'''.format(sdate))
        logging.info('''INPUT: eind datum={}'''.format(edate))

        # Create view
        # sqlfunctions.py
        createView = 'CREATE VIEW photo_view AS SELECT path, datum, geom, vak FROM photos WHERE datum >= {} AND datum < {}'.format(
            sdate, edate)
        new_view = getdata(dbname, host, uname, pwd, createView)

        # Perform SQL query
        #engine = create_engine('')
        #res = engine.execute(createView)
        #header = res.keys()

        # Publish on geoserver
        wmslayer = new_view

        #
        values['wmslayer'] = wmslayer

        # Output finalize
        json_str = json.dumps(values, use_decimal=True)
        logging.info(json_str)
        json_output.write(json_str)
        self.json.setValue(json_output)

        return
