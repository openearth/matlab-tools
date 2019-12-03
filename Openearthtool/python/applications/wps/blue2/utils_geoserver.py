# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
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

# $Id: emisk_utils_wcs.py 14127 2018-01-30 07:21:10Z hendrik_gt $
# $Date: 2018-01-30 08:21:10 +0100 (Tue, 30 Jan 2018) $
# $Author: hendrik_gt $
# $Revision: 14127 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/emisk/emisk_utils_wcs.py $
# $Keywords: $

import os
import csv
import math
import statistics
import logging
import requests
import psycopg2
import zipfile
from requests.auth import HTTPBasicAuth
from geoserver.catalog import Catalog
import numpy as np
from scipy import stats

# Color palettes
from bokeh.palettes import *

# Publish a PostGIS layer/table
def geoserverTempLayer(cf, layername, sld_style, crs, store='tmpstore'):
    # connect
    epsg_str = 'EPSG:{}'.format(crs)
    cat = Catalog(cf.get('GeoServer', 'url_rest'), cf.get('GeoServer', 'user'), cf.get('GeoServer', 'pass'))
    
    # Publish layer
    ds = cat.get_store(cf.get('GeoServer', store))
    ft = cat.publish_featuretype(layername, ds, epsg_str, srs=epsg_str)

    # check if style/layer exists
    if cat.get_style(sld_style) == False:
        logging.info('Style {} not found'.format(sld_style))
    if cat.get_layer(layername) == False:
        logging.info(' '.join(['layer',layername,'not found']))

    # Add SLD
    try:
        layer = cat.get_layer(layername)        
        layer._set_default_style(sld_style)
        # Update and save layer
        cat.save(layer)
        cat.reload()
    except:
        logging.info('ERROR while connecting to geoserver to change SLD styling')
        pass 

    # Return fixed layername
    return cf.get('GeoServer', 'tmpworkspace')+':'+layername

