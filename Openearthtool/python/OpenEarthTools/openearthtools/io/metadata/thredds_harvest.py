# -*- coding: utf-8 -*-
"""
Thredds 2 Geonetwork
a Thredds ISO harvester that places harvested metadata in GeoNetwork

$Id: thredds_harvest.py 12241 2015-09-16 13:09:40Z pronk_mn $
$Date: 2015-09-16 06:09:40 -0700 (Wed, 16 Sep 2015) $
$Author: pronk_mn $
$Revision: 12241 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/metadata/thredds_harvest.py $
$Keywords: $

#TODO Logging
#TODO Try Except

Should not be run as cronjob, only manually on Thredds.
"""

import urllib
from thredds_crawler.crawl import Crawl

from owslib.csw import CatalogueServiceWeb
import lxml.etree as ET
from StringIO import StringIO


# EDIT THESE VALUES
# Thredds Catalog
servers = {
    'jarkus': 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/jarkus/catalog.html'
}
# GeoNetwork CSW endpoint and credentials
geonetwork = {
    'host': 'http://_.deltares.nl:8080/geonetwork/srv/eng/csw-publication',
    'user': '_',
    'pass': '_'
}
# EDIT STOPS HERE

csw = CatalogueServiceWeb(geonetwork['host'],
                          username=geonetwork['user'],
                          password=geonetwork['pass'])
xslt = ET.parse(open('gmiTogmd.xsl'))

# Loop over servers
for server, thredds_url in servers.items():
    # Iniate crawler and filter on ISO service for all datasets
    crawler = Crawl(thredds_url)
    isos = [(d.id, s.get("url")) for d in crawler.datasets for s in d.services if 'ISO' in s.get("service")]
    # Loop over each ISO service
    for iso in isos:
        # Download ISO xml
        temp = StringIO(urllib.urlopen(iso[1]).read())
        # Parse XML and transform it using stylesheet
        dom = ET.parse(temp)
        transform = ET.XSLT(xslt)
        newdom = transform(dom)
        xml = ET.tostring(newdom)
        # Write transformed xml to GeoNetwork
        csw.transaction(ttype='insert', typename='gmd:MD_Metadata', record=xml)
