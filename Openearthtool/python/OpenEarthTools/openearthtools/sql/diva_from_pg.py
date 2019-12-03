# -*- coding: utf-8 -*-
"""
Created on Thu Jan 21 11:18:38 2016

@author: hendrik_gt
"""
# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
#       Gerrit Hendriksen
#
#       gerrit.hendriksen@deltares.nl
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

# $Id: opendap_nhi.py 12405 2015-12-02 07:25:40Z hendrik_gt $
# $Date: 2015-12-02 08:25:40 +0100 (wo, 02 dec 2015) $
# $Author: hendrik_gt $
# $Revision: 12405 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/infoline/opendap_nhi.py $
# $Keywords: $

# import from https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/sql
import sqlfunctions

# save to store the credentials in a textfile with following lines
cf = r'\pgconnection_diva.txt'
credentials = sqlfunctions.get_credentials(cf)

# 3 layers are present
# diva_segments
# surge_levels_diva
# surge_levers_diva_segments (combination of both)
# display comments (unfortunately the only metadata provided by Martin Verlaan)
strSql = """SELECT relname, obj_description(oid)
            FROM pg_class
            WHERE relname like '%diva%' and relkind = 'r'
         """
a = sqlfunctions.executesqlfetch(strSql, credentials)
for c in a:
    print(': '.join(['comment for layer', c[0]]))
    print(c[1])
    print('')

# get entire diva segments table.
# note that the data is in the oceanographic schema of the global database of the Deltares Data Portal
strSql = "select * from oceanographic.diva_segments"
a = sqlfunctions.executesqlfetch(strSql, credentials)

# get data by attribute _plt_yyyy__ or something
# select all diva segments with id 12147 in the station name
strSql = "select * from oceanographic.diva_segments where station like '%12147%'"
a = sqlfunctions.executesqlfetch(strSql, credentials)

# select a diva segment which is intersect by a line -80.58,0.16 to -80.00,-0.33
wktline = 'LINESTRING(-80.58 0.16,-80.00 -0.33)'
strSql = """select * from oceanographic.diva_segments 
        where st_intersects(st_linefromtext('{l}',4326),geom)""".format(l=wktline)
a = sqlfunctions.executesqlfetch(strSql, credentials)

# select diva segment closest to a certain point
wktpoint = 'POINT(-80.58 0.16)'
strSql = """select * from oceanographic.diva_segments
        order by ST_Distance(st_pointfromtext('{l}',4326),geom)
        limit 1""".format(l=wktpoint)
a = sqlfunctions.executesqlfetch(strSql, credentials)

# select all surge_levels_diva related to station name durban
strSql = """select * from oceanographic.surge_levels_diva 
        where lower(station) like '%durban%'"""
a = sqlfunctions.executesqlfetch(strSql, credentials)

# the last table is surge_levels_dive mapped to diva_segments
# actually it is quite a lot of redundant information because, so fur durban it becomes
# for each table an alias has been assigned (s for diva_segments table)
strSql = """select * from oceanographic.diva_segments s
            join oceanographic.surge_levels_diva d on d.station = s.station
            where lower(d.station) like '%durban%'"""
a = sqlfunctions.executesqlfetch(strSql, credentials)

#for the above line string, rp00010 becomes
strSql = """select rp00010 from oceanographic.diva_segments s
            join oceanographic.surge_levels_diva d on d.station = s.station
            where st_intersects(st_linefromtext('{l}',4326),s.geom)""".format(l=wktline)
a = sqlfunctions.executesqlfetch(strSql, credentials)

# for more exotics just ask gerrit.hendriksen@deltares.nl