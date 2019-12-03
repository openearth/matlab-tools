import re
import urlparse

from scrapy.http import Request, Response, TextResponse, XmlResponse, HtmlResponse
from scrapy.selector import HtmlXPathSelector
from scrapy.contrib.linkextractors.sgml import SgmlLinkExtractor
from scrapy.contrib.spiders import CrawlSpider, Rule

from scrapy.selector import HtmlXPathSelector, XmlXPathSelector
from scrapy.spider import BaseSpider
from scrapy.http import Request

from dapcrawler.items import DapcrawlerItem
from dapcrawler.loader import DapcrawlerItemLoader

ns = {"threddsns": "http://www.unidata.ucar.edu/namespaces/thredds/InvCatalog/v1.0",
      "xlinkns": "http://www.w3.org/1999/xlink"}

class DapSpider(BaseSpider):
    name = 'dapcrawler'
    allowed_domains = ['opendap.deltares.nl', 'dtvirt5.deltares.nl']
    start_urls = [
        'http://opendap.deltares.nl',
        'http://dtvirt5.deltares.nl'
    ]
    def __init__(self, *args, **kwargs): 
        BaseSpider.__init__(self, *args, **kwargs) 
        if 'start_url' in kwargs:
            self.start_urls = [kwargs['start_url']] 
    def parse_dap(self, response):
        """parse a dap response using and return a dapcrawleritem"""
        self.log("Parse dap called with {}".format(response.url))
        d = DapcrawlerItem()
        loader = DapcrawlerItemLoader(item=d, response=response)
        loader.add_dataset()
        return d
    def parse_catalog(self, response):
        """Parse a thredds catalog and yield all the urls"""
        xxs = XmlXPathSelector(response)
        for key, value in ns.items():
            xxs.register_namespace(key, value)

        # links to catalogs are relative to the url
        # get links to catalogs...
        urls = xxs.select('//threddsns:catalogRef/@xlinkns:href').extract()
        for url in urls:
            absolute_url = urlparse.urljoin(response.url, url)
            self.log("Yielding nodap request {}".format(absolute_url))
            yield Request(url=absolute_url, callback=self.parse)

        # links to datasets are relative to the base_url
        services = xxs.select('//threddsns:service/@serviceType').extract()
        bases = xxs.select('//threddsns:service/@base').extract()
        basesbyservice = dict((service.lower(), base) for (service, base) in zip(services, bases))
        assert 'opendap' in basesbyservice
        opendap_base = basesbyservice.get('opendap')
        parsed_url = urlparse.urlparse(response.url)
        base_url = urlparse.urlunparse((parsed_url.scheme, parsed_url.netloc, opendap_base, '', '', ''))

        datasets = xxs.select('//threddsns:dataset/@urlPath').extract()
        for url in datasets:
            absolute_url = urlparse.urljoin(base_url, url)
            self.log("Yielding dap request {} with {}".format(absolute_url, self.parse_dap))
            # since we found this link in a catalog file, we are gonna parse it using the parse dap
            yield Request(absolute_url, callback=self.parse_dap)
    def parse_html(self, response):
        """parse a html file and yield all links"""
        self.log("Parse html called with {}".format(response.url))
        hxs = HtmlXPathSelector(response)
        for url in hxs.select('//a/@href').extract():
            absolute_url = urlparse.urljoin(response.url, url)
            yield Request(absolute_url, callback=self.parse)

    def parse(self, response):
        """The parse method is in charge of processing the response and returning scraped data and/or more URLs to follow.
        """
        self.log("Parse called with {}".format(response.url))
        # delegate to the appropriate parser...
        if isinstance(response, XmlResponse) or response.url.endswith('.xml'):
            for request in self.parse_catalog(response):
                yield request
        elif isinstance(response, HtmlResponse):
            for request in self.parse_html(response):
                yield request
        else:
            self.log('WHAT IS THIS?: parsing %s of type %s, %s' % (response.url,type(response), response.headers.get('Content-Type', 'NO CONTENTTYPE')))
        # yield urls
        if response.url.endswith('catalog.html'):
            url = urlparse.urljoin(response.url, 'catalog.xml')
            self.log('Getting catalog.xml for %s (%s)' % (response.url, url))
            yield Request(url, callback=self.parse)
SPIDER = DapSpider()
