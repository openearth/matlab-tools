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

# $Id: downloadNHI.py 13812 2017-10-10 18:50:44Z sala $
# $Date: 2017-10-10 20:50:44 +0200 (Tue, 10 Oct 2017) $

# core
import os
import math
import tempfile
import logging
import time
import configparser

# modules
import types
import simplejson as json
import io
# from pywps.Process import WPSProcess

# other
from coords import change_coords
from utils_wcs import *
from utils_wfs import *

# Default config file (relative path)
CONFIG_FILE = os.path.join(os.path.dirname(
    os.path.realpath(__file__)), 'NHIconfig.txt')


class Process(WPSProcess):
    # Fill in from configuration
    PLOTS_DIR = ''
    APACHE_DIR = ''

    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="downloadNHI",
                            title="Download NHI data [experimental]",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""This function allows you to download NHI data in several formats/projections [experimental]""",
                            grassLocation=False)

        self.layername = self.addLiteralInput(identifier="layername",
                                              title="Layer name",
                                              type=type(""),
                                              default='grondwateronttrekking:Locatie_onttrekkingen')

        self.typereq = self.addLiteralInput(identifier="typereq",
                                            title="Type of request",
                                            type=type(""),
                                            allowedValues=["wcs", "wfs"],
                                            default='wfs')

        self.outcrs = self.addLiteralInput(identifier="outcrs",
                                           title="EPSG definition [output]",
                                           type=type(""),
                                           default='epsg:28992')

        self.fformat = self.addLiteralInput(identifier="fformat",
                                            title="File format",
                                            type=type(""),
                                            allowedValues=[
                                                "shape-zip", "image/geotiff"],
                                            default='shape-zip')

        self.latlonbox = self.addLiteralInput(identifier="latlonbox",
                                              title="Bounding box [in latlon wgs84]",
                                              type=type(""),
                                              default='4.953,51.927,5.463,52.196')  # utrecht

        self.owsurl = self.addLiteralInput(identifier="owsurl",
                                           title="OWS url endpoint",
                                           type=type(""),
                                           default='http://al-ng023.xtr.deltares.nl/geoserver/ows')

        self.json = self.addComplexOutput(identifier="json",
                                          title="Returns list of values for specified xy",
                                          abstract="""Returns list of values for specified xy""",
                                          formats=[{"mimeType": "text/plain"},  # 1st is default
                                                   {'mimeType': "application/json"}])
    # Read configuration from file

    def readConfig(self):
        cf = configparser.RawConfigParser()
        cf.read(CONFIG_FILE)
        self.OUT_DIR = cf.get('Bokeh', 'plots_dir')
        self.APACHE_DIR = cf.get('Bokeh', 'apache_dir')

    # Get Raster transect intersect [default 100m]
    def getDatafromWCS(self, geoserver_url, layername,  xst, yst, xend, yend, crs=32638, all_box=False):
        linestr = 'LINESTRING ({} {}, {} {})'.format(xst, yst, xend, yend)
        l = LS(self.OUT_DIR, linestr, crs, geoserver_url, layername)
        l.line()
        return l.intersect(all_box=all_box)  # coords+data

    # Get Vector data from WFS
    def getDatafromWFS(self, url_wfs, bbox, layer_wfs, fformat, outcrs, outdir):
        wfs = WFS(bbox, url_wfs, layer_wfs, fformat, outcrs, outdir)
        return wfs.getDataWFS()

    def execute(self):
        # Outputs prepare
        outdata = io.StringIO()
        values = {}

        # Read configuration file
        self.readConfig()

        # Input parameters read
        layername = self.layername.getValue()
        typereq = self.typereq.getValue()
        outcrs = self.outcrs.getValue()
        fformat = self.fformat.getValue()
        latlonbox = self.latlonbox.getValue()
        typereq = self.typereq.getValue()
        owsurl = self.owsurl.getValue()
        logging.info('''INPUT [downloadNHI]: layername={}, fformat={}'''.format(
            layername, fformat))
        logging.info(
            '''INPUT [downloadNHI]: latlonbox={}, outcrs={}'''.format(latlonbox, outcrs))
        logging.info(
            '''INPUT [downloadNHI]: typereq={}, owsurl={}'''.format(typereq, owsurl))

        # Distinguish between WCS/WFS
        [xmin, ymin, xmax, ymax] = latlonbox.split(',')
        if typereq == 'wfs':
            # Request has to be in same epsg
            incrs = 'epsg:4326'
            crsdata = 'epsg:28992'
            (xmink, ymink) = change_coords(
                xmin, ymin, epsgin=incrs, epsgout=crsdata)
            (xmaxk, ymaxk) = change_coords(
                xmax, ymax, epsgin=incrs, epsgout=crsdata)
            logging.info('''input_coords [downloadNHI]: [{},{},{},{}]'''.format(
                xmin, ymin, xmax, ymax))
            logging.info('''change_coords [downloadNHI]: [{},{},{},{}]'''.format(
                xmink, ymink, xmaxk, ymaxk))
            bboxrdnew = (xmink, ymink, xmaxk, ymaxk)
            # WFS request [http://al-ng023.xtr.deltares.nl:80/geoserver/ows?SERVICE=WFS&REQUEST=GetFeature&TYPENAME=grondwateronttrekking:Locatie_onttrekkingen&OUTPUTFORMAT=shape-zip&BBOX=4.574,51.719,5.113,52.065]
            outfname = self.getDatafromWFS(
                owsurl, bboxrdnew, layername, fformat, outcrs, self.OUT_DIR)
        else:
            # WCS request directly the raster [epsg:4326]
            outfname = self.getDatafromWCS(
                owsurl, layername, xmin, ymin, xmax, ymax, all_box=True)
            # Convert raster to epsg

        # Send back result JSON
        values['url_data'] = self.APACHE_DIR + '/' + os.path.basename(outfname)
        json_str = json.dumps(values)
        logging.info('''OUTPUT [downloadNHI]: {}'''.format(json_str))
        outdata.write(json_str)
        self.json.setValue(outdata)

        return
