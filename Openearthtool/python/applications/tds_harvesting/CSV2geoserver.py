#!/usr/bin/env python

""" Python script to update a GeoServer from an opendap server TDS

- Read information from CSV [layer, workspace, style]
- Create netcdf datastore
- Create layer + workspace

"""

__author__ = "Joan Sala Calero"
__version__ = "0.1"
__email__ = "joan.salacalero@deltares.nl"
__status__ = "Prototype"

import zipfile
import os
import csv
import requests
from requests.auth import HTTPBasicAuth
from geoserver.catalog import Catalog

# Find a row in a csv
def find_row_csv(fname, csv_file):
    with open(csv_file, 'rb') as csvfile:
        reader = csv.reader(csvfile, delimiter=';', quotechar='|')
        for row in reader:
            if row[0] == fname: return row

# Upload netcdf file to GeoServer
def geoserverUploadNetcdf(user, passw, host, netcdfpath, workspace, sld_style, layertitle):
    # Init parameters
    fname = os.path.basename(netcdfpath)
    coveragename = fname.replace('.nc', '')
    credentials = HTTPBasicAuth(user, passw)

    # Try to create workspace
    cat = Catalog(host_rest, username, password)
    try:
        cat.create_workspace(workspace, workspace)  # name, uri are the same
    except:
        pass  # Workspace already exists

    # Zip the nc file into a zip
    zfile = netcdfpath.replace('.nc', '.zip')
    output = zipfile.ZipFile(zfile, 'w')
    output.write(netcdfpath, fname, zipfile.ZIP_DEFLATED)
    output.close()

    # Upload zipped netcdf
    with open(output.filename, 'rb') as zip_file:
        r = requests.put(
            host + "/workspaces/" + workspace + "/coveragestores/" + coveragename + "/file.netcdf",
            auth=credentials,
            data=zip_file,
            headers={'content-type': 'application/zip'})
        print('''GEOSERVER [upload-Netcdf-REST]: code={}'''.format(r.status_code))

        r_change_name = requests.put(
            host + "/workspaces/" + workspace + "/coveragestores/" + coveragename + "/coverages/Band1",
            auth=credentials,
            data='<coverage><name>' + coveragename + '</name><title>' + layertitle + '</title><enabled>true</enabled></coverage>',
            headers={'content-type': 'text/xml'})
        print('''GEOSERVER [rename-Netcdf-REST]: code={}'''.format(r_change_name.status_code))

        # Rename and associate SLD styling to it
        if r.status_code < 300:
            addSLD(user, passw, host, coveragename, sld_style)


# Add sld styling for a given layer
def addSLD(user, passw, host, coveragename, sld_style):
    cat = Catalog(host, username=user, password=passw)

    # check if style/layer exists
    if cat.get_style(sld_style) == None:
        print('Style {} not found'.format(sld_style))
    if cat.get_layer(coveragename) == None:
        print(' '.join(['layer', coveragename, 'not found']))

    try:
        layer = cat.get_layer(coveragename)
        print('before setting style')
        layer._set_default_style(sld_style)
        # Update and save layer
        cat.save(layer)
        cat.reload()
    except:
        print('ERROR while connecting to geoserver to change SLD styling')
        pass

if __name__ == '__main__':

    # Configuration
    csv_file = 'indeling-modelbestanden-nhi-dataportaal.csv'
    directory_netcdfs = './iso_modellen'

    # Geoserver configuration
    host_rest = "http://modeldata-nhi-data.deltares.nl/geoserver/rest"
    username = "admin"
    password = "bfZT4hY9eaBpU8Jw3LUW"

    # Crawl directories
    for root, subdirs, files in os.walk(directory_netcdfs):
        for filename in files:
            if filename.endswith('.nc'):
                file_path = os.path.join(root, filename)
                row = find_row_csv(filename, csv_file)
                if row != None:
                    ds,tit,ws,sld,path = row
                    print 'Uploading FILE = {} to geoserver on WS = {} with SLD = {} and title={}'.format(filename, ws, sld, tit)
                    # Upload and create workspace and coveragestore and associate styling
                    geoserverUploadNetcdf(username, password, host_rest, file_path, ws, sld, tit)
                else:
                    print 'ERROR: could not find {}'.format(filename)
