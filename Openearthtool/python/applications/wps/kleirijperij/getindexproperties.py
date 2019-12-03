# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2019 Deltares
#       Frederique de Groen
#
#       frederique.degroen@deltares.nl
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

# $Id: getindexproperties.py 
# $Date: 2019-1-30
# $Author: de Groen $
# $Revision: 14128 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/ $
# $Keywords: $


"""
Get Index Properties WPS 

This is a redesigned WPS for the Kleirijperij application.

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

class Process(WPSProcess):
     def __init__(self):
          # init process
         WPSProcess.__init__(self,
              identifier = "getindexproperties", # must be same, as filename
              title="Toon index eigenschappen",
              version = "1.0",
              storeSupported = "true",
              statusSupported = "true",
              abstract="Deze functie maakt het mogelijk om de index eigenschappen per vak te bekijken op verschillende dieptes. Er wordt een verschil gemaakt tussen mengmonsters (van drie locaties in een vak per laag gemengd) en enkele monsters - deze zijn de waarden voor &#233;&#233;n locatie en &#233;&#233;n diepte.",
              grassLocation =False)

         self.location = self.addLiteralInput(identifier = "location",
                                              title="Prik een locatie en druk op execute.",
                                              abstract="input=mapselection",
                                              type=type(""),
                                              uoms=["point"])

         self.type = self.addLiteralInput(
                      identifier="type",
                      title="Kies parameter",
                      abstract="input=dropdownmenu",
                      type=type(""),
                      allowedValues=["vochtgehalte",
                                     "droge_stof",
                                     "dichtheid_situ",
                                     "plastic_limit",
                                     "liquid_limit",
                                     "organisch_gehalte",
                                     "zoutgehalte",
                                     "gloeiverlies"],
                      default="vochtgehalte")

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

      # Inputs check
      location = self.location.getValue()    
      param = self.type.getValue() 
      logging.info('''INPUT [meetlocatie]: location={}'''.format(str(location)))

      # Error messaging
      okparams, msg, xin, yin = check_location(location)
      if not(okparams):            
          logging.info(msg)            
          values['error_html'] = msg
          json_str = json.dumps(values)
          outdata.write(json_str)
          self.json.setValue(outdata)
          return

      # Get values for selected xy in fixed epsg
      epsgout = 'epsg:28992'
      epsgin = 'epsg:3857'

      # Point
      (xk,yk) = change_coords(xin, yin, epsgin=epsgin, epsgout=epsgout)
      
      # Query Database by location
      locinfo = queryPostGISClosestPointMonstername(xk, yk)
      if not(locinfo):            
          logging.info(msg)            
          values['error_html'] = 'Er is een fout opgetreden tijdens het ondervragen van de database [search closest]'
          json_str = json.dumps(values)
          outdata.write(json_str)
          self.json.setValue(outdata)
          return

      locid = locinfo[0][0]
      x = locinfo[0][2]
      y= locinfo[0][3]
      dist = locinfo[0][-1]

      # Title of plot
      if locinfo[0][0] == None:  tit = ''
      else:                      tit = locinfo[0][0]      
      title = '{}'.format(tit)
      logging.info('Title [getindexproperties]: {}'.format(title))

      # Query database by location
      res=queryPostGISLocIDMonsternames(locid, param)   # locid = vak nummer (e.g. D13), param = type of mesurement (e.g. vochtgehalte)
      if not(res):            
          logging.info(msg)            
          values['error_html'] = 'Er zijn geen meetwaardes te vinden voor deze locatie en parameter. Kies een andere locatie.'
          json_str = json.dumps(values)
          outdata.write(json_str)
          self.json.setValue(outdata)
          return

      # Generate plot of index properties
      tmpfile = tempfile(PLOTS_DIR)
      bokeh = bokeh_Plot(x, y, res, param, locid, tmpfile)
      bokeh.plot_IndexPropertiesAtDepth()

      # Send back result JSON
      values['url_plot'] = APACHE_DIR + os.path.basename(tmpfile)
      values['title'] = 'Geselecteerde index eigenschappen'
      
      json_str = json.dumps(values)
      logging.info('''OUTPUT [meetlocaties]: {}'''.format(json_str))
      outdata.write(json_str)
      self.json.setValue(outdata)       

      return