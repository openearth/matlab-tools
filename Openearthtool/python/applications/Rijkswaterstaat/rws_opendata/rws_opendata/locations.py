#!/usr/bin/env python
import json
import os
import contextlib
import logging

import requests
import osgeo.osr
import pandas
from lxml import etree
import numpy as np

from . import URLS
from beaker.cache import cache_regions, cache_region


cache_regions.update({
    'long_term':{
        'expire':1800,
        'type':'dbm',
        'key_length': 250,
        'data_dir':'/tmp',
    }
})

WGS84 = osgeo.osr.SpatialReference()
RD = osgeo.osr.SpatialReference()
# Use A list, should have latitude -> north
WGS84.ImportFromEPSGA(4326)
RD.ImportFromEPSGA(28992)

assert np.isclose(RD.GetTOWGS84()[0], 565.417), "Oops, 28992 projection should have a ToWGS84 parameter, the proj/ogr/gdal projection tables are wrong."


def parse(xmlbytes):
    '''Parse locations from XML url, convert coordinates and return as pandas DataFrame'''

    xml = etree.XML(xmlbytes)
    locations = []

    # loop over all locations
    locs = xml.findall('.//{%s}li' % xml.nsmap['rdf'])
    for loc in locs:

        # parse geometry (point)
        geom   = loc.find('.//{%s}geometry' % loc.nsmap['wadi'])
        coords = [float(x) for x in geom.find('.//{%s}Coordinates' % geom[0].nsmap['gml']).text.split(',')]
        epsg   = geom.find('.//{%s}Point' % geom[0].nsmap['gml']).attrib['srsName']
        epsg_int = int(epsg.lstrip('EPSG:'))

        crs = osgeo.osr.SpatialReference()
        crs.ImportFromEPSGA(epsg_int) # use appended table by default

        if not crs.ExportToWkt():
            # if we don't have a wkt, epsg was invalid and we'll use 28992
            logging.debug("EPSG code invalid: {} {}".format(epsg,  etree.tostring(loc)))
            crs = RD

        crs2wgs84 = osgeo.osr.CoordinateTransformation(crs, WGS84)
        crs2rd = osgeo.osr.CoordinateTransformation(crs, RD)
        # convert geometry to output coordinate reference systems
        lat, lon, z = crs2wgs84.TransformPoint(*coords)
        x, y, z     = crs2rd.TransformPoint(*coords)

        # store location name and code
        location = {}
        location['location_code'] = loc.find('.//{%s}code'        % loc.nsmap['wadi']).text
        location['location_name'] = loc.find('.//{%s}description' % loc.nsmap['wadi']).text

        # store converted coordinates
        location['x'] = x
        location['y'] = y

        location['lat'] = lat
        location['lon'] = lon
        location['coords'] = coords
        location['epsg'] = epsg_int

        locations.append(location)

    return locations

# this is slow, cache result
@cache_region('long_term', 'rws_opendata_downloads')
def download(url=URLS['locations']):
    '''Read locations from XML url into memory'''

    with contextlib.closing(requests.get(url)) as response:
        xmlbytes = response.content

    # don't parse xml yet, as lxml tree is not picklable.
    return xmlbytes


def get():
    '''Download and parse XML and return locations as pandas DataFrame'''
    xmlbytes = download()
    locations = parse(xmlbytes)

    # create pandas dataframe and remove non-distinct records
    # basically we pick a random location in case of ambiguity
    df_locations = pandas.DataFrame(locations)
    df_locations = df_locations.ix[df_locations['location_name'].drop_duplicates().index]

    return df_locations

