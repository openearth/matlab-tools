# -*- coding: utf-8 -*-
from os.path import join, dirname, realpath
import json
from ast_python.ast_utils import *


def groundwater_recharge_dict(d):
    return groundwater_recharge(**d)


def groundwater_recharge_json(jsonstr):
    d = json.loads(jsonstr)
    return groundwater_recharge(**d)


def groundwater_recharge(id, projectArea, area, depth, inflow, returnTime, scenarioName):
        # Data file
    records_file = join(dirname(dirname(realpath(__file__))), 'tables/' +
                        scenarioName+'/ast_measures_groundwater_recharge.json')
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

    groundwater_recharge_a = float(record[f"Col{index_a}"])
    groundwater_recharge_b = float(record[f"Col{index_b}"])

    groundwater_recharge_measure = groundwater_recharge_a + (groundwater_recharge_b - groundwater_recharge_a) * (
        effective_depth_mm - effective_depth_a
    ) / (effective_depth_b - effective_depth_a)

    groundwater_recharge_projectArea = groundwater_recharge_measure * inflow / projectArea

    # API needs key/value pairs
    ret = {
        "groundwater_recharge": groundwater_recharge_projectArea
    }
    return ret
