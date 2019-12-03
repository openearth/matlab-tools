# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
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
# $Keywords: $

import urllib2
import os
import geojson
from datetime import date

# Library SentinelSearch
from sentinelsat.sentinel import SentinelAPI

class SentinelSearch:
    def __init__(self, bbox, mission, tstart, tend, clouds, tmp_dir):
        # Variable params
        self.bbox = bbox
        self.mission = mission
        self.tstart = tstart
        self.tend = tend
        self.clouds = clouds

        # Fixed params
        self.maxresults = 100
        self.user = 'xxxx'
        self.passwd = 'yyyy'
        self.data_hub = 'https://scihub.copernicus.eu/dhus'

        # Temp params
        self.TMP_DIR = tmp_dir

    def searchQuery(self):
        # connect to the API
        self.api = SentinelAPI(self.user, self.passwd, 'https://scihub.copernicus.eu/dhus')

        # search by polygon, time, and Hub query keywords
        #footprint = geojson_to_wkt(read_geojson('map.geojson'))
        footprint = 'POLYGON (({x0} {y0}, {x0} {y1}, {x1} {y1}, {x1} {y0}, {x0} {y0}))'.format(x0=self.bbox[0],x1=self.bbox[2],y0=self.bbox[1],y1=self.bbox[3])

        self.products = self.api.query(footprint,
                             date=(self.tstart, self.tend),
                             platformname=self.mission,
                             cloudcoverpercentage=self.clouds)

        return len(self.products)

    def get_json(self):
        """ Convert search_result to JSON """
        return self.api.to_geojson(self.products)

    def get_df(self):
        """ Convert search_result to Pandas dataframe """
        return self.api.to_dataframe(self.products)

    def download_all(self):
        self.api.download_all(self.products, directory_path=self.TMP_DIR)

    def download_id(self, product_id):
        self.api.download(product_id, directory_path=self.TMP_DIR)

    def download_preview(self, url):
        # Create a password manager
        manager = urllib2.HTTPPasswordMgrWithDefaultRealm()
        manager.add_password(None, url, self.user, self.passwd)
        # Create an authentication handler using the password manager
        auth = urllib2.HTTPBasicAuthHandler(manager)
        # Create an opener that will replace the default urlopen method on further calls
        opener = urllib2.build_opener(auth)
        urllib2.install_opener(opener)
        # Here you should access the full url you wanted to open
        response = urllib2.urlopen(url)
        # Save it to file
        f = open(os.path.join(self.TMP_DIR, 'sentinel_preview.png'), 'wb')
        f.write(response.read())
        f.close()

## ======== TEST ========
def lessCloudsWithinDates(download_full, outfname, mission, clouds, bbox, t0, t1, tmp_dir):
    print 'Sentinel Query ## Mission = {} BBOX = {} Timespan (t0,t1) = ({} -> {})'.format(mission, bbox, t0, t1)

    # Initiate SentinelSearch class
    sr = SentinelSearch(bbox, mission, t0, t1, clouds, tmp_dir)

    # Make query
    n = sr.searchQuery()
    df = sr.get_df()
    print 'Results found -> {} products)'.format(n)

    # Save search result as json [pretty print]
    json_str = sr.get_json()
    parsed = geojson.loads(str(json_str))
    with open(outfname, 'wb') as f:
        f.write(geojson.dumps(parsed, indent=4, sort_keys=True))

    # Search the image with less cloud coverage
    cloudcover = 100.0
    id_to_download = None
    link_icon = None
    for index, row in df.iterrows():
        print row['summary']
        if 'cloudcoverpercentage' in row:
            ccp = float(row['cloudcoverpercentage'])
            if ccp < cloudcover:
                cloudcover = ccp
                id_to_download = row['uuid']
                link_icon = row['link_icon']

    # Download preview if available
    if id_to_download != None and not(download_full):
        print 'Selected for preview: ' + id_to_download
        sr.download_preview(link_icon)

    # Download FULL IMAGE if available
    if id_to_download != None and download_full:
        print 'Selected for download: ' + id_to_download
        sr.download_id(id_to_download)

## ======== MAIN ======== [ Class test ]
if __name__ == "__main__":
    print 'SentinelSearch loaded'
    #tmp_dir='../tmp_data'
    #download_full = False # download preview or get image
    #outfname = '../tmp_data/search_sentinel.json'
    #mission = 'Sentinel-2'
    #clouds = (0, 20)
    #bbox = (2.097, 52.715, 4.277, 53.935)
    #t0 = date(2017, 11, 06)
    #t1 = date(2017, 11, 12)  # the week before the workshop
    #lessCloudsWithinDates(download_full, outfname, mission, clouds, bbox, t0, t1, tmp_dir)