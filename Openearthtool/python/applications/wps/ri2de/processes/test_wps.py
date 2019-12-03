# -*- coding: utf-8 -*-
"""
Created on Fri Nov 15 15:23:48 2019

@author: Frederique de Groen

source: https://publicwiki.deltares.nl/pages/viewpage.action?pageId=119046447

"""

# import owslib wps part dealing with WebProcessingServices
from owslib.wps import WebProcessingService

# define the URL of the WPS
url = 'http://localhost:5000/wps'

# define the WPS
wps = WebProcessingService(url, verbose=False, skip_caps=True)
wps.getcapabilities()

wps.identification.title
wps.identification.abstract

# find out which processes there are
for process in wps.processes:
    print(process.identifier + ': ' + process.title)


"""
DESCRIBE PROCESS
After inspecting the GetCapabilities document and choosing the process you like,
you need to find out how to execute the process. For execution you need at least
all all requested input parameters. This is done by means of the 'DescribeProcess'
request. This request returns an xml containing all in- and outputs.
"""

# DescribeProcess gives insight in input and output parameters
process = wps.describeprocess('ultimate_question')
process.abstract

for input in process.dataInputs:
    print(input.title, input.identifier, input.dataType, input.defaultValue)

for output in process.processOutputs:
    print(output.title, output.identifier, output.dataType, output.defaultValue)

"""
EXECUTE
Once you've found and specified all input parameters you are ready to execute
the process by means of the 'Execute' request. The service returns an xml containing
all process outputs. These outputs can be read by Matlab and can also be plotted or
used for other operations.
"""
# define inputs, which is an array with several objects of several dataTypes (as listed below)
inputs = [('location','POINT(3 52)'),
          ('startdate','2013-08-21 00:00'),
          ('enddate','2013-08-29 23:00'),
          ('frequency','HOURLY')]

execution = wps.execute(process.identifier,inputs)
for output in execution.processOutputs:
    print(output.identifier)
    print(output.data)

# this will yield data for tide for 1 location for the given datetime range







