# Local imports
from make_plots import *
from get_reports import *
from config_plots import *

# FLASK
from flask import Flask
from flask import request, jsonify
from flask_cors import CORS

# FLASK app
application = Flask(__name__)
CORS(application)

# /get_reports
@application.route('/get_reports', methods=['GET', 'POST'])
def flask_get_reports():
    # Inputs / Outputs
    reports = get_reports()
    return jsonify(reports), 200

# /make_plots
@application.route('/make_plots', methods=['GET', 'POST'])
def flask_make_plots():

    # Inputs / Outputs
    result = {}
    try:
        json_data = request.get_json()
    except:
        json_data = {}

    # Config
    if json_data == {}:  return jsonify(config()), 200

   # Make plot
    try:
        # Inputs
        json_data = request.get_json()
        logging.info(json_data)

        # Make plot
        result = make_plots(json_data)
        status = 200
    except Exception as ex:
        template = "An exception of type {0} occurred. Arguments:\n{1!r}"
        message = template.format(type(ex).__name__, ex.args)
        result = { 'error': 'Invalid JSON request', 'code': 400, 'message': message }
        status = 400

    print(result)
    return jsonify(result), status

# Main
if __name__ == "__main__":
	application.run(host='0.0.0.0', debug=True)
