# -*- coding: utf-8 -*-
"""
Created on Tuesday Nov  11 13:25:03 2017
@author: Hessel Winsemius, Joan Sala
"""

# let's load required packages
import pandas as pd
import numpy as np

# Plot packages
from bokeh.plotting import figure, save
from bokeh.io import output_notebook, push_notebook, output_file
from bokeh.models import ColumnDataSource, HoverTool, Div, ColorBar, LinearColorMapper, TapTool, CustomJS
from bokeh.palettes import Reds9

# -------------------------------------------------------------------
# AUXILIARY FUNCTIONS
# -------------------------------------------------------------------
def read_impact_table(fn):
    """
    Read the complete impact table into a dictionary. Each dictionary key represents one province. Each 
    """
    ds = pd.ExcelFile(fn)
    # prepare an empty dictionary
    dfs = {}
    for name in ds.sheet_names:
        dfs[name] = ds.parse(name)
    return dfs

def query_table(dfs, name, query_names, query_mins, query_maxs):
    """
    queries events from a given dataset of impacts. 
    """
    # first query the right dataframe according to name provided
    df = dfs[name]
    df_select = df
    # now query sequentially on all arguments provided
    for query_name, query_min, query_max in zip(query_names, query_mins, query_maxs):
        df_select = df_select[df_select[query_name] >= query_min]
        df_select = df_select[df_select[query_name] < query_max]
        
    return df_select

def find_class(value, classes):
    classes = np.atleast_1d(classes)
    idx_min = np.where(classes <= value)[0]
    idx_max = np.where(classes > value)[0]
#     import pdb
#     pdb.set_trace()
    if len(idx_min) == 0:
        min_val = -np.Inf
    else:
        min_val = classes[idx_min[-1]]
    if len(idx_max) == 0:
        max_val = np.Inf
    else:
        max_val = classes[idx_max[0]]
    return min_val, max_val


# -------------------------------------------------------------------
# REPORTING FUNCTIONS
# -------------------------------------------------------------------           
def report_all(df_select):
    """
    report all values to a defined template
    """
    if len(df_select) == 0:
        report_all = 'No similar events were reported on in online media'
    else:
        report_all = """
        Similar events were reported on in online media. 
        Below we provide a tabulated set of impacts from these media sources. We also
        provide the links to these media sources so that you can read more about these
        past events. You can use these reports to have a better understanding what may
        happen with the forecast event by TMA.
        ==============================================================================

        """
    for _, row in df_select.iterrows():
        report_all += fill_report(row)
    return report_all

def fill_report(info):
    def standardize(val, default='no information'):
        val_str = str(val)
        if val_str == 'nan':
            val_str = default
        return val_str

    template = """
                News report
                -----------
                Event date: {:s}
                The news article reporting on this event can be found on:
                {:s}

                Meteorological conditions
                -------------------------
                Amount of accumulated rainfall in province {:s}: {:s} mm
                Monthly rainfall deviated {:s} standard deviations from normal

                Information about impacts of the event
                --------------------------------------
                Media reported about the following impacts:

                Type of event: {:s}
                Affected locations or regions: {:s}
                Casualties: {:s}
                Evacuations: {:s}
                Amount of damage: {:s}
                Properties damaged or affected: {:s}
                Donations made: {:s}

                """.format
    report = template(standardize(info['time'].strftime('%Y-%m-%d')),
                      'URL PLACEHOLDER',
                      standardize(info['province']),
                      standardize('{:d}'.format(int(round(info['24hr Rainfall'])))),
                      standardize('{:02.1f}'.format(info['SPI'])),
                      standardize(info['identifiers']),
                      standardize(info['location']),
                      standardize(info['casualties']),
                      standardize(info['evacuated']),
                      standardize(info['damage_economy']),
                      standardize(info['damaged_property']),
                      standardize(info['donations']),
                      )
    return report

## below: example of information in one output row                      
#     time                                                2011-12-20 00:00:00
# 24hr Rainfall                                                      97.2
# 3day Rainfall                                                   158.334
# 7day Rainfall                                                   161.101
# 10day Rainfall                                                  169.634
# SPI                                                             1.76457
# Wetness conditions                                                  WET
# casualties                                                     About 40
# casualties_integer                                                   40
# damage_economy                                               $1 billion
# damaged_property      401 homes , infrastructure , Selander Bridge ,...
# donations                                                   Sh7 billion
# end                                                 2011-12-23 00:00:00
# evacuated                                                         4,909
# evacuated_integer                                                 4,909
# event_id                                                             51
# identifiers             flooded , downpours , overflow , floods , rains
# location              Mabwepande , Kinondoni , Tabata , Kisiwani , M...
# province                                                  Dar es Salaam

 