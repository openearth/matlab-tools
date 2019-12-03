# THIS FILE IS SAFE TO EDIT. It will not be overwritten when rerunning go-raml.

from flask import jsonify, request
from utils_DB import executesqlfetch

def eco_parameters_getHandler():
	
	# Default result is empty
	res = {}

	# Insert specific query here
	strSql = 'select * from digitaledelta.ddl_wozbiotaxon_parameters'
	rsql = executesqlfetch(strSql)	

	# Send back result as JSON
	res['result'] = rsql
	return jsonify(res)
