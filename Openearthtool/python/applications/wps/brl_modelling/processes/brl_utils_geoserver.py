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

# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/brl_modelling/processes/brl_utils_geoserver.py $
# $Keywords: $

import os
from geoserver.catalog import Catalog
from requests.auth import HTTPBasicAuth
import requests

def geoserverUploadGTIFF(cf, gtifpath, workspace='brl', sld_style='br'):
    coveragestore = os.path.basename(gtifpath).replace('.tif','')

    #Publish Geotiff on Geoserver
    requests.put(cf.get('GeoServer','rest_url') + "/workspaces/"+ workspace  + "/coveragestores/" + coveragestore + "/external.geotiff?configure=first&coverageName="+coveragestore,
                     headers={'Content-Type': 'GeoTIFF'},
                     data=gtifpath,
                     auth=HTTPBasicAuth(cf.get('GeoServer','user'), cf.get('GeoServer','pass')))
   
    #Associate SLD styling to layer
    requests.put(cf.get('GeoServer','rest_url') + "/layers/"+ workspace  + ':' + coveragestore,
                                      auth=HTTPBasicAuth(cf.get('GeoServer','user'), cf.get('GeoServer','pass')),
                                      data='<layer><defaultStyle><name>' +workspace + ':' + sld_style + '</name></defaultStyle></layer>',
                                      headers={'content-type': 'text/xml'})
    
    addsld(cf, gtifpath)
    wmslay = workspace+':'+coveragestore
    return wmslay

def addsld(cf, gtifpath, workspace='brl', sld_style='brl'):
    layername = os.path.basename(gtifpath).replace('.tif','')
    cat = Catalog(cf.get('GeoServer', 'rest_url'), username=cf.get('GeoServer', 'user'), password=cf.get('GeoServer', 'pass'))

    # Associate SLD styling to it
    layer = cat.get_layer(layername)
    layer.default_style = cat.get_style(sld_style) 
    cat.save(layer)
    cat.reload()

# Uplocondaad raster file to GeoServer
def geoserver_upload_gtif(cf, layername, gtifpath, sld_style='brl', workspace='brl'):
    
    # Connect and get workspace
    print(gtifpath)
    print(layername)
    cat = Catalog(cf.get('GeoServer', 'rest_url'), username=cf.get('GeoServer', 'user'), password=cf.get('GeoServer', 'pass'))
    ws = cat.get_workspace(workspace)

    # Create store
    try:
        layer = cat.create_coveragestore(name=layername, workspace=ws, path=gtifpath)
    except:
        print('did no succeed in creating the coveragestore')

    # Associate SLD styling to it
    layer = cat.get_layer(layername)
    layer.default_style = cat.get_style(sld_style) 
    cat.save(layer)
    cat.reload()

    # Return wms url
    wmslay = workspace+':'+layername    
    return wmslay

# Cleanup temporary layers and stores
def cleanup_temp(cf, workspace='TEMP'):

    # Connect and get workspace
    cat = Catalog(cf.get('GeoServer', 'rest_url'), username=cf.get('GeoServer', 'user'), password=cf.get('GeoServer', 'pass'))
    
    # Layers
    layers = cat.get_layers()
    for l in layers:
        if (workspace+':') in l.name:
            print('Deleting layer = {}'.format(l.name))
            try:
                cat.delete(l)
                print('OK')
            except:
                print('ERR')
    cat.reload()
    
    # Stores
    stores = cat.get_stores()        
    print('-------------------')
    for s in stores:
        if workspace in s.workspace.name:
            print('Deleting store = {}'.format(s.name))
            try:
                cat.delete(s)
                print('OK')
            except:
                print('ERR')
    cat.reload()