# Generate a temporary style associated with the layer
def geoserverTempStyle(varnamestr, cf, df, columname, tablename, colortable='blue', ranges=9.0):
    # Parse title/subtitle
    sld_style = 'tmpsld_{}'.format(tablename)    
    title = varnamestr
    subtitle = 'N/A'
    if '[' in varnamestr and ']' in varnamestr:
      subtitle = varnamestr[varnamestr.find("[")+1:varnamestr.find("]")]
      title = varnamestr[0:varnamestr.find("[")]

    # connect
    cat = Catalog(cf.get('GeoServer', 'url_rest'), cf.get('GeoServer', 'user'), cf.get('GeoServer', 'pass'))

    # Raw data - remove NaN - remove outliers [Scipy z-score ]
    data = df[columname].tolist()
    data = [x for x in data if ~np.isnan(x)]
    threshold = 2 # 2 times standard deviation
    z = np.abs(stats.zscore(data))    
    outliers = np.where(z > threshold)    

    c = 0
    for o in outliers[0]:  
      del data[o-c]
      c+=1 # every time we remove an outlier indexes move one position
    
    # Autogenerate legend [ Percentiles / Gaussian / Z-score for outliers ] 
    minval = min(data)  
    maxval = max(data)
    meanval = statistics.mean(data)
    stdev = statistics.stdev(data)

    vals = [ meanval-2.0*stdev, meanval-stdev, meanval-0.4*stdev, meanval-0.2*stdev, meanval-0.1*stdev, 
             meanval, 
             meanval+0.1*stdev, meanval+0.2*stdev, meanval+0.4*stdev,  meanval+stdev, meanval+2.0*stdev ]
    logging.info(vals)
    
    # If all values are positive, shift legend [if it contains negative values]
    if minval>=0 and min(vals)<=0:
      vals = [ (v+2.0*stdev)/4.0 for v in vals]        
    
    # All values are the same
    diff = float(max(vals) - min(vals))
    if diff == 0:
      strstyle = """<?xml version="1.0" encoding="ISO-8859-1"?>
  <StyledLayerDescriptor version="1."
    xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1./StyledLayerDescriptor.xsd"
    xmlns="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <NamedLayer>
      <Name></Name>
      <UserStyle>      
        <FeatureTypeStyle>
                
          <Rule>
            <Title>{title}</Title>          
          </Rule> 
          <Rule>
            <Title>units = {subtitle}</Title>          
          </Rule>
          <Rule></Rule>

          <Rule>
           <Name>c0</Name>
           <Title>{v0}</Title>
           <ogc:Filter>
             <ogc:PropertyIsEqualTo>
               <ogc:PropertyName>{variable}</ogc:PropertyName>
               <ogc:Literal>{v0}</ogc:Literal>
             </ogc:PropertyIsEqualTo>
           </ogc:Filter>
           <PolygonSymbolizer>
             <Fill>
               <CssParameter name="fill">{c0}</CssParameter>
             </Fill>
             <Stroke>
               <CssParameter name="stroke">#000000</CssParameter>
               <CssParameter name="stroke-width">0.02</CssParameter>
             </Stroke>           
           </PolygonSymbolizer>
         </Rule>

       </FeatureTypeStyle>
      </UserStyle>
    </NamedLayer>
  </StyledLayerDescriptor>
      """.format(title=title, subtitle=subtitle, variable=columname, v0=vals[0], c0='#FFFFFF') 
    
    # Real legend - Legend rounding (Floats decimals [3], integers multiples of 10)
    else:      
      numdec = int(math.log10(1.0/diff)) + 3
      numxif = int(math.log10(diff)) - 1
      logging.info('INFO: minval={}, meanval={}, maxval={}, numdec={}, numxif={}'.format(min(vals), meanval, max(vals), min(data), max(data), numdec, numxif))        
      # Round up legend [two decimals]
      if numdec > 0:                
          vals = [round(i, numdec) for i in vals]
      else:
          vals = [int(i) for i in vals]
          #vals = [int(i/10**numxif)*10**numxif for i in vals]

      # 12 colors scale    
      cols = RdYlBu11
      cols.append('#654321')

      # Generate style [10 color template]
      strstyle = """<?xml version="1.0" encoding="ISO-8859-1"?>
  <StyledLayerDescriptor version="1."
    xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1./StyledLayerDescriptor.xsd"
    xmlns="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <NamedLayer>
      <Name></Name>
      <UserStyle>      
        <FeatureTypeStyle>
                
          <Rule>
            <Title>{title}</Title>          
          </Rule> 
          <Rule>
            <Title>units = {subtitle}</Title>          
          </Rule>
          <Rule></Rule>

          <Rule>
           <Name>c0</Name>
           <Title>Less Than {v0}</Title>
           <ogc:Filter>
             <ogc:PropertyIsLessThan>
               <ogc:PropertyName>{variable}</ogc:PropertyName>
               <ogc:Literal>{v0}</ogc:Literal>
             </ogc:PropertyIsLessThan>
           </ogc:Filter>
           <PolygonSymbolizer>
             <Fill>
               <CssParameter name="fill">{c0}</CssParameter>
             </Fill>
             <Stroke>
               <CssParameter name="stroke">#000000</CssParameter>
               <CssParameter name="stroke-width">0.02</CssParameter>
             </Stroke>           
           </PolygonSymbolizer>
         </Rule>

         <Rule>
           <Name>c1</Name>
           <Title>{v0} to {v1}</Title>
           <ogc:Filter>
             <ogc:And>
               <ogc:PropertyIsGreaterThanOrEqualTo>
                 <ogc:PropertyName>{variable}</ogc:PropertyName>
                 <ogc:Literal>{v0}</ogc:Literal>
               </ogc:PropertyIsGreaterThanOrEqualTo>
               <ogc:PropertyIsLessThan>
                 <ogc:PropertyName>{variable}</ogc:PropertyName>
                 <ogc:Literal>{v1}</ogc:Literal>
               </ogc:PropertyIsLessThan>
             </ogc:And>
           </ogc:Filter>
           <PolygonSymbolizer>
             <Fill>
               <CssParameter name="fill">{c1}</CssParameter>
             </Fill>
             <Stroke>
               <CssParameter name="stroke">#000000</CssParameter>
               <CssParameter name="stroke-width">0.02</CssParameter>
             </Stroke>           
           </PolygonSymbolizer>
         </Rule>

         <Rule>
           <Name>c2</Name>
           <Title>{v1} to {v2}</Title>
           <ogc:Filter>
             <ogc:And>
               <ogc:PropertyIsGreaterThanOrEqualTo>
                 <ogc:PropertyName>{variable}</ogc:PropertyName>
                 <ogc:Literal>{v1}</ogc:Literal>
               </ogc:PropertyIsGreaterThanOrEqualTo>
               <ogc:PropertyIsLessThan>
                 <ogc:PropertyName>{variable}</ogc:PropertyName>
                 <ogc:Literal>{v2}</ogc:Literal>
               </ogc:PropertyIsLessThan>
             </ogc:And>
           </ogc:Filter>
           <PolygonSymbolizer>
             <Fill>
               <CssParameter name="fill">{c2}</CssParameter>
             </Fill>
             <Stroke>
               <CssParameter name="stroke">#000000</CssParameter>
               <CssParameter name="stroke-width">0.02</CssParameter>
             </Stroke>           
           </PolygonSymbolizer>
         </Rule>
         
         <Rule>
           <Name>c3</Name>
           <Title>{v2} to {v3}</Title>
           <ogc:Filter>
             <ogc:And>
               <ogc:PropertyIsGreaterThanOrEqualTo>
                 <ogc:PropertyName>{variable}</ogc:PropertyName>
                 <ogc:Literal>{v2}</ogc:Literal>
               </ogc:PropertyIsGreaterThanOrEqualTo>
               <ogc:PropertyIsLessThan>
                 <ogc:PropertyName>{variable}</ogc:PropertyName>
                 <ogc:Literal>{v3}</ogc:Literal>
               </ogc:PropertyIsLessThan>
             </ogc:And>
           </ogc:Filter>
           <PolygonSymbolizer>
             <Fill>
               <CssParameter name="fill">{c3}</CssParameter>
             </Fill>
             <Stroke>
               <CssParameter name="stroke">#000000</CssParameter>
               <CssParameter name="stroke-width">0.02</CssParameter>
             </Stroke>           
           </PolygonSymbolizer>
         </Rule>
          
          <Rule>
           <Name>c4</Name>
           <Title>{v3} to {v4}</Title>
           <ogc:Filter>
             <ogc:And>
               <ogc:PropertyIsGreaterThanOrEqualTo>
                 <ogc:PropertyName>{variable}</ogc:PropertyName>
                 <ogc:Literal>{v3}</ogc:Literal>
               </ogc:PropertyIsGreaterThanOrEqualTo>
               <ogc:PropertyIsLessThan>
                 <ogc:PropertyName>{variable}</ogc:PropertyName>
                 <ogc:Literal>{v4}</ogc:Literal>
               </ogc:PropertyIsLessThan>
             </ogc:And>
           </ogc:Filter>
           <PolygonSymbolizer>
             <Fill>
               <CssParameter name="fill">{c4}</CssParameter>
             </Fill>
             <Stroke>
               <CssParameter name="stroke">#000000</CssParameter>
               <CssParameter name="stroke-width">0.02</CssParameter>
             </Stroke>           
           </PolygonSymbolizer>
         </Rule>
          
          <Rule>
           <Name>c5</Name>
           <Title>{v4} to {v5}</Title>
           <ogc:Filter>
             <ogc:And>
               <ogc:PropertyIsGreaterThanOrEqualTo>
                 <ogc:PropertyName>{variable}</ogc:PropertyName>
                 <ogc:Literal>{v4}</ogc:Literal>
               </ogc:PropertyIsGreaterThanOrEqualTo>
               <ogc:PropertyIsLessThan>
                 <ogc:PropertyName>{variable}</ogc:PropertyName>
                 <ogc:Literal>{v5}</ogc:Literal>
               </ogc:PropertyIsLessThan>
             </ogc:And>
           </ogc:Filter>
           <PolygonSymbolizer>
             <Fill>
               <CssParameter name="fill">{c5}</CssParameter>
             </Fill>
             <Stroke>
               <CssParameter name="stroke">#000000</CssParameter>
               <CssParameter name="stroke-width">0.02</CssParameter>
             </Stroke>           
           </PolygonSymbolizer>
         </Rule>
          
          <Rule>
           <Name>c6</Name>
           <Title>{v5} to {v6}</Title>
           <ogc:Filter>
             <ogc:And>
               <ogc:PropertyIsGreaterThanOrEqualTo>
                 <ogc:PropertyName>{variable}</ogc:PropertyName>
                 <ogc:Literal>{v5}</ogc:Literal>
               </ogc:PropertyIsGreaterThanOrEqualTo>
               <ogc:PropertyIsLessThan>
                 <ogc:PropertyName>{variable}</ogc:PropertyName>
                 <ogc:Literal>{v6}</ogc:Literal>
               </ogc:PropertyIsLessThan>
             </ogc:And>
           </ogc:Filter>
           <PolygonSymbolizer>
             <Fill>
               <CssParameter name="fill">{c6}</CssParameter>
             </Fill>
             <Stroke>
               <CssParameter name="stroke">#000000</CssParameter>
               <CssParameter name="stroke-width">0.02</CssParameter>
             </Stroke>           
           </PolygonSymbolizer>
         </Rule>
          
          <Rule>
           <Name>c7</Name>
           <Title>{v6} to {v7}</Title>
           <ogc:Filter>
             <ogc:And>
               <ogc:PropertyIsGreaterThanOrEqualTo>
                 <ogc:PropertyName>{variable}</ogc:PropertyName>
                 <ogc:Literal>{v6}</ogc:Literal>
               </ogc:PropertyIsGreaterThanOrEqualTo>
               <ogc:PropertyIsLessThan>
                 <ogc:PropertyName>{variable}</ogc:PropertyName>
                 <ogc:Literal>{v7}</ogc:Literal>
               </ogc:PropertyIsLessThan>
             </ogc:And>
           </ogc:Filter>
           <PolygonSymbolizer>
             <Fill>
               <CssParameter name="fill">{c7}</CssParameter>
             </Fill>
             <Stroke>
               <CssParameter name="stroke">#000000</CssParameter>
               <CssParameter name="stroke-width">0.02</CssParameter>
             </Stroke>           
           </PolygonSymbolizer>
         </Rule>
          
          <Rule>
           <Name>c8</Name>
           <Title>{v7} to {v8}</Title>
           <ogc:Filter>
             <ogc:And>
               <ogc:PropertyIsGreaterThanOrEqualTo>
                 <ogc:PropertyName>{variable}</ogc:PropertyName>
                 <ogc:Literal>{v7}</ogc:Literal>
               </ogc:PropertyIsGreaterThanOrEqualTo>
               <ogc:PropertyIsLessThan>
                 <ogc:PropertyName>{variable}</ogc:PropertyName>
                 <ogc:Literal>{v8}</ogc:Literal>
               </ogc:PropertyIsLessThan>
             </ogc:And>
           </ogc:Filter>
           <PolygonSymbolizer>
             <Fill>
               <CssParameter name="fill">{c8}</CssParameter>
             </Fill>
             <Stroke>
               <CssParameter name="stroke">#000000</CssParameter>
               <CssParameter name="stroke-width">0.02</CssParameter>
             </Stroke>           
           </PolygonSymbolizer>
         </Rule>
          
          <Rule>
           <Name>c9</Name>
           <Title>{v8} to {v9}</Title>
           <ogc:Filter>
             <ogc:And>
               <ogc:PropertyIsGreaterThanOrEqualTo>
                 <ogc:PropertyName>{variable}</ogc:PropertyName>
                 <ogc:Literal>{v8}</ogc:Literal>
               </ogc:PropertyIsGreaterThanOrEqualTo>
               <ogc:PropertyIsLessThan>
                 <ogc:PropertyName>{variable}</ogc:PropertyName>
                 <ogc:Literal>{v9}</ogc:Literal>
               </ogc:PropertyIsLessThan>
             </ogc:And>
           </ogc:Filter>
           <PolygonSymbolizer>
             <Fill>
               <CssParameter name="fill">{c9}</CssParameter>
             </Fill>
             <Stroke>
               <CssParameter name="stroke">#000000</CssParameter>
               <CssParameter name="stroke-width">0.02</CssParameter>
             </Stroke>           
           </PolygonSymbolizer>
         </Rule>

          <Rule>
           <Name>c9</Name>
           <Title>{v9} to {v10}</Title>
           <ogc:Filter>
             <ogc:And>
               <ogc:PropertyIsGreaterThanOrEqualTo>
                 <ogc:PropertyName>{variable}</ogc:PropertyName>
                 <ogc:Literal>{v9}</ogc:Literal>
               </ogc:PropertyIsGreaterThanOrEqualTo>
               <ogc:PropertyIsLessThan>
                 <ogc:PropertyName>{variable}</ogc:PropertyName>
                 <ogc:Literal>{v10}</ogc:Literal>
               </ogc:PropertyIsLessThan>
             </ogc:And>
           </ogc:Filter>
           <PolygonSymbolizer>
             <Fill>
               <CssParameter name="fill">{c10}</CssParameter>
             </Fill>
             <Stroke>
               <CssParameter name="stroke">#000000</CssParameter>
               <CssParameter name="stroke-width">0.02</CssParameter>
             </Stroke>           
           </PolygonSymbolizer>
         </Rule>

         <Rule>
           <Name>c10</Name>
           <Title>More than {v10}</Title>
           <ogc:Filter>
             <ogc:PropertyIsGreaterThanOrEqualTo>
               <ogc:PropertyName>{variable}</ogc:PropertyName>
               <ogc:Literal>{v10}</ogc:Literal>
             </ogc:PropertyIsGreaterThanOrEqualTo>
           </ogc:Filter>
           <PolygonSymbolizer>
             <Fill>
               <CssParameter name="fill">{c11}</CssParameter>
             </Fill>
             <Stroke>
               <CssParameter name="stroke">#000000</CssParameter>
               <CssParameter name="stroke-width">0.02</CssParameter>
             </Stroke>           
           </PolygonSymbolizer>
         </Rule>

       </FeatureTypeStyle>
      </UserStyle>
    </NamedLayer>
  </StyledLayerDescriptor>
      """.format(title=title, subtitle=subtitle, variable=columname, 
          v0=vals[0], v1=vals[1], v2=vals[2], v3=vals[3], v4=vals[4], v5=vals[5], v6=vals[6], v7=vals[7], v8=vals[8], v9=vals[9], v10=vals[10],
          c0=cols[0], c1=cols[1], c2=cols[2], c3=cols[3], c4=cols[4], c5=cols[5], c6=cols[6], c7=cols[7], c8=cols[8], c9=cols[9], c10=cols[10], c11=cols[11])

    # Create Geoserver style    
    logging.info('INFO: sld_style={}, column={}'.format(sld_style, columname))
    cat.create_style(sld_style, strstyle, overwrite=True)
    
    return sld_style