#!/usr/bin/env python
# requires lxml (better namespace support and faster)

# $Id: catalog.py 8903 2013-07-09 09:51:58Z boer_g $
# $Date: 2013-07-09 02:51:58 -0700 (Tue, 09 Jul 2013) $
# $Author: boer_g $
# $Revision: 8903 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/opendap/catalog.py $
# $Keywords: $

import lxml.etree as etree
import urllib
import datetime
import functools
import urlparse
import re

# Define the namespaces used in opendap. See http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/InvCatalogSpec.html for details
ns = {"threddsns": "http://www.unidata.ucar.edu/namespaces/thredds/InvCatalog/v1.0",
      "xlinkns": "http://www.w3.org/1999/xlink"}
# Define some links to elements that can be found in thredds catalogs
# a dataset (http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/InvCatalogSpec.html#dataset)
xpath_dataset='.//{{{threddsns}}}dataset'.format(**ns)
# a reference to another catalog. http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/InvCatalogSpec.html#catalogRef
xpath_catalogs='.//{{{threddsns}}}catalogRef[@{{{xlinkns}}}href]'.format(**ns)
# a service (for example dods)
xpath_service=".//{{{threddsns}}}service".format(**ns)

# some extra regular expressions
catalog_re = re.compile(r'<([^>]+:)?catalog')

def getchildren(url):
    """find children of a catalog"""
    f = urllib.urlopen(url)
    xml = etree.parse(f)
    # parse the url because we need some parts of it later
    parsed_url = urlparse.urlparse(url)
    # get the dap service
    services = [service for service in xml.findall(xpath_service)  if service.attrib['serviceType'].lower() == 'opendap']
    assert len(services) == 1, "%s has %s services: %s" % (url, len(services), services)
    service_base = services[0].attrib['base']
    base_url = urlparse.urlunparse((parsed_url.scheme, parsed_url.netloc, service_base, '', '', ''))
    # links to catalogs are relative to the url
    links = xml.findall(xpath_catalogs)
    for link in links:
        href = link.attrib.get("{{{xlinkns}}}href".format(**ns))
        if href:
            yield urlparse.urljoin(url, href)
    # links to datasets are relative to the base_url
    links = xml.findall(xpath_dataset)
    for link in links:
        href = link.attrib.get("urlPath".format(**ns))
        if href:
            yield urlparse.urljoin(base_url, href)
