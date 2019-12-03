# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2019 Deltares
#       Joan Sala, Gerrit Hendriksen
#
#       joan.salacalero@deltares.nl, gerrit.hendriksen@deltares.nl
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

# $Id: utils.py 14277 2018-04-06 08:43:39Z sala $
# $Date: 2018-04-06 10:43:39 +0200 (vr, 06 apr 2018) $
# $Author: sala $
# $Revision: 14277 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/NutrientenAanpakMaas/utils.py $
# $Keywords: $

import ConfigParser
import math
import time
import logging
import os
import tempfile
import sqlfunctions

import simplejson as json
from pyproj import Proj, transform
from owslib.wfs import WebFeatureService
from owslib.wcs import WebCoverageService
from osgeo import gdal
from sqlalchemy import create_engine

# Read configuration from file
def readConfig(configf):
    cf = ConfigParser.RawConfigParser()  
    cf.read(configf)
    PLOTS_DIR = cf.get('Bokeh', 'plots_dir')
    APACHE_DIR = cf.get('Bokeh', 'apache_dir')
    ENGINE = create_engine('postgresql+psycopg2://'+cf.get('PostGIS', 'user')
    +':'+cf.get('PostGIS', 'pass')+'@'+cf.get('PostGIS', 'host')+':'+str(cf.get('PostGIS', 'port'))
    +'/'+cf.get('PostGIS', 'db'), strategy='threadlocal')

    return PLOTS_DIR, APACHE_DIR, ENGINE

# Parameters check
def check_location(location, epsgin='epsg:3857'):        
    # Valid JSON
    try:
        # Input (coordinates)  
        if isinstance(location, basestring):  
            location_info = json.loads(location)            
            (xin,yin) = location_info['x'], location_info['y']
        else:
            location_info = location
            (xin,yin) = location_info[0], location_info[1]
        
        (lon,lat) = change_coords(xin, yin)
        logging.info('''Input Coordinates {} {} -> {} {}'''.format(xin,yin,lon,lat))  
    except Exception as e: 
        logging.error(e)
        return False, '''<p>Please select a location first with the 'Select on map' button</p>''', -1, -1

    # Parameters check OK 
    return True, '', xin, yin

# Get a unique temporary file
def getTempFile(tempdir):
    dirname = str(time.time()).replace('.','')
    return os.path.join(tempdir, dirname+'.html')

# Change XY coordinates general function
def change_coords(px, py, epsgin='epsg:3857', epsgout='epsg:4326'):
    outProj = Proj(init=epsgout)
    inProj = Proj(init=epsgin)
    return transform(inProj, outProj, px, py)

# Get closest point to user click [shoreline transects]
def queryPostGISClosestPoint(engine, xk, yk, fields, table, where, epsg=4326):
    
    # I know it is not ideal but...
    if where == None:
        where = '1 = 1'

    # Look for closes transect ()
    sql = """SELECT {ff}, ST_Distance(ST_PointFromText('POINT({x} {y})','{e}'), geom) as clickdist
             FROM {t}
             WHERE {ww}
             ORDER BY clickdist
             LIMIT 1
            """.format(ff=fields, x=xk, y=yk, e=epsg, t=table, ww=where)     
    res = engine.execute(sql)
    
    # TRANSECT DB info        
    for r in res:        
        return r
    return False # not found

# Generate html with tabs
def rr(f):
    try:
        return round(float(f),1)
    except:
        return f

