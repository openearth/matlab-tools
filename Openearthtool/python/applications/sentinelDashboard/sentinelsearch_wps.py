# -*- coding: utf-8 -*-
"""
SentinelSearch WPS

Makes use of PyWPS 3
doc @ https://media.readthedocs.org/pdf/pywps/pywps-3.2/pywps.pdf

Normally implemented via Apache CGI process

For running on localhost:
getcapabilities:  http://localhost/cgi-bin/pywps.cgi?request=GetCapabilities&service=wps&version=1.0.0
describe process: http://localhost/cgi-bin/pywps.cgi?request=DescribeProcess&service=wps&version=1.0.0&identifier=sentinelsearch_wps
execute:          PUT naar http://localhost/cgi-bin/pywps.cgi?request=Execute&service=wps&version=1.0.0&identifier=sentinelsearch_wps
"""

import json
import logging
import time
from datetime import date, timedelta
from os import path
from six.moves.html_parser import HTMLParser

from pywps.Process import WPSProcess
from sentinelsearch import SentinelSearch

class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="sentinelsearch_wps",
                            title="SentinelSearch",
                            version="0.1",
                            storeSupported="true",
                            statusSupported="false",
                            abstract="""SentinelSearch allows to query the scihub in a simple way, returns JSON results""",
                            grassLocation=False)

        ##
        # Adding process inputs
        self.in_bbox = self.addLiteralInput(identifier="latlonbox",
                                          title="Bounding Box",
                                          abstract="input=mapselection",
                                          type=type(""),
                                          uoms=["box"],
                                          default="Select a location on the map")

        self.in_mission = self.addLiteralInput(identifier="mission",
                                          title="Mission name [Sentinel1, Sentinel2, Sentinel3]",
                                          type=type(""),
                                          default='Sentinel-1',
                                          allowedValues=['Sentinel-1','Sentinel-2','Sentinel-3']
                                          )

        self.in_tstart = self.addLiteralInput(identifier="tstart",
                                          title="Start date",
                                          type=type(""),
                                          default=(date.today()-timedelta(7)).strftime('%Y-%m-%dT%H:%M:%S.000Z')) # 2016-09-10T12:00:00.000Z

        self.in_tend = self.addLiteralInput(identifier="tend",
                                          title="End date",
                                          type=type(""),
                                          default=date.today().strftime('%Y-%m-%dT%H:%M:%S.000Z'))

        self.in_clouds = self.addLiteralInput(identifier="clouds",
                                          title="Cloud cover",
                                          type=type(0.0),
                                          default=30.0)
        ##
        # Adding process outputs
        self.out_json = self.addComplexOutput(identifier="json",
                                          title="Returns list of available results for the given query",
                                          abstract="""Results of the (area,mission,timespan) query""",
                                          formats=[{"mimeType": "text/plain"},  # 1st is default
                                                   {'mimeType': "text/html"}])

    def execute(self):
        # Other params
        bbox = self.in_bbox.getValue()
        mission = self.in_mission.getValue()
        tstart = self.in_tstart.getValue()
        tend = self.in_tend.getValue()
        clouds = self.in_clouds.getValue()
        logging.info('Sentinel Query ## Mission = ' + mission + ' BBOX = ' + bbox +  ' Timespan (t0,t1) = (' + tstart + ' -> ' + tend + ')')

        # Initiate SentinelSearch class
        try:
            sr = SentinelSearch(bbox, mission, tstart, tend, clouds)
            sr.search_query()
            # Format results        
            json_output = sr.get_json()
        except:
            json_str = json.dumps({'error_msg': 'Data not available, please check dates, mission and latlonbox parameters and try again'})
            json_output = StringIO.StringIO()
            json_output.write(json_str) 

        # Return result
        self.out_json.setValue(json_output)
        return

if __name__ == "__main__":
    a = Process()
    a.execute()
