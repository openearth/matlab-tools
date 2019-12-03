# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2015 Deltares
#       Joan Sala Calero
#
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

# $Id: layersCleanup.py 15858 2019-10-22 15:18:09Z pronk_mn $
# $Date: 2019-10-22 08:18:09 -0700 (Tue, 22 Oct 2019) $
# $Author: pronk_mn $
# $Revision: 15858 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/nhidataportaal/processes/layersCleanup.py $
# $Keywords: $

"""
Created on Tue Oct 13 14:22:36 2015
Regis (netcdf) Accessor
"""

from geoserver.catalog import Catalog
import os
import shutil
import configparser


# Read configuration from file
def readConfig(conf_file):
    cf = configparser.RawConfigParser()
    cf.read(conf_file)
    # Geoserver
    host = cf.get('GeoServer', 'host')
    user = cf.get('GeoServer', 'user')
    passw = cf.get('GeoServer', 'pass')
    # Directories
    bokehdir = cf.get('Bokeh', 'plots_dir')
    wpsoutdir = cf.get('Wps', 'wpsout_dir')
    return host, user, passw, bokehdir, wpsoutdir

# Clean all layers from a geoserver workspace


def cleanupGeoserver(host, user, passwd, workspace='NHIONLINE'):
    # Connection details
    cat = Catalog(host + '/rest', username=user, password=passwd)

    # First clean all layer groups
    lgs = cat.get_layergroups(workspace)
    for g in lgs:
        print(('Removing layerGroup -> ' + g.name))
        try:
            cat.delete(g)
            cat.reload()
        except Exception as e:
            print('Coud not delete layerGroup: '+g.name)
            print(e)

    # Then, remove layers and stores
    layers = cat.get_layers(workspace)
    for lay in layers:
        print(('Removing layer -> ' + lay.name))
        if 'isolines' in lay.name:
            storename = lay.name
        else:
            storename = lay.name + '_ds'

        # Layer
        try:
            cat.delete(lay)
            cat.reload()
        except Exception as e:
            print('Coud not delete layer: '+lay.name)
            print(e)

        # Store delete
        try:
            st = cat.get_store(storename)
            cat.delete(st)
            cat.reload()
        except Exception as e:
            print('Coud not delete datastore: '+storename)
    return

# Clean all directories from a temporal directory


def cleanupTempDirectory(tmpdir='D:\\Temp'):
    for root, dirs, files in os.walk(tmpdir, topdown=False):
        for name in dirs:
            if name.startswith('tmp'):
                path = os.path.join(root, name)
                print(('Removing -> ' + path))
                try:
                    shutil.rmtree(path)
                except:
                    print(('Could not remove -> ' + path))
                    pass
    return

# Clean all files from a temporal directory


def cleanupFilesDirectory(direc, exclude_ext='.txt'):
    for root, dirs, files in os.walk(direc, topdown=False):
        for name in files:
            path = os.path.join(root, name)
            if name.endswith(exclude_ext):
                print(('Skipping -> ' + path))
            else:
                print(('Removing -> ' + path))
                try:
                    os.unlink(path)
                except:
                    print(('Could not remove -> ' + path))
                    pass
    return


if __name__ == "__main__":
    CONFIG_FILE = os.path.join(os.path.dirname(
        os.path.realpath(__file__)), 'NHIconfig.txt')
    if os.path.exists(CONFIG_FILE):
        (host, user, passwd, bokehdir, wpsoutdir) = readConfig(CONFIG_FILE)
        cleanupFilesDirectory(bokehdir)
        cleanupFilesDirectory(wpsoutdir)
        cleanupTempDirectory()
        cleanupGeoserver(host, user, passwd)
        print('Finished Cleaning')
    else:
        print('Config file not found: ' + CONFIG_FILE)
