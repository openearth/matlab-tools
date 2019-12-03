# from kmldap.model import opendap
from kmldap.lib.catalog import getchildren
from pylons import config
import pydap.client

# do this on import time so it is run on startup
url = config.get('waterbase.url', 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/waterbase/sea_surface_height/catalog.xml')
urls = list(getchildren(url))
url_attributes = {}
def getattributes(url):
    return pydap.client.open_url(url).attributes

url_attributes = dict((url,getattributes(url))
                          for url in urls)
id_url = dict((attributes['NC_GLOBAL']['locationcode'], url) for url, attributes in url_attributes.iteritems())

def getseries(id):
    url = id_url[id]
    ds = pydap.client.open_url(url)
    h = ds['sea_surface_height'][:]
    t = ds['time'][:]
    return dict(h=h.tolist(), t=t.tolist())

