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

# $Id: coords.py 13711 2017-09-13 14:52:48Z sala $
# $Date: 2017-09-13 16:52:48 +0200 (Wed, 13 Sep 2017) $
# $Author: sala $
# $Revision: 13711 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/endure/insertTransects.py $
# $Keywords: $

from sqlalchemy import create_engine
from utils import *

# SQL Functions
def dropTable(engine):
    sqlstr = 'DROP TABLE IF EXISTS endure_transects'
    res = engine.execute(sqlstr)

def createTable(engine, header):    
    ## Create table
    sql1 = 'CREATE TABLE endure_transects(geom geometry, '
    for h in header:
        sql1 += '{} text, '.format(h)
    sql1 = sql1[:-2]
    sql1+=');'
    res = engine.execute(sql1)

    ## Add index
    sql2='CREATE INDEX endure_transects_geom ON endure_transects USING gist(geom);'
    res = engine.execute(sql2)

def insertTransect(engine, fields, data, idx_coords):
    values=''
    for d in data:
        values += '\'{}\','.format(d)
    values = values[:-1]

    ## Linestring
    wkt_string = 'LINESTRING ({x0} {y0}, {x1} {y1})'.format(x0=data[idx_coords[0]], x1=data[idx_coords[1]], y0=data[idx_coords[2]], y1=data[idx_coords[3]])

    ## Insert values
    sqlstr = '''INSERT INTO endure_transects(geom,{ff}) VALUES (ST_GeomFromText('{wkt}', {epsg}),{vv})'''.format(ff=fields, vv=values, epsg=4326, wkt=wkt_string)
    res = engine.execute(sqlstr)

# Configuration [inputs]
CONFIG_FILE=os.path.join(os.path.dirname(os.path.realpath(__file__)), 'config.txt')
csv_file='./Endure_transects.csv'
idx_coords = [6,7,8,9] # index coordinates linestring

# Read configuration
PLOTS_DIR, APACHE_DIR, ENGINE = readConfig(CONFIG_FILE)

# Read CSV
with open(csv_file, 'r') as fp:
   
   # Header
   header = fp.readline()
   fields = header.split(',')
   nf = len(fields)
   dropTable(ENGINE)
   createTable(ENGINE, fields)

   # Content
   line = fp.readline()
   while line:    
       dataf = line.split(',')
       if len(dataf) == nf:
          insertTransect(ENGINE, header, dataf, idx_coords)

       # Next
       line = fp.readline()

fp.close()