# -*- coding: utf-8 -*-
"""
SentinelSearch Class
Wrapper to query Sentinel SciHub
"""

import json
import logging
import StringIO
import geojson
import shapely.wkt
import subprocess
import xml.etree.ElementTree as etree
import os
import time
import datetime
import sys

class SentinelSearch:
    def __init__(self, bbox, mission, tstart, tend, clouds):
        # Variable params
        self.bbox = bbox.split(',')        
        self.mission = mission
        self.tstart = tstart
        self.tend = tend
        self.clouds = clouds
        
        # Fixed params
        self.maxresults = 100
        self.user = 'sdashboard_deltares'
        self.passwd = '147258369'
        self.data_hub = 'https://scihub.copernicus.eu/dhus'
        self.SCRIPT = '/opt/pywps/pywps3/processes/dhusget.sh'
        self.result = {}

        # Temp params
        self.TS = str(datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d_%H-%M-%S'))
        self.TMP_DIR = '/var/www/wps/wpsoutputs/sentinelsearch_' + self.TS 
        self.XML_Q = './query_scihub.xml'
        self.XML_R = './query_response.xml'
        self.CSV_R = './products.csv'

    def search_query(self):        
        # Build command
        args=["/bin/bash", self.SCRIPT]        
        # Username
        args.append('-u')
        args.append(self.user)
        # Password
        args.append('-p')
        args.append(self.passwd)        
        # Mission
        args.append('-m')
        args.append(self.mission)
        # Bounding box
        args.append('-c')
        args.append('{},{}:{},{}'.format(self.bbox[0],self.bbox[1],self.bbox[2],self.bbox[3]))
        # Timespan
        args.append('-S')
        args.append(self.tstart)
        args.append('-E')
        args.append(self.tend)
        # Limit
        args.append('-l')
        args.append(str(self.maxresults))
        # Files
        args.append('-z')
        args.append(str(self.TMP_DIR))        
        args.append('-q')
        args.append(str(self.XML_Q))
        args.append('-C')
        args.append(str(self.CSV_R))

        ## Execute 
        cmd_str="CMD: "
        for c in args: cmd_str+=(' '+c)
        logging.info(cmd_str)
        self.exec_cmd(args)

        ## Convert to dict
        if os.path.exists(os.path.join(self.TMP_DIR, self.XML_Q)):
            self.parse_xml_result()
        else:
            self.result['msg'] = 'ERROR: Service is unavailable (check scihub ESA connection)'
            e = sys.exc_info()[0]
            logging.error("%s" % e)

    def exec_cmd(self, args, debug=True):
        """ Execute command in shell """    
        logging.info("Executing script ...")
        pro = subprocess.Popen(args,
                             universal_newlines=True, 
                             stdin=subprocess.PIPE,
                             stdout=subprocess.PIPE,
                             stderr=subprocess.STDOUT)
        
        if debug:
	        ## Standard Output Loop 
	        line = ""
	        while pro.poll() is None:
	            line = pro.stdout.readline()
	            logging.info(line)
	            time.sleep(0.1)   

    def parse_xml_result(self):
        """ Convert xml to dict """
        logging.info("Parsing results ...")
        tree = etree.parse(os.path.join(self.TMP_DIR, self.XML_Q))
        entries = tree.findall('{http://www.w3.org/2005/Atom}entry')
        i=0
        for entry in range(len(entries)):
            # Gather information
            cc_element = entries[entry].find('{http://www.w3.org/2005/Atom}double[@name="cloudcoverpercentage"]')
            fp_element = entries[entry].find('{http://www.w3.org/2005/Atom}str[@name="footprint"]')
            t0_element = entries[entry].find('{http://www.w3.org/2005/Atom}date[@name="beginposition"]')
            t1_element = entries[entry].find('{http://www.w3.org/2005/Atom}date[@name="endposition"]')
            ql_element = entries[entry].find('{http://www.w3.org/2005/Atom}link[@rel="icon"]')
            title_element = entries[entry].find('{http://www.w3.org/2005/Atom}title')
            uuid_element = entries[entry].find('{http://www.w3.org/2005/Atom}id')
            summ_element = entries[entry].find('{http://www.w3.org/2005/Atom}summary')

            ## Required fields
            self.result[i] = dict()
            self.result[i]['id'] = uuid_element.text
            self.result[i]['summary'] = summ_element.text
            self.result[i]['title'] = title_element.text

            # Optional fields
            if cc_element != None: self.result[i]['cloudcoverage'] = cc_element.text
            if fp_element != None: self.result[i]['footprint'] = fp_element.text
            if t0_element != None: self.result[i]['beginposition'] = t0_element.text
            if t1_element != None: self.result[i]['endposition'] = t1_element.text
            if ql_element != None:
                self.result[i]['quicklook_url'] = ql_element.attrib['href']
                self.result[i]['download_url'] = ql_element.attrib['href'].replace('/Products(\'Quicklook\')','') 

            logging.info('Found: '+title_element.text)
            i+=1

    def get_json(self):
        """ Convert dict to JSON """
        json_str = json.dumps(self.result)
        json_output = StringIO.StringIO()
        json_output.write(json_str)    
        return json_output
