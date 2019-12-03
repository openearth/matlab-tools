# -*- coding: utf-8 -*-
from os.path import join, dirname, realpath
import json
from ast_python.ast_utils import *


def pluvflood_dict(d):
    return pluvflood(**d)


def pluvflood_json(jsonstr):
    d = json.loads(jsonstr)
    return pluvflood(**d)


def pluvflood(id, projectArea, area, depth, inflow, returnTime, scenarioName):
    # Data file
    records_file = join(dirname(dirname(realpath(__file__))), 'tables/' +
                        scenarioName+'/ast_measures_pluvflood.json')
    record = find_record(id, records_file)
    # check for too small inflow areas
    if inflow <= 0.01:
        inflow = 0.01
    storage_capacity = area * depth
    effective_depth = storage_capacity / inflow  # [m]
    effective_depth_mm = effective_depth * 1000.0
    effective_depth_list = [
        0.0,
        5.0,
        10.0,
        20.0,
        30.0,
        40.0,
        50.0,
        100.0,
        1.00E+12,
    ]

    for i in range(len(effective_depth_list)):
        if effective_depth_list[i] <= effective_depth_mm:
            index_a = i
            index_b = i + 1
            effective_depth_a = effective_depth_list[index_a]
            effective_depth_b = effective_depth_list[index_b]
        else:
            break

    recurrence_a = float(record[f"Col{index_a}"])
    recurrence_b = float(record[f"Col{index_b}"])

    multiplication_factor = recurrence_a + (recurrence_b - recurrence_a) * (
        effective_depth_mm - effective_depth_a
    ) / (effective_depth_b - effective_depth_a)
    return_time_inflow = returnTime * multiplication_factor
    return_time_projectArea = (return_time_inflow * inflow / (projectArea) +
                               returnTime * (projectArea - inflow) / projectArea) - returnTime

    # API needs key/value pairs
    ret = {
        "returnTime": return_time_projectArea
    }
    return ret
