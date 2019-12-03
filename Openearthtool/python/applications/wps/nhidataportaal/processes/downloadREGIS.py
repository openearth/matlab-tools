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

# $Id: downloadREGIS.py 13812 2017-10-10 18:50:44Z sala $
# $Date: 2017-10-10 20:50:44 +0200 (Tue, 10 Oct 2017) $

# core
import os
import math
import tempfile
import logging
import time
import configparser
import zipfile

# modules
import types
import simplejson as json
import io
from pywps.Process import WPSProcess
from random import choice

# other
from coords import change_coords
from utils_wcs import *
from utils_wfs import *

# Default config file (relative path)
CONFIG_FILE = os.path.join(os.path.dirname(
    os.path.realpath(__file__)), 'REGISconfig.txt')


class Process(WPSProcess):
    # Fill in from configuration
    PLOTS_DIR = ''
    APACHE_DIR = ''

    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="downloadREGIS",
                            title="Download REGIS data [experimental]",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""This function allows you to download REGIS data in several formats/projections [experimental]""",
                            grassLocation=False)

        self.jsonreq = self.addComplexInput(identifier="jsonreq", maxmegabites=20,
                                            title="Vector with all the download requests queue",
                                            formats=[
                                                {'mimeType': 'text/plain',
                                                 'encoding': 'UTF-8'},
                                                {'mimeType': 'application/json'}
                                            ])

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
        self.RANDOM = ''.join(choice(string.ascii_uppercase + string.digits)
                              for _ in range(7))  # random identifier for files

    def execute(self):
        # Outputs prepare
        outdata = io.StringIO()
        values = {}

        # Read configuration file
        self.readConfig()

        # Input parameters read
        with open(self.jsonreq.getValue(), 'r') as f1:
            reqstr = f1.read()
            logging.info('INPUT [downloadREGIS]: '+reqstr)
            data = json.loads(reqstr)

        # Loop over requests
        files2zip = []
        for req in data:
            logging.info('''INPUT [downloadREGIS]: layername={}, fformat={}'''.format(
                req['layername'], req['fformat']))
            logging.info('''INPUT [downloadREGIS]: latlonbox={}, outcrs={}'''.format(
                req['latlonbox'], req['outcrs']))
            logging.info('''INPUT [downloadREGIS]: typereq={}, owsurl={}'''.format(
                req['typereq'], req['owsurl']))

            # Distinguish between WCS/WFS
            [xmin, ymin, xmax, ymax] = req['latlonbox'].split(',')
            # Request has to be in same epsg, vector data is in rdnew
            incrs = 'epsg:4326'
            crsdata = 'epsg:28992'
            (xmink, ymink) = change_coords(
                xmin, ymin, epsgin=incrs, epsgout=crsdata)
            (xmaxk, ymaxk) = change_coords(
                xmax, ymax, epsgin=incrs, epsgout=crsdata)
            logging.info('''input_coords [downloadREGIS]: [{},{},{},{}]'''.format(
                xmin, ymin, xmax, ymax))
            logging.info('''change_coords [downloadREGIS]: [{},{},{},{}]'''.format(
                xmink, ymink, xmaxk, ymaxk))
            bboxrdnew = (round(xmink / 500.0) * 500.0, round(ymink / 500.0) *
                         500.0, round(xmaxk / 500.0) * 500.0, round(ymaxk / 500.0) * 500.0)
            logging.info('Rounded bbox: ' + str(bboxrdnew))

            if req['typereq'] == 'wfs':
                # WFS request in RD_NEW
                outfname = self.getDatafromWFS(req['outfname'], req['ext'], req['owsurl'], bboxrdnew,
                                               req['layername'], req['fformat'], crsdata, self.OUT_DIR, self.RANDOM)

                # Reproject if needed [ogrinfo]
                if req['outcrs'] != 'EPSG:28992':
                    logging.info('Reproject not available for vector files')
            else:
                # BBOX rounded/latlon
                (lon0, lat0) = change_coords(
                    bboxrdnew[0], bboxrdnew[1], epsgin=crsdata, epsgout=incrs)
                (lon1, lat1) = change_coords(
                    bboxrdnew[2], bboxrdnew[3], epsgin=crsdata, epsgout=incrs)

                # WCS request directly the raster [epsg:4326]
                tiffname = self.getDatafromWCS(req['outfname'], req['ext'], req['fformat'], req['owsurl'],
                                               req['layername'], 'EPSG:4326', lon0, lat0, lon1, lat1, self.OUT_DIR, self.RANDOM)

                # Reproject if needed
                if req['outcrs'] != 'EPSG:4326':
                    outfname = tiffname.replace('.tif', '_reproj.tif')
                    cmd = 'gdalwarp -t_srs {} \"{}\" \"{}\"'.format(
                        req['outcrs'], tiffname, outfname)
                    logging.info(cmd)
                    os.system(cmd)
                    os.remove(tiffname)
                    tiffname = outfname  # replace

                # Format if needed
                if req['fformat'] != 'GTiff':
                    outfname = os.path.join(
                        self.OUT_DIR, req['outfname'] + '_' + self.RANDOM + req['ext'])
                    cmd = 'gdal_translate -of {} \"{}\" \"{}\"'.format(
                        req['fformat'], tiffname, outfname)
                    logging.info(cmd)
                    os.system(cmd)
                else:
                    outfname = tiffname

            # Add filename to zip
            files2zip.append(outfname)

        # Zip all files
        zipfname = os.path.join(
            self.OUT_DIR, 'REGIS_data_export_{}.zip'.format(self.RANDOM))
        zf = zipfile.ZipFile(zipfname, mode='w')
        os.chdir(self.OUT_DIR)
        for f in files2zip:
            bf = os.path.basename(f)
            logging.info('Adding to zipfile: {}'.format(bf))
            zf.write(bf)
            os.remove(bf)  # clean
            # Some have prj file
            prjfile = os.path.splitext(bf)[0]+'.prj'
            if os.path.exists(prjfile):
                zf.write(prjfile)
                os.remove(prjfile)  # clean
        zf.close()

        # Send back result JSON
        values['url_data'] = self.APACHE_DIR + '/' + os.path.basename(zipfname)
        json_str = json.dumps(values)
        logging.info('''OUTPUT [downloadREGIS]: {}'''.format(json_str))
        outdata.write(json_str)
        self.json.setValue(outdata)

        return
