# -*- coding: utf-8 -*-
from os.path import join, dirname, realpath
import json
from ast_python.ast_utils import *
import pandas as pd
import numpy as np
import logging


# Data files
records_file = join(dirname(dirname(realpath(__file__))), 'tables/ast_measures.json')
scores_file = join(dirname(dirname(realpath(__file__))), 'tables/ast_scores.json')


def selection_dict(d):
    return selection(**d).to_dict(orient="records")


def selection_json(jsonstr):
    d = json.loads(jsonstr)
    df = selection(**d)
    return df.to_json(orient="records")


def selection(
    scale,
    soil,
    slope,
    multifunctionality,
    surface,
    subsurface,
    capacity,
    suitability,
):

    # construct DataFrame from list of dicts
    scores = read_json_array(scores_file)
    df = pd.DataFrame(scores)

    # convert checkboxes to index the DataFrame with
    scale_list = _checklist(scale)
    capacity_list = _checklist(capacity)
    suitability_list = _checklist(suitability)

    if scale_list == []:
        max_scale = 0
    else:
        max_scale = df[scale_list].max(axis=1)

    # include all characteristics less than or equal to subsurface
    subsurface_characteristics_range = ["high", "medium", "low", "veryLow"]
    subsurface_characteristics_index = subsurface_characteristics_range.index(
        subsurface
    )
    subsurface_characteristics_list = subsurface_characteristics_range[
        subsurface_characteristics_index:
    ]

    # technical feasability
    df["TechFeasabilty"] = max_scale + df[soil] + df[slope]

    # TODO implement multifuntional landuse scores or multiply with 2
    if suitability_list == []:
        df["suitability1"] = 1
    else:
        df["suitability1"] = (
            df[suitability_list].max(axis=1)
            + float(multifunctionality) * df["enablesMultifunctionalLandUse"] * 2
        )
    # check what to do with roofs versus subsurface, now they can sum to 2, instead of 1
    df["suitability2"] = df[surface] + df[subsurface_characteristics_list].max(axis=1)
    df["suitability"] = df["suitability1"] * df["suitability2"].replace(0, 0.4)
    if capacity_list == []:
        df["capacity_sum"] = 0
    else:
        df["capacity_sum"] = df[capacity_list].sum(axis=1)

    # TODO check whether 0 values should be allowed
    df.loc[np.isclose(df["capacity_sum"], 0), "capacity_factor"] = 1.0
    df.loc[np.isclose(df["capacity_sum"], 1), "capacity_factor"] = 1.25
    df.loc[np.isclose(df["capacity_sum"], 2), "capacity_factor"] = 1.35
    df.loc[np.isclose(df["capacity_sum"], 3), "capacity_factor"] = 1.425
    df.loc[np.isclose(df["capacity_sum"], 4), "capacity_factor"] = 1.5
    df.loc[np.isclose(df["capacity_sum"], 5), "capacity_factor"] = 1.575
    df.loc[np.isclose(df["capacity_sum"], 6), "capacity_factor"] = 1.6
    df.loc[np.isclose(df["capacity_sum"], 7), "capacity_factor"] = 1.675
    df.loc[np.isclose(df["capacity_sum"], 8), "capacity_factor"] = 1.75
    # TODO find out why tech feas score instead of rank?
    df["system_suitability"] = (df["suitability"] + df["TechFeasabilty"]) * df[
        "capacity_factor"
    ]

    df["system_suitability_rank"] = df["system_suitability"].rank(
        axis=0, ascending=False, method="min"
    )
    df_sorted = df.sort_values("system_suitability_rank")

    measures_list = df_sorted[["ast_id", "name", "system_suitability"]]
    return measures_list


def _checklist(checkboxes):
    """Turns a dict of {"a":True, "b": False, "c": True} into ["a", "c"]"""
    return [key for key, checked in checkboxes.items() if checked]
