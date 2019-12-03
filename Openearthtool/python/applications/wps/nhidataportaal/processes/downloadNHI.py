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
import zipfile
import pprint
import urllib.request
import urllib.parse
import urllib.error

# modules
import types
import simplejson as json
import io
from pywps import Format
from pywps.app import Process
from pywps.inout.inputs import ComplexInput, LiteralInput
from pywps.inout.outputs import LiteralOutput,ComplexOutput
from pywps.app.Common import Metadata
from pywps.inout.formats import FORMATS
# from pywps.Process import WPSProcess
from random import choice

# other
from .coords import change_coords
from .utils_wcs import *
from .utils_wfs import *

logger = logging.getLogger('PYWPS')

# Default config file (relative path)
CONFIG_FILE = os.path.join(os.path.dirname(
    os.path.realpath(__file__)), 'NHIconfig.txt')


# class Process(WPSProcess):
class downloadNHI(Process):
    # Fill in from configuration
    PLOTS_DIR = ''
    APACHE_DIR = ''

    def __init__(self):
        # init process; note: identifier must be same as filename
        inputs = [ComplexInput(identifier="jsonreq",  #maxsingleinputsize=20 parameters is not available in this version
        #TODO: implement validation function for the size of the input
                                            title="Vector with all the download requests queue",
                                            supported_formats=[Format("text/plain"), Format("application/json")])]
                                            #     {'mimeType': 'text/plain',
                                            #      'encoding': 'UTF-8'},
                                            #     {'mimeType': 'application/json'}
                                            # ])]
        outputs = [ComplexOutput(identifier="json",
                                          title="Returns list of values for specified xy",
                                          abstract="""Returns list of values for specified xy""",
                                          supported_formats=[Format("text/plain"),Format("application/json")])]
                                          # Format=[{"mimeType": "text/plain"},  # 1st is default
                                          #          {'mimeType': "application/json"}])]

        super(downloadNHI, self).__init__(
                            self._handler,
                            identifier="downloadNHI",
                            title="Download NHI data [experimental]",
                            version='1.3.3.7',
                            store_supported="true",
                            status_supported="true",
                            abstract="""This function allows you to download NHI data in several formats/projections [experimental]""",
                            grass_location=False,
                            inputs=inputs,
                            outputs=outputs)

        # self.jsonreq = self.addComplexInput(identifier="jsonreq", maxmegabites=20,
        #                                     title="Vector with all the download requests queue",
        #                                     formats=[
        #                                         {'mimeType': 'text/plain',
        #                                          'encoding': 'UTF-8'},
        #                                         {'mimeType': 'application/json'}
        #                                     ])
        #
        # self.json = self.addComplexOutput(identifier="json",
        #                                   title="Returns list of values for specified xy",
        #                                   abstract="""Returns list of values for specified xy""",
        #                                   formats=[{"mimeType": "text/plain"},  # 1st is default
        #                                            {'mimeType': "application/json"}])
    # Read configuration from file

    def readConfig(self):
        cf = configparser.RawConfigParser()
        cf.read(CONFIG_FILE)
        self.OUT_DIR = cf.get('Bokeh', 'plots_dir')
        self.APACHE_DIR = cf.get('Bokeh', 'apache_dir')
        self.RANDOM = ''.join(choice(string.ascii_uppercase + string.digits)
                              for _ in range(7))  # random identifier for files

    # Get Raster transect intersect [default 100m]
    def getDatafromWCS(self, outfname, ext, fformat, geoserver_url, layername, crs, xst, yst, xend, yend, outdir, random):
        linestr = 'LINESTRING ({} {}, {} {})'.format(xst, yst, xend, yend)
        l = LS(outfname, ext, fformat, outdir, random,
               linestr, crs, geoserver_url, layername)
        l.line()
        return l.intersect()  # coords+data

    # Get Vector data from WFS
    def getDatafromWFS(self, req, bboxrdnew, outdir, random):
        wfs = WFS(req, bboxrdnew, outdir, random)
        return wfs.getDataWFS()

    def _handler(self,request,response):
        # Outputs prepare
        outdata = io.StringIO()
        values = {}

        # Read configuration file
        self.readConfig()

        # Input parameters read
        # with open(self.jsonreq.getValue(), 'r') as f1:
        # logger.info(request.inputs['jsonreq'][0].file)
        with open(request.inputs['jsonreq'][0].file, 'r', encoding="utf-8") as f1:
        # with open(request.inputs['jsonreq'][0].file, 'r') as f1:
            reqstr = f1.read()

            data = json.loads(reqstr)
        logger.info(data)
        # Loop over requests
        files2zip = []
        for req in data:
            logger.info('''INPUT [downloadNHI]: {}'''.format(
                pprint.pformat(req)))

            # Request has to contain WORKSPACE:LAYER
            if not(':' in req['layername']):
                workspace = req['owsurl'].split('/')[-2]
                req['layername'] = workspace + ':' + req['layername']

            # Request has to be in same epsg, vector data is in rdnew
            [xmin, ymin, xmax, ymax] = req['latlonbox'].split(',')
            incrs = 'epsg:4326'
            crsdata = 'epsg:28992'
            (xmink, ymink) = change_coords(
                xmin, ymin, epsgin=incrs, epsgout=crsdata)
            (xmaxk, ymaxk) = change_coords(
                xmax, ymax, epsgin=incrs, epsgout=crsdata)
            logger.info('''input_coords [downloadNHI]: [{},{},{},{}]'''.format(
                xmin, ymin, xmax, ymax))
            logger.info('''change_coords [downloadNHI]: [{},{},{},{}]'''.format(
                xmink, ymink, xmaxk, ymaxk))
            bboxrdnew = (max(0, round(xmink / 500.0) * 500.0), round(ymink / 500.0)
                         * 500.0, round(xmaxk / 500.0) * 500.0, round(ymaxk / 500.0) * 500.0)
            logger.info('Rounded bbox: ' + str(bboxrdnew))

            # Distinguish between WCS/WFS/FULL
            logger.info(req['typereq'])
            if req['typereq'] == 'wfs' and not('dataurl' in req):
                # WFS request in RD_NEW, outputformat handled by owslib
                tempname = self.getDatafromWFS(
                    req, bboxrdnew, self.OUT_DIR, self.RANDOM)
                outfname = tempname

                # Reproject if needed
                # if req['outcrs'] != 'EPSG:28992':
                #outfname = tempname.replace(req['ext'], '_reproj'+req['ext'])
                #cmd = 'ogr2ogr -t_srs {} \"{}\" \"{}\"'.format(req['outcrs'], tempname, outfname)
                # logger.info(cmd)
                # os.system(cmd)
                # os.remove(tempname)
            # WCS
            elif req['typereq'] == 'wcs' and not('dataurl' in req):
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
                    logger.info(cmd)
                    os.system(cmd)
                    os.remove(tiffname)
                    tiffname = outfname  # replace

                # Format if needed
                if req['fformat'] != 'GTiff':
                    outfname = os.path.join(
                        self.OUT_DIR, req['outfname'] + '_' + self.RANDOM + req['ext'])
                    cmd = 'gdal_translate -of {} \"{}\" \"{}\"'.format(
                        req['fformat'], tiffname, outfname)
                    logger.info(cmd)
                    os.system(cmd)
                else:
                    outfname = tiffname
            # FULL
            else:
                # File to save and download url
                outfname = ''
                urldownload = ''

                if req['typereq'] == 'wfs':
                    # GEOSERVER WFS
                    outfname = os.path.join(
                        self.OUT_DIR, req['outfname'] + '_' + self.RANDOM + '.zip')
                    urldownload = req['owsurl'] + '?service=WFS&version=1.0.0&request=GetFeature&typeName={}&outputformat={}'.format(
                        req['layername'], req['fformat'])
                else:
                    # THREDDS - direct download [only if it is netcdf]
                    if req['dataurl'].endswith('.nc'):
                        urldownload = req['dataurl']
                        outfname = os.path.join(
                            self.OUT_DIR, req['outfname'] + '_' + self.RANDOM + '.nc')

                # DOWNLOAD
                if outfname != '':
                    url = urllib.request.URLopener()
                    url.retrieve(urldownload, outfname)

            # Add filename to zip
            if outfname != '':
                files2zip.append(outfname)

        # Zip all files
        zipfname = os.path.join(
            self.OUT_DIR, 'nhi_data_export_{}.zip'.format(self.RANDOM))
        zf = zipfile.ZipFile(zipfname, mode='w')
        os.chdir(self.OUT_DIR)
        for f in files2zip:
            bf = os.path.basename(f)
            logger.info('Adding to zipfile: {}'.format(bf))
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
        logger.info('''OUTPUT [downloadNHI]: {}'''.format(json_str))
        # self.json.setValue(outdata)
        response.outputs['json'].data = json_str
        return response

# if __name__ == "__main__":
#     proc = downloadNHI()
#     input = {}
#     proc.actualstuff()
