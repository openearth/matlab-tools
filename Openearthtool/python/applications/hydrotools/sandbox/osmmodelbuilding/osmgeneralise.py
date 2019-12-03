# -*- coding: utf-8 -*-
#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares for OSM HydroProjects
#       Gerrit Hendriksen@deltares.nl
#       Hessel.winsemius@deltares.nl
#       dirk.eilander@deltares.nl
#       mark.hegnauer@deltares.nl
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

# $Id: orm_initializehydrodb.py 938 2016-06-16 14:03:03Z hendrik_gt $
# $Date: 2016-06-16 16:03:03 +0200 (Thu, 16 Jun 2016) $
# $Author: hendrik_gt $
# $Revision: 938 $
# $HeadURL: https://repos.deltares.nl/repos/NHI/trunk/engines/HMDB/orm_initializehydrodb.py $
# $Keywords: $

import sys
import subprocess
import sqlfunctions

fc = r'd:\projecten\datamanagement\openearth\repos\applications\hydrotools\sandbox\osmmodelbuilding\connection_ddp.txt'
credentials= sqlfunctions.get_credentials(fc)

# subprocess
#ogr2ogr -f "PostgreSQL" PG:"host=localhost user=postgres dbname=osmhydro password=ghn@DELTARES port=5432" D:\projecten\datamanagement\openearth\repos\applications\hydrotools\sandbox\osmmodelbuilding\tanzania-latest.osm.pbf -lco COLUMN_TYPES=other_tags=hstore
args = ['ogr2ogr', '-f "PostgreSQL" PG:"host=localhost user=postgres dbname=osmhydro password=ghn@DELTARES port=5432"', 
        'D:\projecten\datamanagement\openearth\repos\applications\hydrotools\sandbox\osmmodelbuilding\tanzania-latest.osm.pbf', 
        '-lco COLUMN_TYPES=other_tags=hstore']
try:
    subprocess.call(args)
except BaseException as err:
    print err.args
    print 'Please check:'
    print '  if ogr2ogr is in path environment, perhaps start it from osgeo directory'
    sys.exit()

# create extension HSTORE
strSql = """create extension HSTORE """
sqlfunctions.perform_sql(strSql,credentials)
# check if table exists
strSql = """drop table if exists osmwaterways;"""
sqlfunctions.perform_sql(strSql,credentials)

# create table osmwaterways from waterway for the list
strSql = """
create table osmwaterways as
select * from lines where
waterway in ('river','drain','stream','canal','ditch');"""
sqlfunctions.perform_sql(strSql,credentials)

# combine alll waterways to 1 object
strSql = """create table waterways
as select st_collect(wkb_geometry),* from osmwaterways
"""
sqlfunctions.perform_sql(strSql,credentials)

# split the waterways on the junctions
strSql = """create table newlines as
SELECT row_number() OVER() new_id, geom FROM
  (SELECT 
    (ST_Dump(ST_Node(ST_Union(wkb_geometry)))).geom geom 
  FROM osmrivers) a  """
sqlfunctions.perform_sql(strSql,credentials)
  