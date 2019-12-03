# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
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
import numpy as np
import requests

# project specific functions
# from processes.pt_utils import GetTempFile
from pt_utils import GetTempFile

# Plots
from bokeh.plotting import figure, save
from bokeh.io import output_file
from bokeh.models import DatetimeTickFormatter, LinearAxis, DataRange1d, ColumnDataSource
from bokeh.palettes import Category10, Spectral6
from bokeh.embed import components
from bokeh.transform import factor_cmap

# the main should be handling the input
def make_plots(tempdir,url,locationIds,parameterIds,startDate,endDate,analysis):
    
    # Check that the number of locations and parameters are equal
    if len(locationIds)==len(parameterIds):
        
        # Initialize data lists
        locations = []
        params = []
        units = []
        times = []
        values = []
        
        # For plots that are not pre-defined, import data
        if analysis == 'timeseries' or analysis == 'scatter':
            # Get data from PIService (loop through each location/parameter combination)
            for index, l in enumerate(locationIds):
                print('Now requesting data for ' + l + ' - ' + parameterIds[index])
                json_data = request_FEWS_JSON_timeseries(url,locationIds[index],parameterIds[index],startDate,endDate)
                location,param,unit,time,value = parse_FEWS_JSON_timeseries(json_data)
                locations.append(location)
                params.append(param)
                units.append(unit)
                times.append(time)
                values.append(value)
        
        data = {}
        data['script'] = []
        data['div'] = []
        data['html_path'] = []
        
        # Plot data
        if analysis == 'timeseries':
            graph_bokeh, html_path = plot_timeseries(times,values,params,units,locations,tempdir)
            script, div = components(graph_bokeh)
            data['script'].append(script)
            data['div'].append(div)
            data['html_path'].append(html_path)
            return data
        
        elif analysis == 'scatter':
            graph_bokeh, html_path = plot_scatter(times,values,params,units,locations,tempdir)
            script, div = components(graph_bokeh)
            data['script'].append(script)
            data['div'].append(div)
            data['html_path'].append(html_path)
            return data
        
        # call function to make water balance plot (for this option, locationIds and paramterIds can be empty)
        elif analysis == 'waterbalance':
            graph_bokeh, html_path = plot_waterbalance(tempdir,startDate,endDate)
            script, div = components(graph_bokeh)
            data['script'].append(script)
            data['div'].append(div)
            data['html_path'].append(html_path)
            return data
        
        # Return error if a different type of analysis is selected
        else:
            raise Exception("ERROR: Analysis type " + analysis + " is not a valid entry.")
            return
    else:
        raise Exception("ERROR: number of locations, parameters, time vectors, and value vectors are not equal.")
        return

# This function sends a request to the FEWS PI Service for a single timeseries (single location, single param)
def request_FEWS_JSON_timeseries(url,locationId,parameterId,startDate,endDate):
    params = dict(
            locationIds=locationId, 
            parameterIds=parameterId, 
            startTime=startDate.strftime("%Y-%m-%dT%H:%M:%SZ"),
            endTime=endDate.strftime("%Y-%m-%dT%H:%M:%SZ"),
            omitMissing='true',
            documentFormat='PI_JSON'
            )
    resp = requests.get(url=url,params=params)
    data = resp.json()
    return data

# This function parses JSON containing a definition of the timeseries to be requested
def parse_JSON_input(input_json):
#    with open(input_json) as f:
#        data = json.load(f)
    data = input_json
    analysis = data["analysis"]
    startDate = datetime.strptime(data["startDate"],"%Y-%m-%d")
    endDate = datetime.strptime(data["endDate"],"%Y-%m-%d")
  
    locations = []
    params = []
    
    for index, i in enumerate(data["selectedParams"]):
        locations.append(data["selectedParams"][index]["locationId"])
        params.append(data["selectedParams"][index]["parameterId"])
        
    return locations,params,startDate,endDate,analysis

# This function parses a SINGLE FEWS JSON timeseries (single location, single param)
def parse_FEWS_JSON_timeseries(data):
    location = data["timeSeries"][0]["header"]["locationId"]
    param = data["timeSeries"][0]["header"]["parameterId"]
    units = data["timeSeries"][0]["header"]["units"]
    times = []
    values = []
    
    # Loop through each date "event" and store the time and value
    for index, i in enumerate(data["timeSeries"][0]["events"]):
        times.append(datetime.strptime(i["date"]+i["time"],"%Y-%m-%d%H:%M:%S")) 
        values.append(float(i["value"]))
        
    return location,param,units,times,values

