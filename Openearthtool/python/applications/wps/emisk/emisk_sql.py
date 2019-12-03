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

# $Id: emisk_sql.py 14132 2018-01-30 19:06:23Z sala $
# $Date: 2018-01-30 11:06:23 -0800 (Tue, 30 Jan 2018) $
# $Author: sala $
# $Revision: 14132 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/emisk/emisk_sql.py $
# $Keywords: $

import logging
import pyodbc

# Connect to localhost with default params
def create_connection(sql_db, sql_host, sql_user, sql_pass):	
	conn = pyodbc.connect('DRIVER={SQL Server};SERVER=('+sql_host+')\SQLEXPRESS;DATABASE='+sql_db+';UID='+sql_user+';PWD='+sql_pass)
	return conn

# Execute query and give back array results
def executeQuery(sql_db, sql_host, sql_user, sql_pass, sqlstr):
	conn = create_connection(sql_db, sql_host, sql_user, sql_pass)
	cur = conn.cursor()
	cur.execute(sqlstr)
	res = cur.fetchall()
	return res

# Pre-cooked queries
def sql_gwlevels_vs_time(sql_db, sql_host, sql_user, sql_pass, locid, parameterkey=10):
	# Prepare query
	sqlstr='''
		SELECT timeseriesvaluesandflags.datetime, timeseriesvaluesandflags.scalarvalue
		FROM location INNER JOIN timeseries ON location.locationkey = timeseries.locationkey INNER JOIN timeseriesvaluesandflags ON timeseries.serieskey = timeseriesvaluesandflags.serieskey
		WHERE (timeseries.parameterkey = {}) AND (location.locationkey = {})
		ORDER BY location.locationkey, timeseriesvaluesandflags.datetime
	'''.format(parameterkey, locid)
	logging.info(sqlstr)

	# Execute
	res=executeQuery(sql_db, sql_host, sql_user, sql_pass, sqlstr)
	logging.info('Returned {} values'.format(len(res)))
	return res

def sql_sptvalues_vs_depth(sql_db, sql_host, sql_user, sql_pass, locid):
	sqlstr='''
	    SELECT standardpenetrationtest.depth_m, standardpenetrationtest.N_value
		FROM location INNER JOIN borehole ON location.locationkey = borehole.idlocation INNER JOIN standardpenetrationtest ON borehole.idborehole = standardpenetrationtest.idborehole
		WHERE (location.locationkey = {})
		ORDER BY location.locationkey, standardpenetrationtest.depth_m	
	'''.format(locid)
	logging.info(sqlstr)

	# Execute
	res=executeQuery(sql_db, sql_host, sql_user, sql_pass, sqlstr)
	logging.info('Returned {} values'.format(len(res)))
	return res

def sql_lithology_vs_depth(sql_db, sql_host, sql_user, sql_pass, locid):
	sqlstr='''
		SELECT location.locationkey, location.name, boreholedescription.lithologydesc, boreholedescription.topdepth, boreholedescription.botdepth, geologicalperiod.period, 
		         color.color, color.colorstandard
		FROM location INNER JOIN
		     borehole ON location.locationkey = borehole.idlocation INNER JOIN
		     boreholedescription ON borehole.idborehole = boreholedescription.idborehole INNER JOIN
		     color ON boreholedescription.idcolor = color.idcolor INNER JOIN
		     geologicalperiod ON boreholedescription.idgeologicalperiod = geologicalperiod.idgeologicalperiod
		WHERE (location.locationkey = {})
		ORDER BY location.locationkey, boreholedescription.topdepth	
	'''.format(locid)
	logging.info(sqlstr)

	# Execute
	res=executeQuery(sql_db, sql_host, sql_user, sql_pass, sqlstr)
	logging.info('Returned {} values'.format(len(res)))
	return res	

