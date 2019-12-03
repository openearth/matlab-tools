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

# $Id: nhimodel_outputs.py 13820 2017-10-12 12:36:42Z sala $
# $Date: 2017-10-12 14:36:42 +0200 (Thu, 12 Oct 2017) $
# $Author: sala $
# $Revision: 13820 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/onlinemodelling/nhimodel_outputs.py $
# $Keywords: $

# core
import os
import logging
import requests
import psycopg2
import zipfile

# modules
from requests.auth import HTTPBasicAuth
from geoserver.catalog import Catalog
from nhimodel_config import nhimodel_CONF

"""
NHI online modelling input/output functions
- create ouputs
- connect to GeoServer
"""

class nhimodel_IO():

    def __init__(self, c): 
        self.config = c   

    # Group layers (raster + isolines)
    def geoserverGroupLayers(self, name, layer, layeriso, sld_layer='nhiraster', sld_layeriso='nhisolines'):
        # Define layer group
        layergroup="""<layerGroup>
          <name>{}</name>
          <layers>
             <layer>{}</layer>
             <layer>{}</layer>
          </layers>
          <styles>
             <style>{}</style>
             <style>{}</style>
          </styles>
        </layerGroup>""".format('LG_'+name, layer, layeriso, sld_layer, sld_layeriso)

        # Publish GeoTiff on Geoserver        
        r = requests.post(self.config['GEOSERVER_HOST'] + "/rest/workspaces/NHIONLINE/layergroups", 
        headers={'Content-type': 'text/xml'},
        data=layergroup,
        auth=HTTPBasicAuth(self.config['GEOSERVER_USER'], self.config['GEOSERVER_PASS']))
        logging.info('''GEOSERVER [groupLayersREST]: code={}'''.format(r.status_code))

    # Upload file to GeoServer
    def geoserverUploadShp(self, zippath, tmpdir, sld_style='nhisolines'):
        # Return wms url        
        layername = os.path.basename(tmpdir)+'_isolines'
        wmslay = 'NHIONLINE:'+layername
        logging.info('''GEOSERVER [nhimodel]: wmslayer={}'''.format(wmslay))

        # Publish SHP on Geoserver
        resource = 'rest/workspaces/NHIONLINE/datastores/'+layername+'/file.shp'
        file_name = os.path.basename(zippath)
        headers = {'content-type': 'application/zip'}
        auth = HTTPBasicAuth(self.config['GEOSERVER_USER'], self.config['GEOSERVER_PASS'])

        request_url = self.config['GEOSERVER_HOST'] + '/' + resource
        with open(zippath, 'rb') as f:
            r = requests.put(
                request_url,
                data=f,
                headers=headers,
                auth=auth
            )
            logging.info('''GEOSERVER [uploadREST]: code={}'''.format(r.status_code))            
        
        # Associate SLD styling to it
        self.addSLD(layername, sld_style)
        return wmslay

    # Upload file to GeoServer
    def geoserverUploadGtif(self, gtifpath, tmpdir, sld_style='nhiraster'):
        # Return wms url
        layername = os.path.basename(tmpdir)
        wmslay = 'NHIONLINE:'+layername
        logging.info('''GEOSERVER [nhimodel]: wmslayer={}'''.format(wmslay))

        # Publish GeoTiff on Geoserver        
        r = requests.put(self.config['GEOSERVER_HOST'] + "/rest/workspaces/NHIONLINE/coveragestores/" + layername + "_ds/external.geotiff?configure=first\&coverageName="+layername,
        headers={'Content-type': 'text/plain'},
        data='file://'+gtifpath,
        auth=HTTPBasicAuth(self.config['GEOSERVER_USER'], self.config['GEOSERVER_PASS']))
        logging.info('''GEOSERVER [uploadREST]: code={}'''.format(r.status_code))

        # Associate SLD styling to it
        self.addSLD(layername, sld_style)
        return wmslay

    # Add sld styling for a given layer
    def addSLD(self, layername, sld_style):
        cat = Catalog(self.config['GEOSERVER_HOST']+'/rest', username=self.config['GEOSERVER_USER'], password=self.config['GEOSERVER_PASS'])
        
        # check if style/layer exists
        if cat.get_style(sld_style) == False:
            logging.info('Style {} not found'.format(sld_style))
        if cat.get_layer(layername) == False:
            logging.info(' '.join(['layer',layername,'not found']))
        
        try:
            layer = cat.get_layer(layername)
            logging.info('before setting style')
            layer._set_default_style(sld_style)
            # Update and save layer
            cat.save(layer)
            cat.reload()
        except:
            logging.info('ERROR while connecting to geoserver to change SLD styling')
            pass        


    # Check on postgres if X,Y is inside layer L
    def insideLayer(self, xin, yin, layernbin, epsgin=28992):
        try:
            conn = psycopg2.connect("""dbname='{d}' user='{u}' host='{h}' password='{p}'""".format(d=self.config['POSTGIS_DB'], u=self.config['POSTGIS_USER'], h=self.config['POSTGIS_HOST'], p=self.config['POSTGIS_PASS']))
            cur = conn.cursor()
            sqlquery = """SELECT st_value(rast,st_setsrid(st_point({x},{y}),{epsg})) FROM ibound{layernb} WHERE ST_Intersects(rast,st_setsrid(st_point({x},{y}),{epsg}));""".format(x=xin,y=yin,epsg=epsgin,layernb=layernbin)
            logging.info(sqlquery)
            cur.execute(sqlquery)
            rows = cur.fetchall()
            return rows[0][0]==1.0 # return inside boolean
        except Exception as e:
            s = str(e)
            logging.info('ERROR -> ' + s)
            return False # return outside boolean

    # Add file to zip
    def zipAdd(self, zf, file):
        logging.info('Adding file to zip: {}'.format(file))
        zf.write(file)

    # Create shapefile zip to upload to geoserver
    def zipShp(self, shppath):
        # Path setup
        dirname = os.path.dirname(shppath)
        baseshp = os.path.basename(shppath)
        cwd = os.getcwd()
        os.chdir(dirname)
        
        # Files to zip
        zippath = os.path.join(dirname, 'isolines.zip')
        dbffile = baseshp.replace('.shp', '.dbf')
        shxfile = baseshp.replace('.shp', '.shx')        
        prjfile = baseshp.replace('.shp', '.prj')
        zf = zipfile.ZipFile(zippath, mode='w')
        
        # Create RD_NEW prj
        with open(prjfile, "w") as prjf:
            prjstr = 'PROJCS["Amersfoort_RD_New",GEOGCS["GCS_Amersfoort",DATUM["D_Amersfoort",SPHEROID["Bessel_1841",6377397.155,299.1528128]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]],PROJECTION["Double_Stereographic"],PARAMETER["latitude_of_origin",52.15616055555555],PARAMETER["central_meridian",5.38763888888889],PARAMETER["scale_factor",0.9999079],PARAMETER["false_easting",155000],PARAMETER["false_northing",463000],UNIT["Meter",1]]'
            prjf.write(prjstr)

        # Zip all
        logging.info('[ZIP] - Creating zip file')
        try:
            self.zipAdd(zf, baseshp)
            self.zipAdd(zf, shxfile)
            self.zipAdd(zf, dbffile)
            self.zipAdd(zf, prjfile)         
        finally:
            zf.close()
            os.chdir(cwd)
        return zippath

if __name__ == "__main__":
    # Read config    
    conf = nhimodel_CONF('./NHIconfig.txt')
    conf_dict = conf.readConfig()
    nio = nhimodel_IO(conf_dict)

    # Temporary directory
    layername = 'NHIONLINE:tmp7mxgzi_isolines'
    sld_style = 'nhisolines'

    # Test add SLD to SHP    
    #nio.addSLD(layername, sld_style)
