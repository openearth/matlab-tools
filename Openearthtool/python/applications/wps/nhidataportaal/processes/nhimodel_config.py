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

# $Id: nhimodel_config.py 15858 2019-10-22 15:18:09Z pronk_mn $
# $Date: 2019-10-22 08:18:09 -0700 (Tue, 22 Oct 2019) $
# $Author: pronk_mn $
# $Revision: 15858 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/nhidataportaal/processes/nhimodel_config.py $
# $Keywords: $

import configparser

"""
NHI online modelling configuration functions
- create ouputs
- connect to GeoServer
"""


class nhimodel_CONF():
    def __init__(self, conf_file_path):
        self.CONFIG_FILE = conf_file_path

    # Read configuration from file
    def readConfig(self):
        cf = configparser.RawConfigParser()
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
        # IMODFLOW
        conf_dict['EXE_LOCATION'] = cf.get('iMOD', 'exe_location')
        conf_dict['EXE_NAME'] = cf.get('iMOD', 'exe_name')
        conf_dict['HEADS_DIR'] = cf.get('iMOD', 'heads_dir')

        return conf_dict
