# core
import os
import logging
import requests

# modules
from requests.auth import HTTPBasicAuth
from geoserver.catalog import Catalog

# local
from config import *

class utilsGeoserver():

    def __init__(self, c): 
        self.config = c   

    # Upload file to GeoServer
    def geoserverUploadGtif(self, gtifpath, wkspace, sld_style='waterdiepte'):
        # Return wms url
        layername = os.path.basename(gtifpath).replace('.tif', '')
        wmslay = wkspace+layername
        print('''GEOSERVER: wmslayer={}'''.format(wmslay))

        # Publish GeoTiff on Geoserver        
        url = self.config['GEOSERVER_HOST'] + "/rest/workspaces/{}/coveragestores/".format(wkspace) + layername + "_ds/external.geotiff?configure=first\&coverageName="+layername
        print url
        r = requests.put(
                url,
                headers={'Content-type': 'text/plain'},
                data='file://'+gtifpath,
                auth=HTTPBasicAuth(self.config['GEOSERVER_USER'], self.config['GEOSERVER_PASS'])
            )

        # Associate SLD styling to it
        if r.status_code < 300:
            self.addSLD(layername, sld_style)
        else:
            print('''GEOSERVER [uploadREST]: code={}'''.format(r.status_code))
            print('''GEOSERVER [uploadREST]: msg={}'''.format(r.text))          
        return wmslay

    # Add sld styling for a given layer
    def addSLD(self, layername, sld_style):
        cat = Catalog(self.config['GEOSERVER_HOST']+'/rest', username=self.config['GEOSERVER_USER'], password=self.config['GEOSERVER_PASS'])
        
        # check if style/layer exists
        if cat.get_style(sld_style) == False:
            print('Style {} not found'.format(sld_style))
        if cat.get_layer(layername) == False:
            print(' '.join(['layer',layername,'not found']))
        
        try:
            layer = cat.get_layer(layername)
            layer._set_default_style(sld_style)
            # Update and save layer
            cat.save(layer)
            cat.reload()
        except:
            print('ERROR while connecting to geoserver to change SLD styling')
            pass        

    # Resample and fix header
    def resampleTiff(self, intif, ind, outd, res):
        # RDNEW
        outif = os.path.join(outd, intif.replace('.tif', '_{r}m.tif'.format(r=res)))
        crs_in = "EPSG:28992"
        crs_out = "EPSG:28992"
        cmd = """gdalwarp -overwrite -co "TILED=YES" -s_srs "{ci}" -t_srs "{co}" -tr {r} {r} {i} {o}""".format(
            ci=crs_in, co=crs_out, r=res, i=os.path.join(ind, intif), o=outif)
        os.system(cmd)
        return outif
