# -*- coding: utf-8 -*-
"""
SentinelSearch WPS

Makes use of PyWPS 3
doc @ https://media.readthedocs.org/pdf/pywps/pywps-3.2/pywps.pdf

Normally implemented via Apache CGI process

For running on localhost:
getcapabilities:  http://localhost/cgi-bin/pywps.cgi?request=GetCapabilities&service=wps&version=1.0.0
describe process: http://localhost/cgi-bin/pywps.cgi?request=DescribeProcess&service=wps&version=1.0.0&identifier=sentineldownload_wps
execute:          PUT naar http://localhost/cgi-bin/pywps.cgi?request=Execute&service=wps&version=1.0.0&identifier=sentineldownload_wps
"""

import json
import logging
from os import path
from six.moves.html_parser import HTMLParser

from pywps.Process import WPSProcess
from sentinelsearch import SentinelSearch
import urllib2, base64
import random, string
import os
import StringIO

class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="sentineldownload_wps",
                            title="SentinelSearch",
                            version="0.1",
                            storeSupported="true",
                            statusSupported="false",
                            abstract="""SentinelSearch allows to download products from the scihub in a simple way, returns a url with the file""",
                            grassLocation=False)

        # Adding process inputs
        self.in_url = self.addLiteralInput(identifier="url",
                                          title="Url to download",
                                          type=type(""),
                                          default='')

        # Adding process outputs
        self.out_json = self.addComplexOutput(identifier="json",
                                          title="Returns a url with the downloaded file",
                                          abstract="""Returns a url with the downloaded file""",
                                          formats=[{"mimeType": "text/plain"},  # 1st is default
                                                   {'mimeType': "text/html"}])

        # Default config
        self.HTTP_DIR = '/var/www/html/sentinel_quicklooks/'
        self.ACCESS_URL = 'http://dl-040.xtr.deltares.nl/sentinel_quicklooks/'
        self.user = 'sdashboard_deltares'
        self.passwd = '147258369'

    def execute(self):
        # Other params
        url = self.in_url.getValue()
        logging.info('Sentinel Query ## Url = ' + url)

        # Initiate SentinelSearch class
        random_fname = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(6))+'.png'
        file_path = os.path.join(self.HTTP_DIR, random_fname)
        url_path = self.ACCESS_URL + random_fname
        logging.info('Local File: ' + str(file_path))
        logging.info('URL path: ' + str(url_path))

        # Download with authentication
        ok = self.auth_download(url, file_path)        

        # Format results        
        result = dict()
        result['success'] = ok
        result['url'] = self.ACCESS_URL + random_fname
        json_str = json.dumps(result)
        json_output = StringIO.StringIO()
        json_output.write(json_str) 
        
        # Return result
        self.out_json.setValue(json_output)
        return

    def auth_download(self, url, output_file):
        """ Authenticate and download (previews) """
        try:
            request = urllib2.Request(url)
            base64string = base64.b64encode('%s:%s' % (self.user, self.passwd))
            request.add_header("Authorization", "Basic %s" % base64string)
            result = urllib2.urlopen(request)
            with open(output_file, "wb") as f:
                f.write(result.read())
        except Exception as e: # Preview not available
            logging.error(url)
            logging.error(str(e))
            return False
        logging.info(f)
        return True

if __name__ == "__main__":
    a = Process()
    a.execute()
