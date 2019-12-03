# $Id: opendap_catalog.py 8903 2013-07-09 09:51:58Z boer_g $ forked from function getchildren in opendapcrawler.yp
# $Date: 2013-07-09 02:51:58 -0700 (Tue, 09 Jul 2013) $
# $Author: boer_g $
# $Revision: 8903 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/opendap/opendap_catalog.py $
# $Keywords: $

def opendap_catalog(url,maxlevel=1,servicetype='opendap'):
    """
    dataset_urls = opendap_catalog(catalog_url)
    parses (crawls) a THREDDS OPeNDAP catalog.xml from a url into
    a list of OPeNDAP dataset urls that are valid input for 
    opendap.py and netCDF4.py. Other services than 'opendap'
    can also be extracted with keyword servicetype (e.g. 'httpserver' for ftp access).
    The THREDDS catalogs are optionally parsed recursively, meaning that
    nested (remote) catalogs are also parsed. Use keyword maxlevel to determine 
    how deep the nesting should proceed (default 1 to avoid timeout).
    See also opendap_catalog.m, the Matlab equivalent.
    
    Example: 
url = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml'
lst = opendap_catalog(url)
for t in list:
    print t
    """

    from cStringIO import StringIO
    from lxml import etree
    import urllib, re, urlparse
    
    # constants
    # Define the namespaces used in opendap. See http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/InvCatalogSpec.html for details
    ns = {"threddsns": "http://www.unidata.ucar.edu/namespaces/thredds/InvCatalog/v1.0",
            "xlinkns": "http://www.w3.org/1999/xlink"}
    # Define some links to elements that can be found in thredds catalogs
    # a dataset (http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/InvCatalogSpec.html#dataset)
    xpath_dataset  ='.//{{{threddsns}}}dataset'.format(**ns)
    # a reference to another catalog. http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/InvCatalogSpec.html#catalogRef
    xpath_catalogs ='.//{{{threddsns}}}catalogRef[@{{{xlinkns}}}href]'.format(**ns)
    # a service (for example dods)
    xpath_service  =".//{{{threddsns}}}service".format(**ns)
    
    # some extra regular expressions
    catalog_re = re.compile(r'<([^>]+:)?catalog')
    
    f = urllib.urlopen(url)
    
    xml = etree.parse(StringIO(urllib.urlopen(url).read()))
    
    parsed_url = urlparse.urlparse(url)
    
    # get the dap service
    services     = [service for service in xml.findall(xpath_service)  if service.attrib['serviceType'].lower() == servicetype]
    assert len(services) == 1, "%s has %s services: %s" % (url, len(services), services)
    service_base = services[0].attrib['base']
    base_url     = urlparse.urlunparse((parsed_url.scheme, parsed_url.netloc, service_base, '', '', ''))
    
    opendap_urls = []

    # links to catalogs are relative to the url: parse recursively
    if maxlevel > 1:
        links = xml.findall(xpath_catalogs)
        for link in links:
            href = link.attrib.get("{{{xlinkns}}}href".format(**ns))
            if href:
                opendap_urls2 = opendap_catalog(urlparse.urljoin(url, href),maxlevel=maxlevel-1)
                for t in opendap_urls2:
                   opendap_urls.append(t)
    
    # links to datasets are relative to the base_url
    links = xml.findall(xpath_dataset)
    for link in links:
        href = link.attrib.get("urlPath".format(**ns))
        if href:
            opendap_urls.append(urlparse.urljoin(base_url, href))
            
    return opendap_urls

# debug/test code    
#url = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/waterbase/catalog.xml'
#lst = opendap_catalog(url)
#for t in lst:
#    print t
    