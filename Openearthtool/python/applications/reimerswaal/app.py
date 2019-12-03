import os
import json

# FLASK
from flask import Flask
from flask import request, jsonify
from flask_cors import CORS

# Local imports
from calculations import *
from config import *

# Read configuration
conf = CONF(os.path.join(os.path.dirname(os.path.realpath(__file__)), 'config.txt')).readConfig()

# FLASK app
application = Flask(__name__)
CORS(application)

# /
@application.route('/')
def empty_view(self):
    content = {'please move along': 'nothing to see here, perhaps looking for /api?'}
    return content, 200

# /api/selectPoints
@application.route('/api/selectPoints', methods=['POST'])
def selectPoints():
	try:
	    json_data = request.get_json()
	    res = runSelection(json_data, conf) # todo
	    status = 200
	except Exception as e:
		res = { 'error': 'Invalid JSON request', 'code': 400, 'msg': str(e) }
		status = 400		
	return jsonify({'result': res}), status

# /api/calculateScenario
@application.route('/api/calculateScenario', methods=['POST'])
def calculateScenario():
	try:
	    json_data = request.get_json()
	    res = dict()
	    res['wms_url'] = conf['GEOSERVER_WMS'] 
	    res['layername'] = runScenario(json_data, conf)	    
	    status = 200
	except Exception as e:
		res = { 'error': 'Invalid JSON request', 'code': 400, 'msg': str(e) }
		status = 400
	return jsonify({'result': res}), status

# Main
if __name__ == "__main__":
    application.run(host='0.0.0.0', debug=True)
