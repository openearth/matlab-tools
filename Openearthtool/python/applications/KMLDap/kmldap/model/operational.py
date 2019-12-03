import re
import xml.etree.cElementTree as etree
import urllib2
import urlparse
import pydap.client
import kmldap.model

# copied some of this code from the opendap crawler in openearth tools
ns = {"threddsns": "http://www.unidata.ucar.edu/namespaces/thredds/InvCatalog/v1.0",
      "xlinkns": "http://www.w3.org/1999/xlink"}
xpath_dataset='.//{{{threddsns}}}dataset'.format(**ns)
xpath_catalogs='.//{{{threddsns}}}catalogRef[@{{{xlinkns}}}href]'.format(**ns)
xpath_service=".//{{{threddsns}}}service".format(**ns)
catalog_re = re.compile(r'<([^>]+:)?catalog')

def getchildren(url):
    """find children of a catalog"""

    xml = etree.parse(urllib2.urlopen(url))
    parsed_url = urlparse.urlparse(url)
    # get the dap service
    services = [service for service in xml.findall(xpath_service)  if service.attrib['serviceType'].lower() == 'opendap']
    assert len(services) == 1, "%s has %s services: %s" % (url, len(services), services)
    service_base = services[0].attrib['base']
    base_url = urlparse.urlunparse((parsed_url.scheme, parsed_url.netloc, service_base, '', '', ''))
    # links to datasets are relative to the base_url
    links = xml.findall(xpath_dataset)
    for link in links:
        href = link.attrib.get("urlPath".format(**ns))
        if href:
            yield urlparse.urljoin(base_url, href)
    
def getdatasets(model='csm', type='maps'):
    urls = {'csm': 'http://opendap.deltares.nl/thredds/catalog/opendap/deltares/MICORE/public_html/egmond/scenarios/today/europe/csm/netcdf/catalog.xml',
            'nww3': 'http://opendap.deltares.nl/thredds/catalog/opendap/deltares/MICORE/public_html/egmond/scenarios/today/world/nww3/netcdf/catalog.xml',
            'kus': 'http://opendap.deltares.nl/thredds/catalog/opendap/deltares/MICORE/public_html/egmond/scenarios/today/europe/kuststrook/netcdf/catalog.xml',
            'egmond': 'http://opendap.deltares.nl/thredds/catalog/opendap/deltares/MICORE/public_html/egmond/scenarios/today/europe/egmond/netcdf/catalog.html'}
    url = urls[model]
    run_re = re.compile(r'^.*/(?P<model>[\d\w]+)\.(?P<date>\d{8})\_\d{2}z\.(?P<type>[\d\w]+)\.nc$')
    datasets = getchildren(url)
    for dataset in datasets:
        match = run_re.match(dataset)
        if match and match.group('type') == type:
            yield kmldap.model.pydaptonetcdf(pydap.client.open_url(dataset))
            

        
