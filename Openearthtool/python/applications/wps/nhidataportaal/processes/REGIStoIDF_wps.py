#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares for <projectdata>
#       Lilia Angelova
#
#       Lilia.Angelova@deltares.nl
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

# http://aw-060.xtr.deltares.nl:8080/gmdb/cgi-bin/pywps.cgi?service=wps&version=1.0.0&request=Execute&identifier=REGIStoIDF_wps&datainputs=[epsg=4326;latlonbox=130100,139600,449800,462900]

# core
import os
import tempfile
import logging
import time
import configparser
import zipfile
import string
import random
# modules
import simplejson as json
from os.path import normpath, basename
import io
from pywps import Format
from pywps.app import Process
from pywps.inout.inputs import ComplexInput, LiteralInput
from pywps.inout.outputs import LiteralOutput,ComplexOutput
from pywps.app.Common import Metadata
from pywps.inout.formats import FORMATS

# other
#from REGISnc_to_ASCII import *
from .REGIStoIDF import *
logger = logging.getLogger('PYWPS')
# Default config file (relative path)
CONFIG_FILE = os.path.join(os.path.dirname(
    os.path.realpath(__file__)), 'regis_idf_config.txt')
cur_time = time.time()


class REGIStoIDF_wps(Process):
    # Fill in from configuration
    OUT_DIR = ''

    def __init__(self):
        # init process; note: identifier must be same as filename
        inputs = [LiteralInput(identifier="epsg",
                                            title="EPSG code of the input coordinate system.",
                                            abstract="input=mapselection",
                                            default='3857'),
                  LiteralInput(identifier="latlonbox",
                                             title="Bounding box [in latlon RD-28992].",
                                             default='621446,6707268,630757,6730545')]

        outputs = [ComplexOutput(identifier="json",
                                          title="Returns list of values for specified xy",
                                          abstract="""Returns list of values for specified xy""",
                                          supported_formats=[Format("text/plain"),Format("application/json")])]
        super(REGIStoIDF_wps,self).__init__(
                            self._handler,
                            identifier="REGIStoIDF_wps",
                            title="Download REGIS data by bounding box.",
                            version="1.3.3.7",
                            store_supported="true",
                            status_supported="true",
                            abstract="""This function allows you to download REGIS data as a gzip.""",
                            grass_location=False,
                            inputs=inputs,
                            outputs=outputs)

    # Read configuration from file

    def readConfig(self):
        cf = configparser.RawConfigParser()
        cf.read(CONFIG_FILE)
        self.OUT_DIR = cf.get('Wps', 'files_dir')
        self.apache_dir = cf.get('Wps', 'apache_dir')
        self.RANDOM = ''.join(random.choice(string.ascii_uppercase + string.digits)
                              for _ in range(7))  # random identifier for files
        logger.info(self.RANDOM)

    def _handler(self,request,response):
        # Outputs prepare
        outdata = io.StringIO()
        values = {}
#        logger.info("INPUT EPSG IS: {}".format(self.epsginput.getValue()))
#        logger.info("INPUT BBOX IS: {}".format(self.latlonbox.getValue()))
        # Read configuration file
        self.readConfig()

        # format inputs
        bboxinput = tuple(float(x)
                          # for x in self.latlonbox.getValue().split(","))
                          for x in request.inputs['latlonbox'][0].data.split(","))
        # epsg = "epsg:{}".format(self.epsginput.getValue())
        epsg = "epsg:{}".format(request.inputs['epsginput'][0].data)

        tempdir = tempfile.mkdtemp(dir=self.OUT_DIR)
        SOURCE = "http://www.dinodata.nl:80/opendap/REGIS/REGIS.nc"
        path = os.path.join(tempdir)
        LAYERS = ['kv', 'kh', 'top', 'bottom']
        write_to_IDF(SOURCE, path, bboxinput, LAYERS, epsg)
#        write_to_ASCII(SOURCE,path,bboxinput,LAYERS,epsg)

        # zip files
        path_files = path
        zipf = zipfile.ZipFile(
            os.path.join(path_files, "{}.zip".format(self.RANDOM)),
            "w",
            zipfile.ZIP_DEFLATED,
        )
        for root, dirs, files in os.walk(path_files):
            for file in files:
                if file.endswith(".idf"):
                    zipf.write(os.path.join(root, file), file)
                    os.remove(os.path.join(root, file))  # clean
        zipf.close()

        tempfolder = basename(normpath(tempdir))

        # Send back result JSON
        values['url_data'] = self.apache_dir + "/" + \
            tempfolder + "/" + '{}.zip'.format(self.RANDOM)
        json_str = json.dumps(values)
        # outdata.write(json_str)
        # logger.info('''OUTPUT [downloadNHI]: {}'''.format(json_str))
        # self.json.setValue(outdata)
        response.outputs['json'].data = json_str
        return response