# Make timeseries plot: Can have up to 2 parameters/units (automatically get put on different axes), up to 10 locations
def plot_timeseries(times,values,params,units,locations,tempdir):
    # Check that there are exactly two params and unit combinations
    params_units = [m+ " (" + n + ")" for m,n in zip(params,units)] # combine params and units
    
    if len(set(params_units))>2 or len(locations)>10:
        raise Exception("ERROR: " + str(len(set(params_units))) + " param/unit combos and " + str(len(set(locations))) + " locations were provided. Must have 2 or fewer unique parameter/unit combos and 10 or fewer locations for a timeseries plot.")
        return
    else:
        # Initialize figure
        TOOLS = "pan,wheel_zoom,box_zoom,reset,save"
        
        if len(set(params)) == 1:
            tit = 'Time series of ' + params[0]
        else:
            tit = 'Time series of ' + params[0] + ' and ' + params[1]
        
        p = figure(width=800, height=400, x_axis_type="datetime", title=tit, tools=TOOLS,toolbar_location = "above")
        p.xaxis.axis_label = 'Time'
        p.yaxis.axis_label = params_units[0]
        p.xaxis.formatter = DatetimeTickFormatter(days=['%d/%m'])
        colors = Category10[10]
        
        # If more than one parameter (or set of units) is specified, make a new axis
        if len(set(params_units)) == 2:
            param_unit2 = next(iter(set(params_units) - set([params_units[0]])))
            
            # Figure out what the right axis limits should be (this doesn't happen automatically for some reason)
            low = 1000000000 # dummy starting limits
            high = -1000000000
            for index, i in enumerate(params_units):
                if i == param_unit2:
                    low = min(low,min(values[index]))
                    high = max(high,max(values[index]))
            
            yrange = high-low # Used to add some padding to the right axis y-range
            
            # Set up right axis
            p.extra_y_ranges = {"foo": DataRange1d(start=low-yrange*0.1, end=high+yrange*0.1)}
            p.add_layout(LinearAxis(y_range_name="foo", axis_label=param_unit2), 'right')
            
        # Loop through data
        for index, l in enumerate(locations):
            # Get data
            x=[]
            #for t in times[index]: x.append(datetime.strptime(t.split(' ')[0], '%Y-%m-%d'))           
            for t in times[index]: x.append(t) 
            y=[]
            for v in values[index]: y.append(float(v))
            param = params[index]
            
            # Plot the data
            if len(set(params)) == 1: # If there is only one type of param in the set, only one y-axis and legend shows location names only. 
                p.line(x, y, legend=locations[index], color=colors[index])
                p.circle(x=x, y=y, size=5, color=colors[index])
            elif param == params[0]: # If there are two params in the set, and you're plotting the first param, put it on the left axis and legend shows location name + param.
                p.line(x, y, legend=locations[index]+ " (" + param + ")", color=colors[index])
                p.circle(x=x, y=y, size=5, color=colors[index])
            else: # If there are two params in the set, and you're plotting the second param, put it on the right axis and legend shows location name + param.
                p.line(x, y, legend=locations[index]+ " (" + param + ")", color=colors[index], y_range_name="foo")
                p.circle(x=x, y=y, size=5, color=colors[index], y_range_name="foo")
                
        # Output HTML
        output_html = GetTempFile(tempdir)
        output_file(output_html, title="generated with make_plots.py") # TODO change title to something useful
        save(p)
        return p, output_html

# Make scatterplot: this function can read exactly two datasets, which can have 1 or two locations and one or two parameters
# Currently all inputs are lists
def plot_scatter(times,values,params,units,locations,tempdir):
    # xaxis is always first parameter in list
    
    # Check that there are exactly two param-location combinations
    params_units_locations = [m+ " (" + n + ") - " + o for m,n,o in zip(params,units,locations)] # combine params and units

    if len(locations)>2 or len(params)>2:
        raise Exception("ERROR: " + str(len(set(params_units_locations))) + " location/parameter combinations were provided. Must provide 2 locations/parameters combos for a scatterplot. Note: the two parameters and/or locations can be the same, but there must be two datasets.")
        return
    else:
        # Define figure title (format depends on # unique locations/parameters)
        if len(set(locations)) == 2 and len(set(params)) == 2:
            tit = "Scatterplot of " + params [0] + " at " + locations[0] + " vs. " + params[1] + " at " + locations[1]
        elif len(set(locations)) == 1 and len(set(params)) == 2:
            tit = "Scatterplot of " + params [0] + " vs. " + params[1] + " at " + locations[0]
        elif len(set(locations)) == 2 and len(set(params)) == 1:
            tit = "Scatterplot of " + params [0] + " at " + locations[0] + " vs. " + locations[1]
        else: # This option dosn't really make sense - it means you're plotting the same parameter at the same location... 
            tit = "Scatterplot of " + params [0] + " at " + locations[0]
            
        # Initialize figure
        TOOLS = "pan,wheel_zoom,box_zoom,reset,save"
        p = figure(width=800, height=400, tools=TOOLS, title=tit)
        p.xaxis.axis_label = locations[0] + " - " + params[0] + " (" + units[0] + ")"
        p.yaxis.axis_label = locations[1] + " - " + params[1] + " (" + units[1] + ")"

        # Get data
        tx = []
        #for t in times[0]: tx.append(datetime.strptime(t.split(' ')[0], '%Y-%m-%d'))
        for t in times[0]: tx.append(t)           

        x=[]
        for v in values[0]: x.append(float(v))

        ty = []
        #for t in times[1]: ty.append(datetime.strptime(t.split(' ')[0], '%Y-%m-%d')) 
        for t in times[1]: ty.append(t)           

        y=[]
        for v in values[1]: y.append(float(v))
        
        # Get rid of missing data (nan)
        x2 = np.asarray(x)
        inds_good = ~np.isnan(x2)
        x = x2[inds_good]
        tx2 = np.asarray(tx)
        tx = tx2[inds_good]
        
        y2 = np.asarray(y)
        inds_good = ~np.isnan(y2)
        y = y2[inds_good]
        ty2 = np.asarray(ty)
        ty = ty2[inds_good]
        
        # Find overlapping points in time
        inds_x,inds_y = intersection_indices(tx,ty)
        x = x[inds_x]
        tx = tx[inds_x]
        y = y[inds_y]
        ty = ty[inds_y]
        
        # Find line of best fit
        par = np.polyfit(x, y, 1, full=True)
        slope=par[0][0]
        intercept=par[0][1]
        xl = [min(x), max(x)]
        yl = [slope*xx + intercept  for xx in xl]
        
        # Get R-squared
        variance = np.var(y)
        residuals = np.var([(slope*xx + intercept - yy)  for xx,yy in zip(x,y)])
        Rsqr = np.round(1-residuals/variance, decimals=2)
        leg_text = 'Rsqr = {}'.format(Rsqr)
        
        # Plot the data
        p.circle(x=x, y=y, size=10, color='blue',fill_alpha=0.2)
        
        # Plot the line of best fit and error bounds
        p.line(xl, yl, color='darkblue', line_width=3,legend=leg_text)

        # Output HTML
        output_html = GetTempFile(tempdir)
        output_file(output_html, title="generated with make_plots.py")
        save(p)
        return p, output_html

