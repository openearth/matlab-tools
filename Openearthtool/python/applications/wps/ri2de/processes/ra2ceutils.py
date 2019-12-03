# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares
#       Gerrit Hendriksen
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

import os
import json
import configparser
from sqlalchemy import create_engine, exc
import logging

def calccosts(cf, layer_name, json_matrix):
	# calccost function calculates recalcutes the visualisation caterogies
	engine = create_engine('postgresql+psycopg2://'+cf.get('PostGis', 'user')
			    +':'+cf.get('PostGis', 'pass')+'@'+cf.get('PostGis', 'host')+':'+str(cf.get('PostGis', 'port'))
			    +'/'+cf.get('PostGis', 'db'), strategy='threadlocal', pool_pre_ping=True)

	try:
    	#first set everything to 0 and create a new view
		strSql = """drop table temp.classroads"""
		ressql = engine.execute(strSql)
	except Exception as e:
		logging.info("Table temp.classroads did not exist so it cannot be dropped: {}".format(e))

	try:
		strSql = """create table temp.classroads as select shape, societal_class, repair_class, 0 as visclass from ra2ce.{layer_name}_prioriteiten""".format(layer_name=layer_name)
		ressql = engine.execute(strSql)
	except exc.DBAPIError as e:
		# an exception is raised, Connection is invalidated.
		if e.connection_invalidated:
			logging.info("Connection was invalidated!")

	data = json.loads(json_matrix)
	values = data["values"]

	#todo here create new layer (view) and add this to the geoserver
	for societalIndex in range(len(values)):
		for repairIndex in range(len(values[societalIndex])):
		    strSql = """update temp.classroads set visclass = {val}
                            where societal_class = {s} and repair_class = {r}""".format(val=values[societalIndex][repairIndex],s=societalIndex+1,r=repairIndex+1)
		    ressql = engine.execute(strSql)
		ressql.close()

	res = writeOutput(cf=cf, wmslayer="ra2ce:classroads", defstyle="ra2ce")

	return res

def select_from_db(cf, LayerName):
# TO DO: delete
    #	engine = create_engine('postgresql+psycopg2://'+cf.get('PostGis', 'user')
#			    +':'+cf.get('PostGis', 'pass')+'@'+cf.get('PostGis', 'host')+':'+str(cf.get('PostGis', 'port'))
#			    +'/'+cf.get('PostGis', 'db'), strategy='threadlocal')

    # get layer/table from postgresql
	layer_operator_costs = 'ra2ce:' + LayerName + '_herstelkosten'
	layer_societal_costs = 'ra2ce:' + LayerName + '_stremmingskosten'

    # TO DO: input for different legends
	res_operator = writeOutput(cf=cf, wmslayer=layer_operator_costs, defstyle="ra2ce")
	res_societal = writeOutput(cf=cf, wmslayer=layer_societal_costs, defstyle="ra2ce")

	return res_operator, res_societal

# Read default configuration from file
def readConfig():
	# Default config file (relative path, does not work on production, weird)
    if os.name == 'nt':
        logging.info('os not found')
        devpath = r'C:\working-copies\ri2de\processes'
        confpath = os.path.join(devpath,'ra2ce_configuration.txt')
    else:
        confpath = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'ra2ce_configuration.txt')
    if not os.path.exists(confpath):
        confpath = '/opt/pywps/processes/ra2ce_configuration.txt'

	# Parse and load
    cf = configparser.ConfigParser()
    cf.read(confpath)
    return cf

# Write output
def writeOutput(cf, wmslayer, defstyle='ri2de'):
	res = dict()
	res['baseUrl'] = cf.get('GeoServer', 'wms_url')
	res['layerName'] = wmslayer
	res['style'] = defstyle
	return json.dumps(res)