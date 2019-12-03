# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares
#       Joan Sala
#       joan.salacalero@deltares.nl
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

import os
import json
import configparser

# Read default configuration from file
def readConfig():
	# Default config file (relative path, does not work on production, weird)
	confpath = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'rc2ce_configuration.txt')
	if not os.path.exists(confpath):	
		confpath = '/opt/pywps/processes/ri2de_configuration.txt'
	# Parse and load
	cf = configparser.ConfigParser() 
	cf.read(confpath)
	return cf

# Write output
def writeOutput(cf, wmslayer, defstyle='ri2de'):
	res = dict()
	res['baseUrl'] = cf.get('GeoServer', 'wms_url')
	res['layerName'] = wmslayer
	res['style'] = defstyle
	return json.dumps(res)