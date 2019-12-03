# -*- coding: utf-8 -*-
"""
Created on Tue Mar 14 16:51:44 2017

@author: wps
"""

'''

http://localhost/cgi-bin/pywps.cgi?&service=wps&version=1.0.0&request=GetCapabilities
http://localhost/cgi-bin/pywps.cgi?&service=wps&version=1.0.0&request=DescribeProcess&identifier=wps_windrose
http://localhost/cgi-bin/pywps.cgi?&service=wps&version=1.0.0&request=Execute&identifier=wps_windrose&datainputs=[locations={"id":"OpenLayers_Geometry_Point_212","x":-1779633.3901414,"y":6836335.5553734,"bounds":{"left":-1779633.3901414,"bottom":6836335.5553734,"right":-1779633.3901414,"top":6836335.5553734}};startdate=19000101;enddate=20180101]

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
from pyproj import Proj, transform

import netCDF4
from windrose import WindroseAxes
import numpy as np
import matplotlib.pyplot as plt
from io import BytesIO
import base64

import ConfigParser

CONFIG_FILE=os.path.join(os.path.dirname(os.path.realpath(__file__)), 'default.cfg')


class Process(WPSProcess):
    PLOTS_DIR = ''
    APACHE_DIR = ''
    def __init__(self):

        ##
        # Process initialization
        WPSProcess.__init__(self,
                            identifier="wps_windrose",
                            title="""Windrose """,
                            abstract="""Plotting a waverose with the information on mean wave direction and  wave height.
                            """,
                            version="1.1",
                            storeSupported=True,
                            statusSupported=True)
        #
        # self.parameterID = self.addLiteralInput(
        #     identifier="parameterid",
        #     title="Parameter ID",
        #     abstract="input=dropdownmenu",
        #     type=type(""),
        #     default="P.obs")

        self.locations = self.addLiteralInput(
            identifier="locations",
            title="Locations selected for residual curve",
            abstract="input=mapselection",
            type=type(""),
            uoms=["point"],
            default="Select a location on the map")

        self.sdate = self.addLiteralInput(
            identifier="startdate",
            title="Start date for data collection",
            abstract="input=dateObject",
            type=type(""),
            default="19800101")

        self.edate = self.addLiteralInput(
            identifier="enddate",
            title="End date for data collection",
            abstract="input=dateObject",
            type=type(""),
            default="20170101")
        ##
        # Adding process outputs

        # self.Output1 = self.addComplexOutput(
        #     identifier="json",
        #     title="Time series for specified parameter and locationid",
        #     formats=[{"mimeType": "text/plain"},  # 1st is default
        #              {'mimeType': "text/html"}])
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
        # self.PLOTS_DIR = cf.get('server', 'plots_dir')
        self.APACHE_DIR = cf.get('server', 'apache_dir')

    def execute(self):
        self.readConfig()
        locations = self.locations.getValue()
        startdate = self.sdate.getValue()
        enddate = self.edate.getValue()
        static_folder="C:/Apache24/htdocs/static"
        APACHE_DIR  = self.APACHE_DIR
        plot_name = 'Windrose'

        #Transform OSM to latlon coordinates
        locations = json.loads(locations)
        x_coor = locations['x']
        y_coor = locations['y']
        P3857 = Proj(init='epsg:3857') # Mercator OSM projectie
        P4326 = Proj(init='epsg:4326') # latlon
        lon_viewer, lat_viewer= transform(P3857, P4326, x_coor, y_coor) # from latlon to Mercator OSM projection

        plt.close('all')
        url = r'http://al-ng002.xtr.deltares.nl/thredds/dodsC/fast/era/erai2015.nc'
        data = netCDF4.Dataset(url, 'r')

        lat_nc = data.variables['latitude'][:]
        lon_nc = data.variables['longitude'][:]

        id_lat = (np.abs(lat_nc - lat_viewer)).argmin()
        id_lon = (np.abs(lon_nc - lon_viewer)).argmin()

        title = 'lat, lon: ' + str(lat_nc[id_lat]) + ', ' +  str(lon_nc[id_lon]) + '; ' + str(lat_viewer) + ', ' +  str(lon_viewer)
        logging.info(title)
        json_output = StringIO.StringIO()
        values = {}
        try:
            fig = plt.figure()
            rect =[0, 0, 1, 1]

            # fig.add_axes(rect, projection='polar')
            logging.info(data.variables['mwd'][:, id_lat, id_lon], data.variables['swh'][:, id_lat, id_lon])
            ax = WindroseAxes(fig, rect)
            fig.add_axes(ax, polar=True)
            ax.bar(data.variables['mwd'][:, id_lat, id_lon], data.variables['swh'][:, id_lat, id_lon],
                   normed=True, opening=0.8, edgecolor='white')
            ax.set_legend()
            data.close()

            figfile = BytesIO()
            plt.savefig(figfile, format='png')
            figfile.seek(0)
            figdata_png = figfile.getvalue()
            figdata_png = base64.b64encode(figdata_png)
            code = "<img src='data:image/png; base64, " + str(figdata_png) +"' width='500'>"
        except Exception:
            code = 'Clicked on land, no waves here'
            logging.info(code)
            values['error_html'] = code
        logging.info('plotted')

        H = datetime.datetime.now()
        uid = H.strftime("%Y%m%d%H%M%S%f")
        file_name = r"%s%s.html" % (plot_name, uid)
        work_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)))
        abs_static_folder = os.path.abspath(os.path.join(work_dir,
                                                             static_folder))
        fpana = os.path.join(abs_static_folder, file_name)

        values['url_plot'] = APACHE_DIR + file_name
        values['title'] = title
        logging.info(fpana)
        with open(fpana, "w") as fp:
            fp.write(code)

        json_str = json.dumps(values)
        json_output.write(json_str)
        logging.info('''OUTPUT [info_nhiflux]: {}'''.format(json_str))
        self.json.setValue(json_output)
        return
        # if self.sdate.getValue() == 'NoneType':
        #     logging.info('start date is null ')
        # if len(self.sdate.getValue()) < 8:
        #     logging.info('start date if null ' + self.sdate.getValue())
        #     if len(self.edate.getValue()) < 8:
        #         logging.info('end date if null ' + self.edate.getValue())
        #         io = plotting_windrose.windrose(
        #             self.locations.getValue(),
        #             '19810101', '19820101',
        #             APACHE_DIR = self.APACHE_DIR
        #
        #             # , **arg_dict
        #         )
        # else:
        #     io = plotting_windrose.windrose(self.locations.getValue(),
        #                                     self.sdate.getValue(),
        #                                     self.edate.getValue(),
        #                                     APACHE_DIR =self.APACHE_DIR
        #                                     # **arg_dict
        #                                     )
        #     logging.info('start date  ' + self.sdate.getValue())
        #     logging.info('end date    ' + self.edate.getValue())
        # logging.info(io)
        # self.Output1.setValue(io)
        # if not io:
        #     self.Output1.setValue('no data retrieved')
        #     logging.info('no data retrieved')
        # else:
        #     logging.info(io, self.Output1)
        #     self.Output1.setValue(io)
        #     io.close()
        # return
