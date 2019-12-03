# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018-2019 Deltares
#       Joan Sala
#       joan.salacalero@deltares.nl
#       Gerrit Hendriksen
#       gerrit.hendriksen@deltares.nl
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

# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/ri2de/processes/utils.py $
# $Keywords: $

import time
import os
import json
import configparser

import sys
from owslib.fes import *
from owslib.etree import etree
from owslib.wfs import WebFeatureService

def clipfromwfs(wfs,layer,bbx,fn,srs=4326,of='shape-zip'):
    #wfs11 = WebFeatureService(url='http://localhost:8080/geoserver/global/ows?', version='1.1.0',timeout=320)
    wfs11 = WebFeatureService(url=wfs, version='1.1.0',timeout=640)
    try:
        #response = wfs11.getfeature(typename='global:glhymps', bbox=(75,24,78,26),srsname='urn:x-ogc:def:crs:EPSG:4326',outputFormat='shape-zip')   
        response = wfs11.getfeature(typename=layer, bbox=bbx,srsname='urn:x-ogc:def:crs:EPSG:{s}'.format(s=srs),outputFormat=of)   
        if os.path.isfile(fn):
            os.unlink(fn)
        out = open(fn, 'wb')
        out.write(response.read())
        out.close()
        return fn
    except:
        print(' '.join(['error occurred while clipping layer',layer,'from',wfs]))
        return None

# Get a unique temporary file
def tempfile(tempdir, typen, extension):
    fname = typen + str(time.time()).replace('.','')
    return os.path.join(tempdir, fname+extension)

# Read default configuration from file
def read_config():
	# Default config file (relative path, does not work on production, weird)
	confpath = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'ri2de_configuration.txt')
	if not os.path.exists(confpath):	
		confpath = '/opt/pywps/processes/ri2de_configuration.txt'
	# Parse and load
	cf = configparser.ConfigParser() 
	cf.read(confpath)
	return cf

# Read input [common parameters]
def read_input(request):
	layers_jsonstr = request.inputs["layers_setup"][0].data		
	layer_info = json.loads(layers_jsonstr)
	roads_id = request.inputs["roads_identifier"][0].data.strip()
	return layers_jsonstr, layer_info, roads_id

# Read input [common parameters]
def read_input_segments(request):
	buffer_dist = float(request.inputs["buffer_dist"][0].data)
	segment_length = float(request.inputs["segment_length"][0].data)
	return buffer_dist, segment_length

# Write output
def write_output(cf, wmslayer, defstyle='ri2de'):
	res = dict()
	res['baseUrl'] = cf.get('GeoServer', 'wms_url')
	res['layerName'] = wmslayer
	res['style'] = defstyle
	return json.dumps(res)
	
# Read default configuration from file
def read_setup():
	# Default layers file (relative path, does not work on production, weird)
	confpath = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'ri2de_layers.json')
	if not os.path.exists(confpath):	
		confpath = '/opt/pywps/processes/ri2de_layers.json'
	return confpath

# Read default susceptibilities configuration file
def read_susceptibilities():
	# Default layers file (relative path, does not work on production, weird)
	confpath = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'ri2de_susceptibilities.json')
	if not os.path.exists(confpath):	
		confpath = '/opt/pywps/processes/ri2de_susceptibilities.json'
	return confpath