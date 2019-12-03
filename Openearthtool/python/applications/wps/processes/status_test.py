# -*- coding: utf-8 -*-
"""
Created on Tue Apr 09 15:40:46 2013

@author: boerboom

Example of a process that updates its status.

Call this with the following parameters
request=Execute&
service=wps&
identifier=status_test&
version=1.0.0&
storeexecuteresponse=True&
status=True&
datainputs=input=hello%20world

Make sure you set the parameters in the config file:
outputUrl=http://localhost/wps/wpsoutputs
outputPath=/Users/fedorbaart/Downloads/pywps

"""
from types import StringType, FloatType
import time
import hashlib
from pywps.Process import WPSProcess

class Process(WPSProcess):
    def __init__(self):
        # init process
        WPSProcess.__init__(self,
                            identifier = "status_test", # must be same, as filename
                            title="echo",
                            version = "1",
                            storeSupported = True,
                            statusSupported = True,
                            abstract="Echo server")

        self.input = self.addLiteralInput(identifier = "input",
                                          title = "Input",
                                          abstract = "text input",
                                          type = StringType)
        self.output = self.addLiteralOutput(identifier="output",
                                            title="Output",
                                            abstract="text output",
                                            type = StringType)

    def execute(self):
        self.status.set("Starting computation",0)
        time.sleep(1)
        md5 = hashlib.md5()
        md5.update(self.input.getValue())
        self.status.set("Computing md5sum: {}".format(md5.hexdigest()) ,20)
        time.sleep(1)
        wc = len(self.input.getValue().split())
        self.status.set("Computing word count: {}".format(wc),40)
        time.sleep(1)
        rev = self.input.getValue()[::-1]
        self.status.set("Reversing: {}".format(rev),60)
        time.sleep(1)
        srt = "".join(sorted(self.input.getValue()))
        self.status.set("Sorting: {}".format(srt),80)
        time.sleep(1)
        self.status.set("Process completed",100)
        self.output.setValue("Was {} spawned?: {}".format(self.input.getValue(), self.spawned))
        return
