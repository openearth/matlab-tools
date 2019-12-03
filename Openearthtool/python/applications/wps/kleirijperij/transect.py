# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares
#       Joan Sala
#
#       joan.salacalero@deltares.nl
#
#   This library is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this library.  If not, see <http://www.gnu.org/licenses/>.
#   --------------------------------------------------------------------
#
# This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
# OpenEarthTools is an online collaboration to share and manage data and
# programming tools in an open source, version controlled environment.
# Sign up to recieve regular updates of this function, and to contribute
# your own tools.

# $Id: kust_transect.py 14128 2018-01-30 07:30:36Z sala $
# $Date: 2018-01-30 08:30:36 +0100 (Tue, 30 Jan 2018) $
# $Author: sala $
# $Revision: 14128 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/emisk/kust_transect.py $
# $Keywords: $


"""
Transect WPS 

This is a redesigned WPS for the Kleirijperij application.

if it runs on localhost then:
getcapabilities:  http://localhost/cgi-bin/pywps.cgi?request=GetCapabilities&service=wps&version=1.0.0
describe process: http://localhost/cgi-bin/pywps.cgi?request=DescribeProcess&service=wps&version=1.0.0&identifier=transect
execute:          http://localhost/cgi-bin/pywps.cgi?&service=wps&request=Execute&version=1.0.0&identifier=transect&datainputs=[linestr={%20"type":%20"FeatureCollection",%20"features":%20[%20{%20"type":%20"Feature",%20"properties":%20{%20"id":%20null%20},%20"geometry":%20{%20"type":%20"LineString",%20"coordinates":%20[%20[%2083831.092144669499,%20448452.68563390407%20],%20[%2083958.355731735704,%20448428.40837328951%20],%20[%2084101.003099671972,%20448430.12129659101%20],%20[%2084247.216841408226,%20448418.68480195443%20],%20[%2084347.366886706994,%20448334.90273034602%20],%20[%2084437.90036527536,%20448234.41033133975%20],%20[%2084524.658347761986,%20448132.09910295915%20],%20[%2084624.369683701385,%20448016.50065624306%20],%20[%2084727.680250018995,%20447889.61876790464%20],%20[%2084823.542831033759,%20447766.58495800826%20],%20[%2084908.650886898482,%20447679.27150645608%20]%20]%20}%20}%20]%20}]
"""


# core
import os
import operator
import math
import tempfile
import logging
import ConfigParser
import time
import datetime as date
import pandas as pd

# modules
import types
import simplejson as json
import StringIO
from pywps.Process import WPSProcess
from geojson import LineString, Feature, FeatureCollection
from shapely import wkt

# Self libraries
from utils import *
from bokeh_plots import *

"""
This is a redesigned WPS from the MEP duinen application for the Kleirijperij application.
"""

# list of kleirijperij dtm
lstdata = ['20180409_164731_Kleirijperij',
           '20180423_164731_Kleirijperij',
           '20180531_164731_Kleirijperij',
           '20180802_164731_Kleirijperij',
           '20180906_164731_Kleirijperij',
           '20181015_164731_Kleirijperij']
                  