def generateHtml(temp_html, regimepngname_current, resultpngname_current, regimepngname_SLR, resultpngname_SLR, wavepngname, description, SSL, beachslope, bruun, dhigh, Hs, Tp,desc_regime_slr):
    html_str = '''<head>
      <link rel="stylesheet" type="text/css" href="../endure/site/css/transect_tab.css">
    </head>

    <body onload="openTab(event, 'statslr')">
      <script src="../endure/site/js/transect_tab.js"></script>

      <!-- Tab links -->
      <div class="tab">
        <button class="tablinks" onclick="openTab(event, 'statcur')">Current state</button>
        <button class="tablinks" onclick="openTab(event, 'regcur')">Current regime</button>
        <button id="defaultOpen" class="tablinks" onclick="openTab(event, 'statslr')">State + SLR</button>
        <button class="tablinks" onclick="openTab(event, 'regslr')">Regime + SLR</button>
        <button class="tablinks" onclick="openTab(event, 'background')">Background</button>
        <button class="tablinks" onclick="openTab(event, 'summary')">Parameters</button>
      </div>

      <!-- Tab content -->
      <div id="statcur" class="tabcontent">
        <img src="../endure/data/{rescur}" style="height: 370px; width: 670px" alt="current status">
      </div>

      <div id="regcur" class="tabcontent">
        <p>{desc}</p>
        <img src="../endure/data/{regcur}" style="width: 670px" alt="current regime">
        <p class="stext">Source of figure: Goslin, Jerome & Clemmensen, Lars. (2017). Proxy records of Holocene storm events in coastal barrier systems: Storm-wave induced markers. Quaternary Science Reviews. 174. 80-119. <a href"https://www.sciencedirect.com/science/article/abs/pii/S0277379117305516" target="_blank">10.1016/j.quascirev.2017.08.026</a></p>
      </div>      

      <div id="statslr" class="tabcontent">
        <img src="../endure/data/{resslr}" style="height: 370px; width: 670px" alt="slr status">
      </div>  

      <div id="regslr" class="tabcontent">
        <p>{desc_slr}</p>
        <img src="../endure/data/{regslr}" style="width: 670px" alt="slr regime">
        <p class="stext">Source of figure: Goslin, Jerome & Clemmensen, Lars. (2017). Proxy records of Holocene storm events in coastal barrier systems: Storm-wave induced markers. Quaternary Science Reviews. 174. 80-119. <a href"https://www.sciencedirect.com/science/article/abs/pii/S0277379117305516" target="_blank">10.1016/j.quascirev.2017.08.026</a></p>
      </div> 

      <div id="background" class="tabcontent">
        <div id="content" class="row">
            <div class="scolumn">
                <p class="stext">The Swash regime describes a storm where wave runup is confined below the dune foot. During a storm the foreshore typically erodes and recovers afterwards.</p>
                <p class="stext">The Collision regime during is describing a storm where the wave runup exceeds the dune foot, but is below the top of the dune. The front of the dune is impacted by the storm.</p>
                <p class="stext">The Overwash regime describes a storm where wave runup overtops the top of the dune. Because of this sediment is transported landwards, the overtopping waves may lead to flooding issues in the hinterland.</p>
                <p class="stext">The Inundation regime describes a storm where the storm surge is sufficient to completely and continuously submerge the dune system. A lot of sediment is transported landward and there if significant flooding of the hinterland.</p>
                <p class="stext">Source of figures: Goslin, Jerome & Clemmensen, Lars. (2017). Proxy records of Holocene storm events in coastal barrier systems: Storm-wave induced markers. Quaternary Science Reviews. 174. 80-119. <a href"https://www.sciencedirect.com/science/article/abs/pii/S0277379117305516" target="_blank">10.1016/j.quascirev.2017.08.026</a></p>
            </div>            
            <div class="bcolumn">             
             <img src="../endure/data/{allreg}" style="width: 450px" alt="slr regime">
            </div>
            <br style="clear:both;"/>
        </div>
      </div>

      <div id="summary" class="tabcontent">
        <table style="width:100%">
          <tr>
            <th style="text-align: left">Parameter</th>
            <th style="text-align: left">Value</th>
            <th style="text-align: left">Units</th>            
          </tr>
          <tr>
            <td>Storm surge level</td><td>{ssl}</td><td>meters</td>
          </tr>
          <tr>
            <td>Beach slope</td><td>{beachslope}</td><td>1/meters</td>
          </tr>
          <tr>
            <td>Dune retreat</td><td>{bruun}</td><td>meters</td>
          </tr>
          <tr>
            <td>Maximum runup height</td><td>{dhigh}</td><td>meters</td>
          </tr>
          <tr>
            <td>Offshore wave height</td><td>{hs}</td><td>meters</td>
          </tr>
          <tr>
            <td>Offshore wave period</td><td>{tp}</td><td>seconds</td>
          </tr>                                        
        </table>      
      </div>
    </body>'''.format(regcur=regimepngname_current, rescur=resultpngname_current, regslr=regimepngname_SLR, resslr=resultpngname_SLR, allreg='all_regimes.png', desc=description, ssl=rr(SSL), beachslope=rr(beachslope), bruun=rr(bruun), dhigh=rr(dhigh), hs=rr(Hs), tp=rr(Tp),desc_slr=desc_regime_slr)

    # Write to file
    with open(temp_html, "w") as tf:
        tf.write(html_str)