# Plot waterbalance: this function plots the pre-defined water balance and requires no inputs 
def plot_waterbalance(tempdir, startDate, endDate):
    # TO DO: Import data for all required timeseries
    # TO DO: Check period of time overwhich you have all required timeseries? Or make a good warning to say when one of the timeseries was incomplete. 
    
    # CALCULATE COMPONENTS OF WATER BALANCE --- TO DO: add actual equations
    # Inflow from inlets
    inflow = 7.6
    
    # Rainfall
    rainfall = 4.3
    
    # Evaporation
    evap = -8.1
    
    # Seepage
    seepage = -6.3
    
    # Storage
    storage = 3
    
    # Sum (should be 0)
    total = inflow + rainfall + evap + seepage + storage
    
    # MAKE PLOT
    wb_components = ['Inflows', 'Rainfall', 'Evaporation', 'Seepage', 'Storage', 'Remainder']
    wb_values = [inflow, rainfall, evap, seepage, storage, total]
    #wb_colors = ['#c60000' if i < 0 else '#008000' for i in wb_values] # Make it red if negative, blue if positive
    tit = "Water balance for the period: " + startDate.strftime('%d %b %Y') + " to " + endDate.strftime('%d %b %Y') 
    TOOLS = "pan,wheel_zoom,box_zoom,reset,save"
    
    source = ColumnDataSource(data = dict(wb_components = wb_components, wb_values = wb_values))
    p = figure(x_range=wb_components,width=800, height=400, tools=TOOLS, title=tit)
    p.vbar(x='wb_components', top='wb_values', width=0.9, source=source, line_color='white', fill_color=factor_cmap('wb_components', palette=Spectral6, factors=wb_components))
    #p.vbar(x='wb_components', top='wb_values', width=0.9, source=source, line_color='white', fill_color='wb_colors')
    
    p.xaxis.axis_label = "Component of water balance"
    p.yaxis.axis_label = "Volume (m3)"
    p.xaxis.axis_line_color = "black"
    
    # Output HTML
    output_html = GetTempFile(tempdir)
    output_file(output_html, title="generated with make_plots.py")
    save(p)
    return p, output_html
    
# The following function returns the indices from doing an intersection analysis. This is used in the scatterplot function to find matching timesteps in two datasets to compare in the plot. 
def intersection_indices(a, b):
    a1=np.argsort(a)
    b1=np.argsort(b)
    
    # use searchsorted:
    sort_left_a=a[a1].searchsorted(b[b1], side='left')
    sort_right_a=a[a1].searchsorted(b[b1], side='right')
    sort_left_b=b[b1].searchsorted(a[a1], side='left')
    sort_right_b=b[b1].searchsorted(a[a1], side='right')
    
    # which values of b are also in a?
    inds_b=(sort_right_a-sort_left_a > 0).nonzero()[0]
    # which values of a are also in b?
    inds_a=(sort_right_b-sort_left_b > 0).nonzero()[0]

    # return the indices of a and b which return the matching values of a and b
    return a1[inds_a], b1[inds_b]