class Process(WPSProcess):
     def __init__(self):
          # init process
         WPSProcess.__init__(self,
              identifier = "transect", # must be same, as filename
              title="Transect",
              version = "1.0",
              storeSupported = "true",
              statusSupported = "true",
              abstract="Deze functie maakt het mogelijk om dwarsprofielen van de bassins te maken. Teken een profiel (dubbel klik om het profiel af te sluiten) en klik op Execute om het dwarsprofiel te bepalen (dit is een dynamisch proces en kan even duren).",
              grassLocation =False)

         self.transect = self.addLiteralInput(identifier = "transect",
                                              title="Teken een transect en klik op Execute",
                                              abstract="input=mapselection",
                                              type=type(""),
                                              uoms=["linestring"])

         self.json=self.addComplexOutput(identifier="json",
                                         title="Returns list of values for specified xy",
                                         abstract="""Returns list of values for specified xy""",
                                         formats=[{"mimeType": "text/plain"}, # first is default
                                                   {"mimeType": "application/json"}])                              
     
     
     def execute(self):
      # Outputs preparation
      outdata = StringIO.StringIO()
      values = {}

      # Read config
      PLOTS_DIR, APACHE_DIR, GEOSERVER_URL,_,_ = readConfig()
      linestr_str=""

      # Inputs check
      try:
        linestr_str = self.transect.getValue()
        logging.info('''INPUT [transect]: location={}'''.format(str(linestr_str)))
        lwkt = wkt.loads(linestr_str)
      except:
        msg = 'Selecteer eerst een transect en klik op Execute'
        logging.info(msg)
        values['error_html'] = msg
        json_str = json.dumps(values)
        outdata.write(json_str)
        self.json.setValue(outdata)
        return

      # Get values for selected xy in fixed epsg
      epsgout = 'epsg:3857'
      epsgin = 'epsg:3857'
      wcs_x = {}
      wcs_y = {}

      # For every layer, supports multilinestrings
      err = False
      mindist = 99999
      maxdist = -99999

      for y in range(len(lstdata)): # configured on top
          logging.info(lstdata[y])

          # For every subline of the transect
          x0, y0 = change_coords(lwkt.coords[0][0], lwkt.coords[0][1], epsgin=epsgin, epsgout=epsgout)
          wcs_vals = []
          wcs_dist = []
          first = True
          total_dist = 0

          # Go line by line
          for xin,yin in lwkt.coords:
              # First point is useless
              if first:
                  first = False
                  continue
              
              # Point
              (xk,yk) = change_coords(xin, yin, epsgin=epsgin, epsgout=epsgout)
              total_dist += math.sqrt((xk-x0)*(xk-x0) + (yk-y0)*(yk-y0))
              if total_dist > 10000:
                  msg = 'De maximaal toegestane afstand voor een transect is 10 km. Probeer het opnieuw.'
                  logging.info(msg)
                  values['error_html'] = msg
                  json_str = json.dumps(values)
                  outdata.write(json_str)
                  self.json.setValue(outdata)
                  return
              
              # Retrieve and parse data
              d=getDatafromWCS(GEOSERVER_URL, 'hoogte:{}'.format(lstdata[y]), x0, y0, xk, yk)
              if not(d is None):
                  N=float(len(d))
                  step=float(total_dist)/N
                  # concatenate values  
                  i=0.0
                  for val in d:
                      if not(val is None) and val > -999.0: #no-nonsense
                          wcs_vals.append(val)
                          wcs_dist.append(step*i)
                      i+=1.0

          # Add to hash results for layer l
          if len(wcs_vals):
              wcs_y[y] = wcs_vals
              wcs_x[y] = wcs_dist
              maxdist = max(maxdist, max(wcs_dist))
              mindist = min(mindist, min(wcs_dist))

      # Start/End of data
      m = math.sqrt((xk-x0)*(xk-x0) + (yk-y0)*(yk-y0))
      xu = float(xk-x0)/float(m)
      yu = float(yk-y0)/float(m)
      xs = x0 + mindist*xu
      ys = y0 + mindist*yu
      xe = x0 + maxdist*xu
      ye = y0 + maxdist*yu
      (lone,late) = change_coords(xe, ye, epsgin=epsgout, epsgout='epsg:4326')
      (lons,lats) = change_coords(xs, ys, epsgin=epsgout, epsgout='epsg:4326')
      
      # Generate plot       
      if len(wcs_y) or err:
          # Prepare plot            
          tmpfile = tempfile(PLOTS_DIR)
          bokeh=bokeh_Plot(wcs_x, wcs_y, {'x':'Transect', 'y':'Transect', 'locationke':'Selected by user'}, '', '', tmpfile)
          bokeh.plot_Transect()

          # Send back result JSON     
          values['url_plot'] = APACHE_DIR + os.path.basename(tmpfile)
          values['plot_xsize'] = 1020
          values['plot_ysize'] = 550
          # values['zoomx'] = (lwkt.coords[0][0]+lwkt.coords[1][0])/2.0    # no zoom required for the Kleirijperij webviewer
          # values['zoomy'] = (lwkt.coords[0][1]+lwkt.coords[1][1])/2.0
          values['title'] = 'OpenEarth WPS'
          values['wkt_transect'] = 'LINESTRING ({} {}, {} {})'.format(lons,lats,lone,late)
          json_str = json.dumps(values)
          logging.info('''OUTPUT [kleirijperij]: {}'''.format(json_str))
          outdata.write(json_str)
          self.json.setValue(outdata)
      else:
          msg = 'No data for the selected bounding box. Please draw inside the available area.'
          logging.info(msg)            
          values['error_html'] = msg
          json_str = json.dumps(values)
          outdata.write(json_str)
          self.json.setValue(outdata)

      return