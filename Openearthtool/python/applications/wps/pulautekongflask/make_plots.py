# -*- coding: utf-8 -*-
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares
#       Joan Sala
#       joan.salacalero@deltares.nl
#       Nena Vandebroek
#       nena.vandebroek@deltares.nl
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

# modules
from datetime import datetime
import os
import sys
import traceback
import numpy as np
import requests
import logging
import json

# project specific functions
from pt_utils import *
from pt_fews import *

# Functions [plotting]
from pt_plots_trend import *
from pt_plots_slr import *
from pt_plots_exceedance import *
from pt_plots_tseries import *
from pt_plots_waterbalance import *
from pt_plots_scatter import *

# the main should be handling the input
def make_plots(conf):

    # Parse input
    locationIds, locationNames, parameterIds, startDate, endDate = getLocationsParameters(conf)

    # Generate csv
    genCsv = getGenerateCsv(conf)

    # Get size prefences
    xSize, ySize = getPlotSize(conf)

    # Get plot settings
    title, xAxis, yAxis1, yAxis2 = getPlotSettings(conf)

    # Read configuration
    reports_dir, reports_url, plots_dir, plots_url, piwebservice_url = readConfig()

    # Check that the number of locations and parameters are equal
    if len(locationIds) != len(parameterIds):
        return { 'errmsg': "ERROR: number of locations, parameters, time vectors, and value vectors are not equal." }

    # Initialize data lists
    locations = []
    params = []
    units = []
    times = []
    values = []
    flags = []
    qualifiers = []
    data = {}
    data['html_path'] = []
    data['csv_path'] = []
    graph_bokeh, file_path, csv_path, stats = '','','', {}

    # Get data from PIService (loop through each location/parameter combination)
    # For plots that are not pre-defined, import data
    if conf['plotType'] != 'waterbalance':
        try:
            # CSV is optional
            if genCsv:
                csv_path = getTempFile(plots_dir, typen='export', extension='.csv')
                fcsv = open(csv_path, 'a')
                fcsv.write("location;param;unit;time;value\n")

            # Locations information gathering
            for index, l in enumerate(locationIds):
                logging.info('Now requesting data for ' + l + ' - ' + parameterIds[index])
                json_data = request_FEWS_JSON_timeseries(piwebservice_url, locationIds[index], parameterIds[index], startDate, endDate)                
                location, param, qualifier, unit, time, value, flag = parse_FEWS_JSON_timeseries(json_data)
                locations.append(locationNames[index])
                params.append(param)
                units.append(unit)
                times.append(time)
                values.append(value)
                flags.append(flag)
                qualifiers.append(qualifier)
                # CSV export data [optional]
                if genCsv:
                    for t,v in zip(time, value):          
                        fcsv.write('{};{};{};{};{}\n'.format(location, param, unit, t, v))
        except Exception as e: 
            print(e)
            return { 'errmsg': "ERROR: Requesting data from the FEWS system" }

        try:
            # Call timeseries function
            if 'timeseries' in conf['plotType']:
                print('Plotting timeseries ...')
                stats = getStatistics(times, values)
                print(locations)
                file_path = plotTseries(conf, times, values, flags, params, units, locations, plots_dir)

            # Call scatter function
            elif conf['plotType'] == 'scatter':
                print('Plotting scatter ...')
                file_path = plotScatter(conf, times, values, params, units, locations, plots_dir)

            # call Alfons function [Exceedance analysis]
            elif conf['plotType'] == 'exceedance':
                print('Plotting Exceedance analysis ...')
                file_path = plotExceedance(conf, times, values, params, units, locations, plots_dir)

            # call Alfons function [Sea Level Rise analysis]
            elif conf['plotType'] == 'sealevelrise':
                print('Plotting Sea Level Rise analysis ...')
                file_path = plotSLRAnalysis(conf, times, values, params, units, locations, plots_dir)

                # Trend analysis 4-subtypes
            elif 'trend' in conf['plotType']:
                print('Plotting Trend analysis ...')
                ttype = conf['plotType'].split('-')[-1]
                file_path = plotTrend(conf, ttype, times, values, params, units, locations, plots_dir)

            # Correlation
            elif 'correlation' in conf['plotType']:
                print('Plotting time-series correlation ...')
                file_path = plotScatter(conf, xSize, ySize, times, values, params, units, locations, plots_dir,
                                        correlation=True)

            # Return error if a different type of conf['plotType'] is selected
            else:
                return {'errmsg': "ERROR: Analysis type: " + conf['plotType'] + " is not a valid entry."}

        except Exception as e:
            print(e)
            traceback.print_exc(file=sys.stdout)
            return { 'errmsg': "ERROR: Plotting data" }
    else:
        # TO DO:
        # Import data for the following parameters, within the range of "times" (all for locationId = wb_entirepolder): Q.wb.structure, Q.wb.pump, Q.wb.rainfall_tot, Q.wb.evap, Q.wb.seepage, Q.wb.storage, Q.wb.residual.
        # Give a warning if data is not available for complete specified period (especially since our test period is only 1 week)
        # The data will be flow rates (m3/s) at daily timesteps. We want to calculate the average over the range of "times" and plot these averages in the graph.
        locationId = 'wb_entirepolder'
        parameterIds = [ 'Q.wb.structure', 'Q.wb.pump', 'Q.wb.rainfall_tot', 'Q.wb.evap', 'Q.wb.seepage', 'Q.wb.storage', 'Q.wb.residual' ]
        dataWB = {}
        for p in parameterIds:
            dataWB[p] = 0
            try:
                json_data = request_FEWS_JSON_timeseries(piwebservice_url, locationId, p, startDate, endDate)
                location, param, qualifier, unit, time, value, flag = parse_FEWS_JSON_timeseries(json_data)
                dataWB[p] = np.mean(value)
            except:
                pass

        file_path, csv_path = plotWaterBalance(conf, dataWB, plots_dir)

    # Return data
    data['html_path'].append(plots_url + '/' + os.path.basename(file_path))
    if genCsv:
        data['csv_path'].append(plots_url + '/' + os.path.basename(csv_path))
    data['stats_table'] = stats 
    return data        
