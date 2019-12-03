"""
Script to generate a couchdb database with all metadata of several opendap servers.
"""

# $Id: opendapcrawler.py 8903 2013-07-09 09:51:58Z boer_g $
# $Date: 2013-07-09 02:51:58 -0700 (Tue, 09 Jul 2013) $
# $Author: boer_g $
# $Revision: 8903 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/opendap/opendapcrawler.py $
# $Keywords: $

import multiprocessing
import urllib
import datetime
import functools
import urlparse
from cStringIO import StringIO
import re
import logging

import pydap.client
import pydap.model
import numpy

# this looks a bit messy but we want it to work on all python versions with or without lxml,
# and if it's not there we prefer the c implementation. Before 2.5 python didn't have element
# tree installed. prefer the fastest element tree
try:
    from lxml import etree
    print("running with lxml.etree")
except ImportError:
    try:
        # Python 2.5
        import xml.etree.cElementTree as etree
        print("running with cElementTree on Python 2.5+")
    except ImportError:
        try:
            # Python 2.5
            import xml.etree.ElementTree as etree
            print("running with ElementTree on Python 2.5+")
        except ImportError:
            try:
                # normal cElementTree install
                import cElementTree as etree
                print("running with cElementTree")
            except ImportError:
                try:
                    # normal ElementTree install
                    import elementtree.ElementTree as etree
                    print("running with ElementTree")
                except ImportError:
                    print("Failed to import ElementTree from any known place")

import couchdb
import couchdb.design
import couchdb.client
from couchdb import json
# patch the json function to allow nans do not use simplejson, does not work
# because I get a invalid utf-8 json request from the server
# import simplejson
#json._encode = lambda obj, dumps=simplejson.dumps: \
#            dumps(obj, allow_nan=True, ensure_ascii=False)


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

# I couldn't find a good crawler. So I wrote this simple one. Might be better to switch to another one:
# See for a discussion:
# http://stackoverflow.com/questions/419235/anyone-know-of-a-good-python-based-web-crawler-that-i-could-use
# Alternatives are: Stateful programmatic web browsing in Python, after Andy Lester's Perl module
# http://wwwsearch.sourceforge.net/mechanize/
# Scrapy is a fast high-level screen scraping and web crawling framework: http://scrapy.org/
# 

# Also now this crawler knows about opendap + crawling + couchdb. Might be good to split these off into the following:
# - crawl catalog -> urls
# - crawl opendap -> metadata
# - archive -> store metadata

