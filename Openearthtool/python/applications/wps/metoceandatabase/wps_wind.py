# -*- coding: utf-8 -*-
"""
Created on Tue Mar 14 16:51:44 2017

@author: wps
"""

'''

http://localhost/cgi-bin/pywps.cgi?&service=wps&version=1.0.0&request=GetCapabilities
http://localhost/cgi-bin/pywps.cgi?&service=wps&version=1.0.0&request=DescribeProcess&identifier=wps_wind
http://localhost/cgi-bin/pywps.cgi?&service=wps&version=1.0.0&request=Execute&identifier=wps_wind&datainputs=[locations={"id":"OpenLayers_Geometry_Point_212","x":-1779633.3901414,"y":6836335.5553734,"bounds":{"left":-1779633.3901414,"bottom":6836335.5553734,"right":-1779633.3901414,"top":6836335.5553734}};startdate=19000101;enddate=20180101]

Repository information:
Date of last commit:     $Date: 2015-06-15 09:04:54 +0200 (Mon, 15 Jun 2015) $
Revision of last commit: $Revision: 11987 $
Author of last commit:   $Author: hendrik_gt $
URL of source:           $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/naivasha/fews_gettimeseries.py $
CodeID:                  $ID$

'''


import logging
from pywps.Process import WPSProcess
# import bokeh_plots
import plotting_windrose
import datetime
import os
import StringIO
import json
import re
import fnmatch

from getLocations import getLocations
from pyproj import Proj, transform
import netCDF4
from windrose import WindroseAxes
import numpy as np
import matplotlib.pyplot as plt
from io import BytesIO
import base64
import glob
import ConfigParser

CONFIG_FILE=os.path.join(os.path.dirname(os.path.realpath(__file__)), 'default.cfg')


class Process(WPSProcess):
    PLOTS_DIR = ''
    APACHE_DIR = ''
    def __init__(self):

        ##
        # Process initialization
        WPSProcess.__init__(self,
                            identifier="wps_wind",
                            title="""Wind """,
                            abstract="""Data on Wind direction and speed yearly or monthly from 1979-2015
                            """,
                            version="1.1",
                            storeSupported=True,
                            statusSupported=True)

        self.type = self.addLiteralInput(
            identifier="type",
            title="Yearly or Monthly",
            abstract="input=dropdownmenu",
            type=type(""),
            allowedValues=["Yearly", "Monthly"],
            default="Yearly")

        self.locations = self.addLiteralInput(
            identifier="locations",
            title="Locations selected for residual curve",
            abstract="input=mapselection",
            type=type(""),
            uoms=["point"],
            default="Select a location on the map")

        self.json = self.addComplexOutput(
            identifier="json",
            title="Returns list of values for specified xy",
            abstract="""Returns list of values for specified xy""",
            formats=[{"mimeType": "text/plain"},  # 1st is default
                   {'mimeType': "application/json"}])

    ##
    # Execution part of the process
    def readConfig(self):
        cf = ConfigParser.RawConfigParser()
        cf.read(CONFIG_FILE)
        self.APACHE_DIR = cf.get('server', 'apache_dir')

    def execute(self):
        self.readConfig()
        locations = self.locations.getValue()
        static_folder="C:/Apache24/htdocs/static"
        if self.type.getValue() == "Monthly":
            mode = ["wind_roses"]
        elif self.type.getValue() == "Yearly":
            mode = ["u10_ref"]
        logging.info(mode)
        APACHE_DIR  = self.APACHE_DIR
        plot_name = 'wind'

        #Transform OSM to latlon coordinates
        locations = json.loads(locations)
        lat, lon = getLocations(locations)
        dirname = r"D:/data/Metoceanatlas/"
        json_output = StringIO.StringIO()
        values = {}
        code = "No data available near this location"
        for i in range(len(lat)):
            latt = lat[i]
            lont = lon[i]
            if lat[i] %1.0==0.0:
                latt = int(lat[i])
            if lon[i] %1.0==0.0:
                lont = int(lon[i])
            filen = "erai_" + mode[0] + "_lon_" + str(lont) + "_lat_" + str(latt) + "*.png"
            try:
                rule = re.compile(fnmatch.translate(filen), re.IGNORECASE)
                png_name = [name for name in os.listdir(dirname) if rule.match(name)][0]
                logging.info('this is it')
                encoded = base64.b64encode(open(dirname + png_name, "rb").read())
                code = """
                <div id='figure1'>
                    <img  id='figure' src='data:image/png; base64, """ + str(encoded) + """' height='90%' width='90%'>
                </div>
                <button class="download">Download PNG</button>

                <script src="http://code.jquery.com/jquery-1.11.2.min.js"></script>
                <script>
                    $('.download').on('click', function(){
                       $('<a />').attr({
                              download: 'export.png',
                              href: 'data:image/png; base64, """ + str(encoded) + """'
                       })[0].click()
                    });
                </script>
                """
                break
            except IndexError:
                logging.info(filen)

        H = datetime.datetime.now()
        uid = H.strftime("%Y%m%d%H%M%S%f")
        file_name = r"%s%s.html" % (plot_name, uid)
        work_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)))
        abs_static_folder = os.path.abspath(os.path.join(work_dir,
                                                             static_folder))
        fpana = os.path.join(abs_static_folder, file_name)

        values['url_plot'] = APACHE_DIR + file_name
        values['title'] = "Wind"
        logging.info(fpana)
        with open(fpana, "w") as fp:
            fp.write(code)

        json_str = json.dumps(values)
        json_output.write(json_str)
        logging.info('''OUTPUT [info_nhiflux]: {}'''.format(json_str))
        self.json.setValue(json_output)
        return
