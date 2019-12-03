# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2019 Deltares
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

# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/brl_modelling/processes/brl_utils.py $
# $Keywords: $

import os
import json
import sys
import time
import configparser

# Get a unique temporary file
def tempfile(tempdir, typen, extension):
    fname = typen + str(time.time()).replace('.','')
    return os.path.join(tempdir, fname+extension)

# Read default configuration from file
def read_config():
	# Default config file (relative path, does not work on production, weird)
    if os.name == 'nt':
        devpath = r'D:\projecten\datamanagement\rws\BasisRivierbodemLigging\wps_brl_modelling\processes'
        confpath = os.path.join(devpath,'brl_configuration_local.txt')
    else:
        confpath = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'brl_configuration.txt')
    if not os.path.exists(confpath):	
        confpath = '/opt/pywps/processes/brl_configuration.txt'
	# Parse and load
    cf = configparser.ConfigParser() 
    print(confpath)
    cf.read(confpath)
    return cf

def gettmpdir():
    import tempfile
    tmpdir = tempfile.gettempdir()
    return tmpdir

# Read input [common parameters]
def read_input(request):
	setup_jsonstr = request.inputs["model_setup"][0].data		
	model_setup = json.loads(setup_jsonstr)
	waters_id = request.inputs["waters_identifier"][0].data.strip()
	print(setup_jsonstr)
	return model_setup, waters_id

# Write output
def write_output(cf, wmslayer, defstyle='brl'):
	res = dict()
    #for testing
	if defstyle=='brl':
		res['baseUrl'] = cf.get('GeoServer', 'wms_url')
		res['layerName'] = wmslayer
		res['style'] = defstyle
	else:
		res['baseUrl'] = 'https://ri2de.openearth.eu/geoserver/wms?'
		res['layerName'] = 'brl:difhead_waters_1573832155882882'
		res['style'] = 'tmp'    
	return json.dumps(res)