class OpenDapCrawler:
    """crawler for opendap datasets"""
    def __init__(self, *args, **kwargs):
        conn = couchdb.Server()
        if 'opendap' in conn:
            self.db = conn['opendap']
    def setup(self):
        """setup a couchdb to store information"""
        conn = couchdb.Server()
        if not 'opendap' in conn:
            try:
                self.db = conn.create('opendap')
            except couchdb.client.PreconditionFailed, error:
                # this should be fixed in the new httplib2
                # http://code.google.com/p/httplib2/source/detail?r=3e88c07b96
                self.db = conn['opendap'] 
        else:
            self.db = conn['opendap']
        view_all = '''
        function(doc) 
        {
             emit(doc._id, null);
        }
        '''
        view_url = '''
        function(doc) 
        {
             emit(doc._id, doc);
        }
        '''
        view_status = '''
        function(doc) 
        {
             if(doc.status)
             {
                 emit(doc._id, doc.status);
             }
        }
        '''
        view_last_visited = '''
        function(doc)
        {
             if (doc.last_visited)
             {
                 last_visit = Date.parse(doc.last_visited);
                 emit(doc._id, last_visit);
             }
        }
        '''
       
        couchdb.design.ViewDefinition('views', 'all'         ,          view_all).sync(self.db)
        couchdb.design.ViewDefinition('views', 'url'         ,          view_url).sync(self.db)
        couchdb.design.ViewDefinition('views', 'status'      ,       view_status).sync(self.db)
        couchdb.design.ViewDefinition('views', 'last_visited', view_last_visited).sync(self.db)

    def addurl(self, url):
        """add a url to the list of datasets to crawl"""
        obj = {}
        obj['url'] = url
        try:
            self.db[url] = obj
        except couchdb.client.ResourceConflict, error:
            logging.debug(error)
            
    """TODO: store information in a view to determine which urls need to be checked"""
    @property
    def status(self): return self.db
    def update(self, url):
        """update http information for a url"""
        f      = urllib.urlopen(url)
        status = f.getcode()
        obj    = self.db[url]
        obj.update(f.headers.dict)
        obj['status'] = status
        obj['last-visited'] = str(datetime.datetime.today())
        # thredds doens't give a content description, so we need to read a bit
        try:
            pydap.client.open_url(url)
            obj['type'] = 'dap'
        except:
            if 'html' in obj['content-type']:
                obj['type'] = 'html'
            else:
                start = f.read(1000)
                if catalog_re.search(start):
                    obj['content'] = start + f.read()
                    obj['type'] = 'catalog'
                else:
                    obj['type'] = 'unknown'
        self.db[url] = obj

    def getchildren(self, url):
        """find children of a catalog"""
        obj = self.db[url]
        if obj['type'] == 'html':
            f = urllib.urlopen(url)
            if f.geturl().endswith('catalog.html'):
                yield urlparse.urljoin(f.geturl(), 'catalog.xml')
        if obj['type'] == 'catalog':
            t = obj['content']
            xml = etree.parse(StringIO(t))
            parsed_url = urlparse.urlparse(url)
            # get the dap service
            services     = [service for service in xml.findall(xpath_service)  if service.attrib['serviceType'].lower() == 'opendap']
            assert len(services) == 1, "%s has %s services: %s" % (url, len(services), services)
            service_base = services[0].attrib['base']
            base_url     = urlparse.urlunparse((parsed_url.scheme, parsed_url.netloc, service_base, '', '', ''))
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
    def updatemetadata(self, url):
        """update the information from opendap"""
        ds         = pydap.client.open_url(url)
        obj        = self.db[url]
        variables  = obj.get('variables', {})
        dimensions = obj.get('dimensions', {})
        # store global attributes
        variables.update(ds.attributes)
        # update variable information
        for varname in ds.keys():
            attributes = ds[varname].attributes
            for key, val in attributes.items():
                try:
                    if str(val).lower() == 'nan':
                        val = 'NaN'
                        attributes[key] = val
                except TypeError, error:
                    pass
            variables.update([(varname, attributes)])

        for varname in ds.keys():
            if ds[varname].dimensions:
                logging.debug(ds[varname].dimensions)
                dimensions.update(zip(ds[varname].dimensions, ds[varname].shape))
        obj['variables']  = variables
        obj['dimensions'] = dimensions
        self.db[url] = obj
    def markcoordinatevariables(self, url):
        """Determine which variables can be used and coordinate variables and mark them as axis"""
        obj = self.db[url]
        variables = obj['variables']
        for varname, variable in variables.items():
            if not variable.has_key('standard_name'):
                continue
            elif variable.has_key('axis'):
                continue
            if variable['standard_name'] in ('projection_x_coordinate', 'longitude'):
                variables[varname]['axis'] = 'X'
            elif variable['standard_name'] in ('projection_y_coordinate', 'latitude'):
                variables[varname]['axis'] = 'Y'
            elif variable['standard_name'] in ('time', ):
                variables[varname]['axis'] = 'T'
            else:
                name = variable.get('standard_name')
                if 'altitude' in name or 'height' in name or 'sigma_coordinate' in name:
                    variables[varname]['axis'] = 'Z'
        obj['variables'] = variables
        self.db[url] = obj
    def getextents(self, url):
        """Look up the bounding boxes of coordinate variables"""
        print 'getting extent for %s' % url
        ds = pydap.client.open_url(url)
        obj = self.db[url] 
        variables = obj['variables']
        assert len((set(ds.keys()) - set(variables.keys()))  - set(['NC_GLOBAL'])) == 0 , "%s vs %s (%s)" % (ds.keys(), variables.keys(), url)
        # loop over the variables we just read
        for varname in ds.keys():
            actual_range = None
            if variables[varname].has_key('axis'):
                variable = ds[varname] 
                if len(variable.dimensions) == 1:
                    # get the first and the last value
                    bounds = ds[varname][0], ds[varname][-1]
                    # do a nan check
                    actual_range = float(numpy.min(bounds)), float(numpy.max(bounds))
                elif len(variable.dimensions) == 2:
                    # get the boundaries, TODO: make this more efficient
                    basevar = ds[varname]
                    print type(basevar)
                    if not isinstance(basevar, pydap.model.BaseType):
                        basevar = ds[varname][varname]
                    top    = basevar[ 0,: ]
                    bottom = basevar[-1,: ]
                    left   = basevar[ :, 0]
                    right  = basevar[ :,-1]
                    bounds = numpy.r_[top, bottom, left, right]
                    # nan check should probably be done here
                    actual_range = float(numpy.min(bounds)), float(numpy.max(bounds))
                # make sure we don't include nan's json doesn't like it
                print varname, actual_range
                # not sure how to check for nan's in the most elegant way
                if actual_range is not None and 'nan' not in str(actual_range):
                    variables[varname]['actual_range'] = actual_range

        obj['variables'] = variables
        self.db[url] = obj
                    
    def iscatalog(self, url):
        """Is the url a catalog?"""
        obj = self.db[url]
        return obj['type'] == 'catalog'
    def isdap(self, url):
        """is the url a dap server"""
        obj = self.db[url]
        return obj['type'] == 'dap'
    def crawl(self):
        """start a crawl sweep accross all urls"""
        for row in self.db.view('views/url'):
            url = row.key
            obj = row.value
            print('updating %s' % url)
            self.update(url)
            obj = self.db[url]
            if obj['status'] not in (200, 400):
                print(obj['status'], url)
                continue
            if obj['type'] == 'dap':
                self.updatemetadata(url)
                self.markcoordinatevariables(url)
                self.getextents(url)
            elif obj['type'] in ('catalog', 'html'):
                children = list(self.getchildren(url))
                for childurl in children:
                    if 'kml' in childurl.lower():
                        continue
                    # administer relations
                    self.addurl(childurl)
                    childobj           = self.db[childurl]
                    childobj['parent'] = url
                    self.db[childurl]  = childobj
                    # store children
                children.extend(obj.get('children', []))
                children        = list(set(children))
                obj['children'] = children
                self.db[url]    = obj


urls = ['http://opendap.deltares.nl/thredds/catalog/opendap/catalog.xml'] #, 'http://opendap.deltares.nl:8080/thredds', 'http://dtvirt5.deltares.nl/thredds']
        

if __name__ == '__main__':
    
    # look up all objects we want to check
    crawler = OpenDapCrawler()
    crawler.setup()
    for url in urls:
        crawler.addurl(url)
    crawler.crawl()