def sql_get_lithologyRows_bbox(sql_db, sql_host, sql_user, sql_pass, xmin, xmax, ymin, ymax):
	sqlstr='''
		SELECT        location.locationkey, location.name, location.shortname, location.x, location.y, location.z, location.dd_long, location.dd_lat, location.utm_x, location.utm_y, 
		                         borehole.borehole_nm, borehole.purpose_dsc, borehole.drilling_method, borehole.drilling_depth, grainsize.name AS Grainsize, lithifaction.name AS Lithifaction, 
		                         maintype.name AS Main_type, methoddescription.method, subtype.name AS Sub_type, color.color, geologicalformation.name AS Geological_formation, 
		                         geologicalperiod.period AS Geological_period, boreholedescription.lithologydesc, boreholedescription.topdepth, boreholedescription.botdepth
		FROM            borehole INNER JOIN
		                         boreholedescription ON borehole.idborehole = boreholedescription.idborehole INNER JOIN
		                         location ON borehole.idlocation = location.locationkey INNER JOIN
		                         color ON boreholedescription.idcolor = color.idcolor INNER JOIN
		                         geologicalformation ON boreholedescription.idgeologicalformation = geologicalformation.idgeologicalformation INNER JOIN
		                         geologicalperiod ON boreholedescription.idgeologicalperiod = geologicalperiod.idgeologicalperiod INNER JOIN
		                         grainsize ON boreholedescription.idgrainsize = grainsize.idgrainsize INNER JOIN
		                         lithifaction ON boreholedescription.idlithifaction = lithifaction.idlithifaction INNER JOIN
		                         maintype ON boreholedescription.idmaintype = maintype.idmaintype INNER JOIN
		                         methoddescription ON boreholedescription.idmethoddesc = methoddescription.idmethoddesc INNER JOIN
		                         subtype ON boreholedescription.idsubtype = subtype.idsubtype
		WHERE    location.x >= {} and location.x <= {} and location.y >= {} and location.y <= {} 
		ORDER BY location.name, boreholedescription.topdepth
	'''.format(xmin, xmax, ymin, ymax)
	logging.info(sqlstr)

	# Execute
	res=executeQuery(sql_db, sql_host, sql_user, sql_pass, sqlstr)
	logging.info('Returned {} values'.format(len(res)))

	# Header
	head = [ 'location.locationkey', 'location.name', 'location.shortname', 'location.x', 'location.y', 'location.z', 'location.dd_long', 'location.dd_lat', 'location.utm_x', 
	'location.utm_y', 'borehole.borehole_nm', 'borehole.purpose_dsc', 'borehole.drilling_method', 'borehole.drilling_depth', 'Grainsize', 'Lithifaction','Main_type', 
	'methoddescription.method', 'Sub_type', 'color.color', 'Geological_formation', 'Geological_period', 'boreholedescription.lithologydesc', 'boreholedescription.topdepth', 
	'boreholedescription.botdepth']
	return res, head	

def sql_get_groudwaterRows_bbox(sql_db, sql_host, sql_user, sql_pass, xmin, xmax, ymin, ymax):
	sqlstr='''
		SELECT        location.locationkey, location.name, location.shortname, location.x, location.y, location.z, location.dd_long, location.dd_lat, location.utm_x, location.utm_y, 
		                         borehole.borehole_nm, parameterstable.name AS Parameter, parametergroups.name AS Parameter_group, timeseriesvaluesandflags.datetime, 
		                         timeseriesvaluesandflags.scalarvalue, timeseriescomments.datetime AS Date_comments, timeseriescomments.commenttext
		FROM            location INNER JOIN
		                         borehole ON location.locationkey = borehole.idlocation INNER JOIN
		                         timeseries ON location.locationkey = timeseries.locationkey INNER JOIN
		                         timeseriescomments ON timeseries.serieskey = timeseriescomments.serieskey INNER JOIN
		                         timeseriesvaluesandflags ON timeseries.serieskey = timeseriesvaluesandflags.serieskey INNER JOIN
		                         parameterstable ON timeseries.parameterkey = parameterstable.parameterkey INNER JOIN
		                         parametergroups ON parameterstable.groupkey = parametergroups.groupkey
		WHERE    location.x >= {} and location.x <= {} and location.y >= {} and location.y <= {} and parameterstable.name LIKE 'Groundwater levels'
		ORDER BY location.locationkey, timeseriesvaluesandflags.datetime
	'''.format(xmin, xmax, ymin, ymax)
	logging.info(sqlstr)

	# Execute
	res=executeQuery(sql_db, sql_host, sql_user, sql_pass, sqlstr)
	logging.info('Returned {} values'.format(len(res)))

	# Header
	head = [ 'location.locationkey', 'location.name', 'location.shortname', 'location.x', 'location.y', 'location.z', 'location.dd_long', 'location.dd_lat', 'location.utm_x', 'location.utm_y', 
	  'borehole.borehole_nm', 'Parameter', 'Parameter_group', 'timeseriesvaluesandflags.datetime', 'timeseriesvaluesandflags.scalarvalue', 'Date_comments', 'timeseriescomments.commenttext']
	return res, head
	