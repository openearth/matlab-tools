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

# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/ri2de/processes/wps_ri2de_slope.py $
# $Keywords: $
# http://localhost:5000/wps?request=Execute&service=WPS&identifier=ra2ce_calc_ratio&version=1.0.0&inputs=[uid=testing;json_matri={'values':[[1,1,3,1,1],[1,1,4,1,1],[1,1,5,1,1],[1,1,2,1,1],[1,1,1,1,5]]}]
# PyWPS
from pywps import Process, Format, FORMATS
from pywps.inout.inputs import ComplexInput, LiteralInput
from pywps.inout.outputs import ComplexOutput
from pywps.app.Common import Metadata

# other
import json

# local


class WpsRa2ceRatio(Process):

	def __init__(self):
		# Input [in json format ]
		inputs = [LiteralInput('uid', 'User Identifier', data_type='string'),
				  ComplexInput('json_matrix', 'matrix with priorities',
		                       [Format('application/json')],
		                       abstract="Complex input abstract", )]

		# Output [in json format]
		outputs = [ComplexOutput('output_json',
		                         'Ra2ce calculation of costs',
		                         supported_formats=[Format('application/json')])]

		super(WpsRa2ceRatio, self).__init__(
		    self._handler,
		    identifier='ra2ce_calc_ratio',
		    version='1.0',
		    title='backend process for the RA2CE POC, calculates the ratio between Annual Repair costs and Societial Costs',
		    abstract='It uses PostgreSQL to calculate the ratio\
		     using 2 columns of a table and answer via a JSON reply, wrapped in the xml/wps format with the wmslayer to show',
		    profile='',
		    metadata=[Metadata('WpsRa2ceRatio'), Metadata('Ra2CE/ratio')],
		    inputs=inputs,
		    outputs=outputs,
		    store_supported=False,
		    status_supported=False
		)

	## MAIN
	def _handler(self, request, response):

		try:
			# Read configuration
			#cf = readConfig()

			# Read input
			#json_matrix = request.inputs["json_matrix"][0].data
			#uid = request.inputs["uid"][0].data.strip()
			#calccosts(cf,uid, json_matrix)

			res = dict()
			res['baseUrl'] = "https://ri2de.openearth.eu/geoserver/ows"
			res['layerName'] = "ra2ce:classroads_testing"
			res['style'] = 'ra2ce'
                     
			# Set output
			response.outputs['output_json'].data = json.dumps(res)
		
		except Exception as e:
			res = { 'errMsg' : 'ERROR: {}'.format(e) }
			response.outputs['output_json'].data = json.dumps(res)	

		return response

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

# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/ri2de/processes/wps_ri2de_slope.py $
# $Keywords: $
# http://localhost:5000/wps?request=Execute&service=WPS&identifier=ra2ce_calc_ratio&version=1.0.0&inputs=[uid=testing;json_matri={'values':[[1,1,3,1,1],[1,1,4,1,1],[1,1,5,1,1],[1,1,2,1,1],[1,1,1,1,5]]}]
# PyWPS
from pywps import Process, Format, FORMATS
from pywps.inout.inputs import ComplexInput, LiteralInput
from pywps.inout.outputs import ComplexOutput
from pywps.app.Common import Metadata

# other
import json
import os
import time
import logging
from processes.utils import *
# local


