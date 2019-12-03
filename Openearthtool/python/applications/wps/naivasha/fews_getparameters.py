# -*- coding: utf-8 -*-
"""
Created on Mon Sep 29 16:44:03 2014

@author: hendrik_gt

Repository information:
Date of last commit:     $Date: 2015-04-01 00:36:12 -0700 (Wed, 01 Apr 2015) $
Revision of last commit: $Revision: 11846 $
Author of last commit:   $Author: hendrik_gt $
URL of source:           $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/naivasha/fews_getparameters.py $
CodeID:                  $ID$


http://localhost/cgi-bin/pywps.cgi?service=wps&request=GetCapabilities&version=1.0.0

http://localhost/cgi-bin/pywps.cgi?service=wps&request=DescribeProcess&Identifier=fews_getparameters&version=1.0.0

http://localhost/cgi-bin/pywps.cgi?request=Execute&service=wps&version=1.0.0&identifier=fews_getparameters&datainputs=[wellid=iets]

"""

from pywps.Process import WPSProcess
from pywps import config
from naivasha import waterinformation
import logging

tempDir = config.getConfigValue("server","tempPath")
class Process(WPSProcess):
    def __init__(self):

        ##
        # Process initialization
        WPSProcess.__init__(self,
            identifier = "fews_getparameters",
            title="Return available time series parameters",
            abstract="""Get available parameters with timeseries""",
            version = "1.0",
            storeSupported = True,
            statusSupported = True)

        self.textIn = self.addLiteralInput(identifier="empty",
                                           title     ="Parameter ID",
                                           type      =type(""),
                                           default   ="A.obs")


        ##
        # Adding process outputs
        self.Output1 = self.addComplexOutput(identifier  = "Parameters",
                                             title       = "List of available Parameters with timeseries",
                                             formats    = [{"mimeType":"text/plain"}, # 1st is default
                                                           ])

    ##
    # Execution part of the process
    def execute(self):
    #    self.Output1.setValue(self.test.getValue())
     #   return

        # just copy the input values to output values
        logging.info('fews_getparameters started')
        io = waterinformation.getparameters()
        self.Output1.setValue(io)
        io.close()
        return