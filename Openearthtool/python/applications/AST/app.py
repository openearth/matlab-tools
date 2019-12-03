import os

# AST 2.0
from ast_python.ast_selection import selection_dict
from ast_python.ast_heatstress import temperature_dict, waterquality_dict, cost_dict
from ast_python.ast_pluvflood import pluvflood_dict
from ast_python.ast_groundwater_recharge import groundwater_recharge_dict
from ast_python.ast_evapotranspiration import evapotranspiration_dict
from ast_python.web_map import layerurl, wfs_area_parser
from errors import error_handler

# FLASK
from apispec import APISpec
from apispec.ext.marshmallow import MarshmallowPlugin
from flask_apispec.extension import FlaskApiSpec
from flask_apispec import use_kwargs
from webargs import fields
from flask import Flask, redirect, url_for
from flask_cors import CORS
import json


# FLASK app
application = Flask(__name__)
application.config.update({
    'APISPEC_SPEC': APISpec(
        title='AST2.0 Backend',
        version='v1',
        openapi_version="2.0.0",
        plugins=[MarshmallowPlugin()],
    ),
    'APISPEC_SWAGGER_URL': '/api/swagger/',
    'APISPEC_SWAGGER_UI_URL': '/api/swagger-ui/',
})
docs = FlaskApiSpec(application)
CORS(application)

application.register_blueprint(error_handler)

# /
@application.route('/')
def empty_view():
    0/0
    return redirect(url_for("flask-apispec.swagger-ui"))


# /api/selection
@application.route('/api/selection', methods=['GET', 'POST'])
@use_kwargs({"capacity": fields.Dict(required=True),
             "multifunctionality": fields.Float(required=True),
             "scale": fields.Dict(required=True),
             "slope": fields.Str(required=True),
             "soil": fields.Str(required=True),
             "subsurface": fields.Str(required=True),
             "suitability": fields.Dict(required=True),
             "surface": fields.Str(required=True)})
def ast_calc_selection(**kwargs):
    res = selection_dict(kwargs)
    return {'result': res}


# /api/pluvflood
@application.route('/api/pluvflood', methods=['GET', 'POST'])
@use_kwargs({"scenarioName": fields.Str(required=True),
             "projectArea": fields.Float(required=True),
             "inflow": fields.Float(required=True),
             "returnTime": fields.Float(required=True),
             "area": fields.Float(required=True),
             "depth": fields.Float(required=True),
             "id": fields.Int(required=True)})
def ast_calc_pluvflood(**kwargs):
    res = pluvflood_dict(kwargs)
    return {'result': res}


# /api/evapotranspiration
@application.route('/api/evapotranspiration', methods=['GET', 'POST'])
@use_kwargs({"scenarioName": fields.Str(required=True),
             "projectArea": fields.Float(required=True),
             "inflow": fields.Float(required=True),
             "returnTime": fields.Float(required=True),
             "area": fields.Float(required=True),
             "depth": fields.Float(required=True),
             "id": fields.Int(required=True)})
def ast_calc_evapotranspiration(**kwargs):
    res = evapotranspiration_dict(kwargs)
    return {'result': res}


# /api/groundwater_recharge
@application.route('/api/groundwater_recharge', methods=['GET', 'POST'])
@use_kwargs({"scenarioName": fields.Str(required=True),
             "projectArea": fields.Float(required=True),
             "inflow": fields.Float(required=True),
             "returnTime": fields.Float(required=True),
             "area": fields.Float(required=True),
             "depth": fields.Float(required=True),
             "id": fields.Int(required=True)})
def ast_calc_groundwater_recharge(**kwargs):
    res = groundwater_recharge_dict(kwargs)
    return {'result': res}


# /api/heatstress/temperature
@application.route('/api/heatstress/temperature', methods=['GET', 'POST'])
@use_kwargs({"scenarioName": fields.Str(required=True),
             "projectArea": fields.Float(required=True),
             "area": fields.Float(required=True),
             "id": fields.Int(required=True)})
def ast_calc_heatstress_temperature(**kwargs):
    res = temperature_dict(kwargs)
    return {'result': res}


# /api/heatstress/waterquality
@application.route('/api/heatstress/waterquality', methods=['GET', 'POST'])
@use_kwargs({"scenarioName": fields.Str(required=True),
             "projectArea": fields.Float(required=True),
             "area": fields.Float(required=True),
             "id": fields.Int(required=True)})
def ast_calc_heatstress_waterquality(**kwargs):
    res = waterquality_dict(kwargs)
    return {'result': res}


# /api/heatstress/cost
@application.route('/api/heatstress/cost', methods=['GET', 'POST'])
@use_kwargs({"scenarioName": fields.Str(required=True),
             "area": fields.Float(required=True),
             "id": fields.Int(required=True)})
def ast_calc_heatstress_cost(**kwargs):
    res = cost_dict(kwargs)
    return {'result': res}


# /api/scores
@application.route('/api/scores', methods=['GET'])
def ast_calc_scores():
    res = {}
    ast_dir = os.path.dirname(os.path.realpath(__file__))
    with open(os.path.join(ast_dir, 'tables/ast_scores.json')) as f:
        res['scores'] = json.load(f)
    with open(os.path.join(ast_dir, 'tables/ast_selection_scores.json')) as f:
        res['selection_scores'] = json.load(f)

    return {'result': res}


@application.route("/api/maplayers", methods=['GET', 'POST'])
@use_kwargs({"url": fields.Str(required=True),
             "type": fields.Str()})
def maplayers(url, **kwargs):
    """Parse given url as a possible map layer
    and returns Mapbox compatible url."""
    type = kwargs.get("type", "GUESS")
    return layerurl(url, type)


@application.route("/api/mapsetup", methods=['GET', 'POST'])
@use_kwargs({"url": fields.Str(required=True),
             "layer": fields.Str(required=True),
             "area": fields.Dict(required=True),
             "field": fields.Str(required=True),
             "srs": fields.Int(default=28992)})
def mapsetup(url, layer, area, field, **kwargs):
    """Parse WFS layer for given bounding box."""
    return wfs_area_parser(url, layer, area, field)


# Register documentation endpoints
docs.register(ast_calc_selection)
docs.register(ast_calc_pluvflood)
docs.register(ast_calc_evapotranspiration)
docs.register(ast_calc_groundwater_recharge)
docs.register(ast_calc_heatstress_temperature)
docs.register(ast_calc_heatstress_waterquality)
docs.register(ast_calc_heatstress_cost)
docs.register(maplayers)
docs.register(ast_calc_scores)


# Main
if __name__ == "__main__":
    application.run(host='0.0.0.0', debug=True)
