# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
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

# $Id: onttrekking_config.py 13630 2017-09-01 09:12:48Z sala $
# $Date: 2017-09-01 11:12:48 +0200 (Fri, 01 Sep 2017) $
# $Author: sala $
# $Revision: 13630 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/zeeland/onttrekking_config.py $
# $Keywords: $

import ConfigParser

"""
NHI online modelling configuration functions
- create ouputs
- connect to GeoServer
"""

class onttrekking_CONF():
    def __init__(self, conf_file_path): 
        self.CONFIG_FILE = conf_file_path

    # Read configuration from file
    def readConfig(self):
        cf = ConfigParser.RawConfigParser()  
        cf.read(self.CONFIG_FILE)
        conf_dict = dict()
        # Geoserver
        conf_dict['GEOSERVER_HOST'] = cf.get('GeoServer', 'host')
        conf_dict['GEOSERVER_USER'] = cf.get('GeoServer', 'user')
        conf_dict['GEOSERVER_PASS'] = cf.get('GeoServer', 'pass')
        # PostGIS
        conf_dict['POSTGIS_HOST'] = cf.get('PostGIS', 'host')
        conf_dict['POSTGIS_USER'] = cf.get('PostGIS', 'user')
        conf_dict['POSTGIS_DB'] = cf.get('PostGIS', 'db')
        conf_dict['POSTGIS_PASS'] = cf.get('PostGIS', 'pass')
        conf_dict['POSTGIS_PORT'] = cf.get('PostGIS', 'port') 
        # Script location
        conf_dict['ONTSCRIPT'] = cf.get('Wps', 'ontscript') 
        return conf_dict

    