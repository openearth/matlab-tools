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

# core 
import requests
from datetime import datetime

# This function sends a request to the FEWS PI Service for a single timeseries (single location, single param)
def request_FEWS_JSON_timeseries(url, locationId, parameterId, startDate, endDate):
    params = dict(
        locationIds=locationId, 
        parameterIds=parameterId, 
        startTime=startDate,
        endTime=endDate,
        omitMissing='true',
        documentFormat='PI_JSON'
    )
    resp = requests.get(url=url,params=params)
    data = resp.json()

    return data

# This function parses JSON containing a definition of the timeseries to be requested
def getLocationsParameters(data):          
    startDate = data["startDate"]
    endDate = data["endDate"]
    locations = []
    locationNames = []
    params = []
    
    for index, i in enumerate(data["selectedParams"]):
        locations.append(data["selectedParams"][index]["locationId"])
        try:
            locationNames.append(data["selectedParams"][index]["locationName"])
        except:
            locationNames.append(data["selectedParams"][index]["locationId"]) # optional
        params.append(data["selectedParams"][index]["parameterId"])
        
    return locations, locationNames, params, startDate, endDate

# This function parses a SINGLE FEWS JSON timeseries (single location, single param)
def parse_FEWS_JSON_timeseries(data, index=0):

    # Mandatory [loc/param/units]
    location = data["timeSeries"][index]["header"]["locationId"]
    param = data["timeSeries"][index]["header"]["parameterId"]
    units = data["timeSeries"][index]["header"]["units"]

    # Optional (qualifier)
    try:
        qualifier = str(data["timeSeries"][index]["header"]["qualifierId"][index])
        param += ' ({})'.format(qualifier)
    except:
        qualifier = ""

    times = []
    values = []
    flags = []

    # Loop through each date "event" and store the time and value
    for index, i in enumerate(data["timeSeries"][index]["events"]):
        times.append(datetime.strptime(i["date"]+i["time"],"%Y-%m-%d%H:%M:%S")) 
        values.append(float(i["value"]))
        flags.append(float(i["flag"]))
        
    return location, param, qualifier, units, times, values, flags


