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

from geoserver.catalog import Catalog
from sqlalchemy import create_engine

import re
import os
import shutil
import ConfigParser

# Clean all layers from a geoserver workspace
def cleanupGeoserver(host, user, passwd):
    # Connection details
    cat=Catalog(host + '/rest', username=user, password=passwd)
    
    # First clean all layers   
    layers = cat.get_layers()
    pattern1 = re.compile("^tempresults_(\w)+$") # temp style [static]
    pattern2 = re.compile("^tmpsld_(\w)+$") # temp style [dynamic]
    for lay in layers:         
        # Layer
        try:                        
            if pattern1.match(lay.default_style.name) or pattern2.match(lay.default_style.name):
                print('Removing layer -> ' + lay.name)
                cat.delete(lay)
                cat.reload()


        except Exception as e:
            print 'Coud not delete layer: '+lay.name
            print e 

    # Then delete dynamic styles
    slds = cat.get_styles()
    pattern = re.compile("^tmpsld_(\w)+$") # temp style
    for sld in slds:         
        # Layer
        try:                        
            if pattern.match(sld.name):
                print('Removing sld -> ' + sld.name)
                cat.delete(sld)
                cat.reload()            
        except Exception as e:
            print 'Coud not delete sld: '+sld.name
            print e 

    return

# Clean all directories from a temporal directory
def cleanupTempDirectory(tmpdir='D:\\Temp'):
    for root, dirs, files in os.walk(tmpdir, topdown=False):
        for name in dirs:            
            if name.startswith('tmp'):
                path=os.path.join(root, name)
                print('Removing -> ' + path)
                try:
                    shutil.rmtree(path)
                except:
                    print('Could not remove -> ' + path)
                    pass
    return

# Clean all files from a temporal directory
def cleanupFilesDirectory(direc, exclude_ext='.txt'):
    for root, dirs, files in os.walk(direc, topdown=False):        
        for name in files:  
            path=os.path.join(root, name)         
            if name.endswith(exclude_ext):
                print('Truncating -> ' + path)
                fo = open(path, "w")
                fo.truncate()
            else:                
                print('Removing -> ' + path)
                try:
                    os.unlink(path)
                except:
                    print('Could not remove -> ' + path)
                    pass
    return

# Cleanup postgis temporary layers
def cleanupPostGIS(cf, DB, schema='tempresults'):
    engine_temp = create_engine('postgresql+psycopg2://'+cf.get('PostGIS', 'user')
    +':'+cf.get('PostGIS', 'pass')+'@'+cf.get('PostGIS', 'host')+':'+str(cf.get('PostGIS', 'port'))
    +'/'+DB, strategy='threadlocal')

    sqlStr = 'DROP schema {s} CASCADE; CREATE SCHEMA {s}'.format(s=schema)
    engine_temp.execute(sqlStr)

if __name__ == "__main__":
    CONFIG_FILE=os.path.join(os.path.dirname(os.path.realpath(__file__)), 'blue2_config.txt')
    if os.path.exists(CONFIG_FILE):
        # Read config
        cf = ConfigParser.RawConfigParser()  
        cf.read(CONFIG_FILE)
    
        cleanupFilesDirectory(cf.get('Bokeh', 'plots_dir'))
        cleanupFilesDirectory(cf.get('Wps', 'wpsout_dir'))
        cleanupTempDirectory()
        cleanupGeoserver(cf.get('GeoServer', 'host'), cf.get('GeoServer', 'user'), cf.get('GeoServer', 'pass'))  
        cleanupPostGIS(cf, cf.get('PostGIS', 'db_temp')) # temp results
        cleanupPostGIS(cf, cf.get('PostGIS', 'db_generation')) # temp results

        print 'Finished Cleaning'
    else:
        print 'Config file not found: ' + CONFIG_FILE