class WpsRa2ceRatio(Process):

	def __init__(self):
		# Input [in json format ]
		inputs = [LiteralInput('uid', 'User Identifier', data_type='string'),
				  ComplexInput('json_matrix', 'matrix with priorities',
		                       [Format('application/json')],
		                       abstract="Complex input abstract", )]

		# Output [in json format]
		outputs = [ComplexOutput('output_json',
		                         'Ra2ce calculation of costs',
		                         supported_formats=[Format('application/json')])]

		super(WpsRa2ceRatio, self).__init__(
		    self._handler,
		    identifier='ra2ce_calc_ratio',
		    version='1.0',
		    title='backend process for the RA2CE POC, calculates the ratio between Annual Repair costs and Societial Costs',
		    abstract='It uses PostgreSQL to calculate the ratio\
		     using 2 columns of a table and answer via a JSON reply, wrapped in the xml/wps format with the wmslayer to show',
		    profile='',
		    metadata=[Metadata('WpsRa2ceRatio'), Metadata('Ra2CE/ratio')],
		    inputs=inputs,
		    outputs=outputs,
		    store_supported=False,
		    status_supported=False
		)

	## MAIN
	def _handler(self, request, response):

		try:
			# Read configuration
			cf = readConfig()

			# Read input
			json_matrix = request.inputs["json_matrix"][0].data
			uid = request.inputs["uid"][0].data.strip()
			calccosts(cf,uid, json_matrix)

			res = dict()
			res['baseUrl'] = "https://ri2de.openearth.eu/geoserver/ows"
			res['layerName'] = "ra2ce:classroads_testing"
			res['style'] = 'ra2ce'
                     
			# Set output
			response.outputs['output_json'].data = json.dumps(res)
		
		except Exception as e:
			res = { 'errMsg' : 'ERROR: {}'.format(e) }
			response.outputs['output_json'].data = json.dumps(res)	

		return response

	def calccosts(cf,uid,json_matrix):
		## calcost function calculates recaclutes the 
		import json 
		from sqlalchemy import create_engine
		engine = create_engine('postgresql+psycopg2://'+cf.get('PostGIS', 'user')
		  	+':'+cf.get('PostGIS', 'pass')+'@'+cf.get('PostGIS', 'host')+':'+str(cf.get('PostGIS', 'port'))
		  	+'/'+cf.get('PostGIS', 'db'), strategy='threadlocal')

      
		#first set everything to 0 and create a new viw
		strSql = """drop table temp.classroads_testing"""
		res = engine.execute(strSql)
		strSql = """create table temp.classroads_testing as select geom, societalclass, repairclass, 0 as visclass from ra2ce.classroads""".format(uid=uid)
		res = engine.execute(strSql)

        #this type of matrix is sent from frontend to backend
		local = False
		if local:
			json_matrix = {'values':[
                [1,1,3,1,1],
                [1,1,4,1,1],
                [1,1,5,1,1],
                [1,1,2,1,1],
                [1,1,1,1,5]]}
        
		xj = json.dumps(json_matrix)
        
		data = json.loads(xj)
		values = data["values"]
        #todo here create new layer (view) and add this to the geoserver
		for societalIndex in range(len(values)):
			for repairIndex in range(len(values[societalIndex])):
			    strSql = """update temp.classroads_{uid} set visclass = {val}
                            where societalclass = {s} and repairclass = {r}""".format(val=values[societalIndex][repairIndex],s=societalIndex+1,r=repairIndex+1,uid=uid)
        
			    res = engine.execute(strSql)
		res.close()

		# create new layer from postgis in geoserver
		uid = 'testing'
		atable = 'classroads_{uid}'.format(uid=uid)  
		wmslay = geoServerUploadVector(cf,atable,'ra2ce','temp','ra2ce_temp','32634','ra2ce')
        
		return wmslay

		# Upload raster file to GeoServer
	def geoServerUploadVector(cf, alayer, sld='ra2ce', schema='temp',datastore='race_temp',s_srs='32634',workspace='TEMP'):
		from geoserver.catalog import Catalog    
		# Connect and get workspace
		#cat = Catalog("http://localhost:8080/geoserver/rest", username = "admin", password = "geoserver")
		cat = Catalog(cf.get('GeoServer', 'rest_url'), username=cf.get('GeoServer', 'user'), password=cf.get('GeoServer', 'pass'))
		ws = cat.get_workspace(workspace)  
		ds = cat.get_store (datastore, ws)
		if ds is None:            
		    ds = cat.create_datastore(datastore,ws)    

 			ds.connection_parameters.update(host=cf.get('PostGIS', 'host'), port=str(cf.get('PostGIS', 'port'), 
                                        database=cf.get('PostGIS', 'db'), user=cf.get('PostGIS', 'user'), 
                                        passwd=cf.get('PostGIS', 'pass'), dbtype='postgis', schema='{s}'.format(s=schema))
 

#		ds.connection_parameters.update(host='localhost', port='5432', 
#                       database='ra2ce', user='postgres', 
 #                      passwd='', dbtype='postgis', schema='{s}'.format(s=schema))
		cat.save(ds)
			
			# Associate SLD styling to it
		ft = cat.publish_featuretype(alayer, ds, str('EPSG:{s}'), srs=str('EPSG:{s}')).format(s=s_srs)
		cat.save(ft)
		layer = cat.get_layer(alayer)
		if sld != False:
		    layer._set_default_style(sld)
		#TODO set proper layer name using ln
		cat.save(layer)
			
		# Return wms url
		wmslay = workspace+':'+alayer    
		return wmslay
