# -*- coding: utf-8 -*-
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares
#       Joan Sala
#       joan.salacalero@deltares.nl
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

import collections

# Return the plots list configuration to the Frontend
def config():
    configPlots = collections.OrderedDict({
        "plots": [  
            {
                "name": "Timeseries - Single axis",
                "category": "Timeseries analysis",
                "tooltip": "Correlate two time series to observe likelihood",
                "plotType": "single-timeseries",
                "rangeLoc": {"min": 1, "max": 10},
                "rangePar": {"min": 1, "max": 1}
            },
            {
                "name": "Timeseries - Double axis",
                "category": "Timeseries analysis",
                "tooltip": "Analyze trend, try to fit a linear equation",
                "plotType": "multi-timeseries",
                "rangeLoc": {"min": 1, "max": 10},
                "rangePar": {"min": 1, "max": 2}
            },
            {
                "name": "Scatter plot",
                "category": "Correlation analysis",
                "tooltip": "Correlate two time series to observe likelihood",
                "plotType": "scatter",
                "rangeLoc": {"min": 1, "max": 2},
                "rangePar": {"min": 1, "max": 2}
            },
            {
                "name": "Linear",
                "category": "Trend analysis",
                "tooltip": "Analyze trend, try to fit a linear equation",
                "plotType": "trend-linear",
                "rangeLoc": {"min": 1, "max": 1},
                "rangePar": {"min": 1, "max": 1}
            },
            {
                "name": "Polynomial 2D",
                "category": "Trend analysis",
                "tooltip": "Analyze trend, try to fit a linear equation",
                "plotType": "trend-poly2",
                "rangeLoc": {"min": 1, "max": 1},
                "rangePar": {"min": 1, "max": 1}
            },
            {
                "name": "Polynomial 3D",
                "category": "Trend analysis",
                "tooltip": "Analyze trend, try to fit a linear equation",
                "plotType": "trend-poly3",
                "rangeLoc": {"min": 1, "max": 1},
                "rangePar": {"min": 1, "max": 1}
            },
            {
                "name": "Exponential",
                "category": "Trend analysis",
                "tooltip": "Analyze trend, try to fit an exponential equation",
                "plotType": "trend-exp",
                "rangeLoc": {"min": 1, "max": 1},
                "rangePar": {"min": 1, "max": 1}
            },
            {
                "name": "Logarithmic",
                "category": "Trend analysis",
                "tooltip": "Analyze trend, try to fit a logarithmic equation",
                "plotType": "trend-log",
                "rangeLoc": {"min": 1, "max": 1},
                "rangePar": {"min": 1, "max": 1}
            },
            {
                "name": "Sinus",
                "category": "Trend analysis",
                "tooltip": "Analyze trend, try to fit a sinus equation",
                "plotType": "trend-sin",
                "rangeLoc": {"min": 1, "max": 1},
                "rangePar": {"min": 1, "max": 1}
            },
            {
                "name": "Moving Average",
                "category": "Trend analysis",
                "tooltip": "Analyze trend, perform a moving average choosing a window of measurements",
                "plotType": "trend-movavg",
                "extraParams": {
                    "averageWindow": 10
                },
                "rangeLoc": {"min": 1, "max": 1},
                "rangePar": {"min": 1, "max": 1}
            },   
            {
                "name": "Water balance analysis",
                "category": "Water balance",
                "tooltip": "Water balance analysis for the whole polder structure given a time range",
                "plotType": "waterbalance",
                "rangeLoc": {"min": 0, "max": 0},
                "rangePar": {"min": 0, "max": 0}
            },
            {
                "name": "Sea level rise analysis",
                "category": "Sea level rise",
                "tooltip": "Specific analyis for waterlevel locations",
                "plotType": "sealevelrise",
                "extraParams": {
                    "averagingPeriod": ["D", "M", "Y"]
                },
                "rangeLoc": {"min": 1, "max": 1},
                "rangePar": {"min": 1, "max": 1}
            },  
            {
                "name": "Surge analysis",
                "category": "Surge",
                "tooltip": "Exceedance analysis plot for --- locations",
                "plotType": "exceedance",
                "extraParams": {
                    "potThreshold": 2.7,
                    "popInterval": 30
                },
                "rangeLoc": {"min": 1, "max": 1},
                "rangePar": {"min": 1, "max": 1}
            }
        ]
    })

    return configPlots