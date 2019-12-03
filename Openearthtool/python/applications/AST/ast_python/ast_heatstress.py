# -*- coding: utf-8 -*-
from os.path import join, dirname, realpath
import json
from ast_python.ast_utils import *


def temperature_dict(d):
    return temperature(**d)


def temperature_json(jsonstr):
    d = json.loads(jsonstr)
    return temperature(**d)


def temperature(id, projectArea, area, scenarioName):
    # Data file
    records_file_temp = join(dirname(dirname(realpath(__file__))),
                             'tables/'+scenarioName+'/ast_measures_temperature.json')
    record = find_record(id, records_file_temp)
    #temp_reduction_local = float(record["Value_T"])
    #temp_reduction = temp_reduction_local * area / projectArea
    temp_reduction_local = float(record["GreenOrBlue"])
    temp_coolspot_potential = float(record["Coolspot_potential"])

    temp_reduction = temp_reduction_local * area / projectArea * 2.85
    # API needs key/value pairs
    if temp_coolspot_potential > 0.5 and area > 200:
        coolspot = 1
    else:
        coolspot = 0

    # API needs key/value pairs
    ret = {
        "coolSpot": coolspot,
        "tempReduction": temp_reduction
    }
    return ret


def cost_dict(d):
    return cost(**d)


def cost_json(jsonstr):
    d = json.loads(jsonstr)
    return cost(**d)


def cost(id, area, scenarioName):
    # Data file
    records_file_cost = join(dirname(dirname(realpath(__file__))),
                             'tables/'+scenarioName+'/ast_measures_cost.json')
    record = find_record(id, records_file_cost)
    construction_unit_cost = float(record["construction_m2"])
    maintenance_unit_cost = float(record["maint_annual_frac_constr"])
    construction_cost = construction_unit_cost * area
    maintenance_cost = 0.01 * maintenance_unit_cost * construction_cost

    # API needs key/value pairs
    ret = {
        "maintenanceCost": maintenance_cost,
        "constructionCost": construction_cost
    }
    return ret


def waterquality_dict(d):
    return waterquality(**d)


def waterquality_json(jsonstr):
    d = json.loads(jsonstr)
    return waterquality(**d)

# def waterquality(id, area, scenarioName):


def waterquality(id, projectArea, area, scenarioName):
    # Data file
    records_file_wq = join(dirname(dirname(realpath(__file__))),
                           'tables/'+scenarioName+'/ast_measures_wq.json')
    record = find_record(id, records_file_wq)
    capture_unit = float(record["Nutrients"])
    settling_unit = float(record["AdsorbingPollutants"])
    filtering_unit = float(record["Pathogens"])
    capture_unit = capture_unit * area / projectArea * 100.0
    settling_unit = settling_unit * area / projectArea * 100.0
    filtering_unit = filtering_unit * area / projectArea * 100.0

    # API needs key/value pairs
    ret = {
        "filteringUnit": filtering_unit,
        "settlingUnit": settling_unit,
        "captureUnit": capture_unit
    }
    return ret
