# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
#       Gerrit Hendriksen
#       gerrit.hendriksen@deltares.nl
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

def read_config():
    """
    Read the configuration file which should be named hymos.config
    file should be structured in the following manner:
    key1 = value1
    key2 = value2

    Returns
    -------
    arg_dict : dictionary, containing keys and values of config file
    """
    import os
    import logging

    arg_dict = {}
    lines_split = []

    work_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)))
    config_file = "hymos.config"  # this is the standard name
    path_config_file = os.path.join(work_dir, config_file)
    if os.path.isfile(path_config_file):
        with open(path_config_file) as fc:
            lines = fc.readlines()
        for line in lines:
            if line.startswith("#") or len(line) == 0:
                pass
            else:
                line_nocomment = line.strip().split("#")[0]
                lines_split.append(line_nocomment.strip().split("="))
        for line in lines_split:
            key = line[0].strip()
            value = line[1].strip()
            arg_dict[key] = value

        return arg_dict

    else:
        logging.info("No configuration file found in working directory")
        return arg_dict


def generate_output(static_folder, js_folder, mode, plot_name, grd):
    """
    Creates a timeseries plot based on a selected parameter and location(s).
    NOTE: due to certificate issues the stylesheet and bokeh-js files are not
    referred to by URL, but are stored in a local folder and loaded from there.

    Parameters
    ----------

    static_folder : string, Path to the static folder on server
    mode : string, determines output of script (static, wps)
    plot_name : string, name of the plot function
    grd : layout of the bokeh plots

    Returns
    -------
    f : StringIO object containing json with path to html of bokeh plot
    """
    import os
    import logging
    import datetime

    import bokeh
    import StringIO
    import json

    f = False
    if mode == "static":
        H = datetime.datetime.now()
        uid = H.strftime("%Y%m%d%H%M%S%f")
        file_name = r"static/%s%s.html" % (plot_name, uid)
        work_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)))
        abs_static_folder = os.path.abspath(os.path.join(work_dir,
                                                         static_folder))
        logging.info(js_folder)

        fpana_css = os.path.join(js_folder, "bokeh_0.12.0.min.css")
        fpana_js = os.path.join(js_folder, "bokeh_0.12.0.min.js")
        css_link = ('<link rel="stylesheet" href="%s" type="text/css" />' %
                    fpana_css)
        js_script = ('<script type="text/javascript" src="%s"></script>' %
                     fpana_js)
        fpana = os.path.join(abs_static_folder, file_name)

        bokeh.plotting.output_file(fpana, title="bokeh plot")
        bokeh.plotting.save(grd)

        with open(fpana, "r") as fh:
            html = fh.read()
            html_split = html.split("\n")
        new_html_split = []
        for item in html_split:
            if "<script" in item and 'src="https' in item:
                new_item = js_script
                new_html_split.append(new_item)

            elif "<link" in item and 'href="https' in item:
                new_item = css_link
                new_html_split.append(new_item)

            elif "<meta" in item:
                meta_block = item
                args = ' http-equiv="X-UA-Compatible" content="IE=edge"'
                new_item = meta_block[:-1] + args + meta_block[-1]
                new_html_split.append(new_item)
            else:
                new_html_split.append(item)
        new_html = "\n".join(new_html_split)

        with open(fpana, "w") as fp:
            fp.write(new_html)

        filepath_dict = {"path": file_name}
        f = StringIO.StringIO()
        json.dump(filepath_dict, f)

    # wps
    if mode == "wps":
        H = datetime.datetime.now()
        uid = H.strftime("%Y%m%d%H%M%S%f")
        script, div = bokeh.embed.components(grd)
        file_name = r"static/%s_div_script%s.html" % (plot_name, uid)
        fpana = os.path.join(static_folder, file_name)
        with open(fpana, "w") as f:
            f.write("{\ndiv: '")
            for line in div.split("\n")[1:]:
                f.write(line)
            f.write("',\nscript: '")
            for line in script.split("\n")[1:]:
                f.write(line)
            f.write("',\nplotDiv: '#plot-wps-div',\n")
            f.write("plotScript: '#plot-wps-script'\n}")

        filepath_dict = {"path": file_name}
        f = StringIO.StringIO()
        json.dump(filepath_dict, f)

        fname_div = '%s_div%s.html' % (plot_name, uid)
        with open(os.path.join(static_folder, fname_div), 'w') as fh:
            fh.write(div)

        fname_script = '%s_script%s.html' % (plot_name, uid)
        with open(os.path.join(static_folder, fname_script), 'w') as fh:
            fh.write(script)

    return f


def check_availability(df, locations, locations_x=None, locations_y=None):
    """
    Checks the availability of data for the given timeseries in the DataFrame,
    in case of multiple location-lists these will be checked and also returned.
    Returns lists with locations with and without any data available.

    Parameters
    ----------

    df: pandas.DataFrame, rows are times, columns are locations
    locations : selected locations
    locations_x : selected locations for x axis (double mass curve)
    locations_y : selected locations for y axis (double mass curve)

    Returns
    -------
    locations : list, locations with data in original locations
    locations_x : list, locations with data in original locations_x
    locations_y : list, locations with data in original locations_y
    empty_timeseries : list, containing names of locations with no data
    """

    extra_output = False
    if locations_x and locations_y:
        extra_output = True
    df_grouped = df.groupby(df.location_id)
    available_locations = [key for key, grp in df_grouped]
    empty_timeseries = [location for location in locations
                        if location not in available_locations]

    locations = list(locations)
    for location in empty_timeseries:
        locations.remove(location)
        if locations_x and location in locations_x:
            locations_x.remove(location)
        if locations_y and location in locations_y:
            locations_y.remove(location)

    if extra_output:
        return locations, locations_x, locations_y, empty_timeseries
    else:
        return locations, empty_timeseries


def create_label(label_text, height, width):
    """
    Creates standard label to be shown in bokeh plot.

    Parameters
    ----------
    label_text : string

    Returns
    -------
    new_label : bokeh.models.Label object, with label_text as text of label
    """
    import bokeh.models
    y_height = 0.9 * height
    new_label = bokeh.models.Label(x=70, y=y_height, x_units='screen',
                                   y_units='screen', text=label_text,
                                   render_mode='canvas',
                                   border_line_color='black',
                                   border_line_alpha=1.0,
                                   background_fill_color='white',
                                   background_fill_alpha=1.0)
    return new_label


def bokeh_double_mass(parameter, locations_x, locations_y,
                      startdate, enddate, interp_method=None,
                      wps=True, mode="static", static_folder="", js_folder=""):
    """
    Creates a double mass curve based on a selected parameter and locations.
    Two sets of locations should be selected, set can consist of a single or
    multiple locations. In case of multiple locations the mean of the values
    is calculated.
    Parameters
    ----------
    parameter : string, name of parameter that is selected
    locations : list, list of locations (strings) that are selected in the
        viewer
    startdate : start date of search period
    enddate : end date of search period
    interp_method : default None
        interpolation method, can be one of the following functions:
        None --> removes all nans
        fill_value --> give in value to fill nans
        ffill --> forward fill
        any other function of the fillna function of pandas
    wps : boolean, default True
    mode : string, default static
        determines output of script (static, wps)
    static_folder : string, default .
        Path to the static folder on server

    Returns
    -------
    f : StringIO object containing json with path to html of bokeh plot
    """
    import logging

    import pandas as pd
    import numpy as np

    import bokeh
    import bokeh.embed
    import bokeh.plotting
    import bokeh.resources

    import hymos_functions

    no_data_text = None
    plot_name = "bokeh_double_mass"
    colors = ["#1F77B4", "#1FB69F", "#B61F6D", "#B67A1F", "#72B61F", "#B61F33",
              "#B6B41F"] * 10

    logger = logging.getLogger(__name__)
    logger.setLevel(logging.DEBUG)

#    locations_x = locations_x.split(",")
#    locations_y = locations_y.split(",")

    locations_x = hymos_functions.parse_locations(locations_x)
    locations_y = hymos_functions.parse_locations(locations_y)
    locations = tuple(np.unique(np.array(locations_x + locations_y)))

    df = hymos_functions.get_timeseries(locations, parameter, startdate,
                                        enddate)

    param_dict = hymos_functions.get_parameter_names(parameter)
    locations, locations_x, locations_y, no_data_loc = check_availability(
        df, locations, locations_x, locations_y)

    if df.empty:
        msg = "No data available for any location"
        logging.warning(msg)
        no_data_loc += locations
        locations_x = []
        locations_y = []
        locations = []
        no_data_text = msg
    else:
        df_ts = hymos_functions.create_df(df, locations, "data_values")

    df_filled = hymos_functions.gap_filling(df_ts, method=interp_method)

    if df_filled.empty and not df.empty:
        msg = "No timesteps with data available for all timeseries"
        logging.warning(msg)
        no_data_loc += locations
        locations_x = []
        locations_y = []
        locations = []
        no_data_text = msg
    else:
        df_cumsum = df_filled.cumsum()

    # Splitting series into x and y locations is done after interpolation to
    # make sure the same amount of timesteps is available for each station.
    # This might go wrong in case there is a station that has no data for
    # that period. In that case the script will return no data at all.
    df_merged = hymos_functions.averaging(df_cumsum, locations_x, locations_y)

    df_ts_filled = hymos_functions.gap_filling(df_ts, method=None)

    for column in df_ts_filled.columns:
        df_new = pd.DataFrame(df_ts_filled[column])
        df_new = hymos_functions.add_nans(df_new, column)
        df_merged = pd.concat([df_merged, df_new], axis=1)

    df_merged.reset_index()
    logger.debug("generating sources")
    source = bokeh.models.ColumnDataSource(data=df_merged)

    # plot
    logger.debug("generating plots")
    param = param_dict[parameter]
    Tools = "box_zoom, wheel_zoom, pan, reset"
    p = bokeh.plotting.Figure(title="Double mass curve", tools=Tools,
                              active_scroll="wheel_zoom")
    p.line("x_locations", "y_locations", source=source, color="firebrick")
    loc_string = ", ".join(locations_x)
    x_axis_label = "Cumulative {:s} locations_x: {:s}".format(param.name,
                                                              loc_string)
    p.xaxis.axis_label = (x_axis_label)

    loc_string = ", ".join(locations_y)
    y_axis_label = "Cumulative {:s} locations_y: {:s}".format(param.name,
                                                              loc_string)
    p.yaxis.axis_label = (y_axis_label)
    cr = p.circle("x_locations", "y_locations", size=20,
                  fill_color=None, hover_fill_color="firebrick",
                  hover_alpha=0.3, line_color=None, hover_line_color="white",
                  source=source)

    p.add_tools(bokeh.models.tools.HoverTool(tooltips=None, renderers=[cr],
                                             mode="hline"))

    Tools_x = "box_zoom, xwheel_zoom, xpan, reset"
    # timeseries plotting x_locations
    p_tx = bokeh.plotting.Figure(title="Timeseries locationset x-axis",
                                 x_axis_type="datetime",
                                 tools=Tools_x,
                                 active_scroll="xwheel_zoom")
    p_tx.yaxis.axis_label = "{:s} {:s}".format(param.name, param.unit)
    crx = []
    for ind, location in enumerate(locations_x):
        p_tx.line("timestamp", location, source=source, color=colors[ind],
                  legend=location)
        crx.append(p_tx.circle("timestamp", location, size=20,
                               fill_color=None, hover_fill_color=colors[ind],
                               hover_alpha=0.3, line_color=None,
                               hover_line_color="white", source=source))
    p_tx.add_tools(bokeh.models.tools.HoverTool(tooltips=None, renderers=crx,
                                                mode="vline"))

    # timeseries plotting y_locations
    p_ty = bokeh.plotting.Figure(title="Timeseries locationset y-axis",
                                 x_axis_type="datetime",
                                 x_range=p_tx.x_range, y_range=p_tx.y_range,
                                 tools=Tools_x,
                                 active_scroll="xwheel_zoom")
    p_ty.yaxis.axis_label = "{:s} {:s}".format(param.name, param.unit)
    cry = []

    for ind, location in enumerate(locations_y):
        p_ty.line("timestamp", location, source=source, color=colors[ind],
                  legend=location)
        cry.append(p_ty.circle("timestamp", location, size=20,
                               fill_color=None, hover_fill_color=colors[ind],
                               hover_alpha=0.3, line_color=None,
                               hover_line_color="white", source=source))
    p_ty.add_tools(bokeh.models.tools.HoverTool(tooltips=None, renderers=cry,
                                                mode="vline"))

    if no_data_loc and locations_x and locations_y:
        no_data_text = "No data for:\n{:s}".format(", ".join(no_data_loc))
        no_data_label = create_label(no_data_text, p.plot_height, p.plot_width)
        p.add_layout(no_data_label)
    elif not locations_x or not locations_y:
        if no_data_text is None:
            no_data_text = "No data available for search period"
        no_data_label = create_label(no_data_text, p.plot_height, p.plot_width)
        p.add_layout(no_data_label)
        if not locations_x:
            no_data_label_x = create_label(no_data_text, p_tx.plot_height,
                                           p_tx.plot_width)
            p_tx.add_layout(no_data_label_x)
        if not locations_y:
            no_data_label_y = create_label(no_data_text, p_ty.plot_height,
                                           p_ty.plot_width)
            p_ty.add_layout(no_data_label_y)

    # Grouping plots
    grd = bokeh.plotting.gridplot([[p, p_tx, p_ty]], toolbar_location="right")

    f = generate_output(static_folder, js_folder, mode, plot_name, grd)

    return f


def bokeh_residual(parameter, locations, startdate, enddate,
                   interp_method=None, wps=True, mode='static',
                   static_folder="", js_folder=""):
    """
    Creates a residual plot based on a selected parameter and location(s).
    Residual is calculated as value - mean_value

    Parameters
    ----------
    parameter : string, name of parameter that is selected
    locations : list, list of locations (strings) that are selected in the
        viewer
    startdate : start date of search period
    enddate : end date of search period
    interp_method : default None
        interpolation method, can be one of the following functions:
        None --> removes all nans
        fill_value --> give in value to fill nans
        ffill --> forward fill
        any other function of the fillna function of pandas
    wps : boolean, default True
    mode : string, default static
        determines output of script (static, wps)
    static_folder : string, default .
        Path to the static folder on server

    Returns
    -------
    f : StringIO object containing json with path to html of bokeh plot
    """
    import logging

    import pandas as pd

    import bokeh
    import bokeh.embed
    import bokeh.plotting
    import bokeh.resources

    import hymos_functions

    logger = logging.getLogger(__name__)
    logger.setLevel(logging.DEBUG)

    plot_name = 'bokeh_residual'
    colors = ["#1F77B4", "#1FB69F", "#B61F6D", "#B67A1F", "#72B61F", "#B61F33",
              "#B6B41F"]

#    locations = locations.split(",")
    locations = hymos_functions.parse_locations(locations)

    df = hymos_functions.get_timeseries(locations, parameter, startdate,
                                        enddate)
    logging.info("timeseries imported")
    param_dict = hymos_functions.get_parameter_names(parameter)
    locations, no_data_loc = check_availability(df, locations)

    df_merged_dict = {}
    sources_dict = {}
    for key, grp in df.groupby(df.location_id):
        grp = grp.reset_index().drop_duplicates(subset='timestamp',
                                                keep='last')
        grp = grp.set_index('timestamp')
        grp_filled = hymos_functions.gap_filling(grp["data_values"],
                                                 method=interp_method)
        grp_filled = pd.DataFrame(grp_filled)
        grp_filled.columns = [key]

        grp_residual = hymos_functions.calculate_residual(grp_filled)

        grp_residual = hymos_functions.add_nans(grp_residual, key)

        df_timestamp = pd.Series(grp_residual.index,
                                 grp_residual.index)
        df_str_time = df_timestamp.dt.strftime("%Y%m%d")

        df_new = pd.concat([df_str_time, grp_residual], axis=1)
        df_merged_dict[key] = df_new.to_dict(orient="records")

        source = bokeh.models.ColumnDataSource(data=grp_residual)
        sources_dict[key] = source

    # plot
    logger.debug("generating plots")
    Tools = "box_zoom, xwheel_zoom, xpan, reset"
    p = bokeh.plotting.Figure(plot_width=1000, plot_height=500,
                              x_axis_type="datetime", tools=Tools,
                              active_scroll="xwheel_zoom")

    i = 0
    for key, source in sources_dict.items():
        p.line("timestamp", key, source=source, color=colors[i],
               legend=key)
        i += 1
    p.yaxis.axis_label = "Residual %s" % param_dict[parameter].name

    if no_data_loc:
        no_data_text = "No data for:\n{:s}".format(", ".join(no_data_loc))
        no_data_label = create_label(no_data_text, p.plot_height, p.plot_width)
        p.add_layout(no_data_label)

    grd = bokeh.plotting.gridplot([[p]], toolbar_location="right")

    f = generate_output(static_folder, js_folder, mode, plot_name, grd)

    return f


def bokeh_aggregate(parameter, locations, startdate, enddate, multiplier=1,
                    unit="D", interp_method=None, wps=True, mode='static',
                    static_folder="", js_folder=""):
    """
    Creates a timeseries plot based on a selected parameter and location(s).

    Parameters
    ----------
    parameter : string, name of parameter that is selected
    locations : list, list of locations (strings) that are selected in the
        viewer
    startdate : start date of search period
    enddate : end date of search period
    timestep : int, default 1, aggregation timestep
    interp_method : default None
        interpolation method, can be one of the following functions:
        None --> removes all nans
        fill_value --> give in value to fill nans
        ffill --> forward fill
        any other function of the fillna function of pandas
    wps : boolean, default True
    mode : string, default static
        determines output of script (static, wps)
    static_folder : string, default .
        Path to the static folder on server

    Returns
    -------
    f : StringIO object containing json with path to html of bokeh plot
    """
    import logging

    import pandas as pd

    import bokeh
    import bokeh.embed
    import bokeh.plotting
    import bokeh.resources

    import hymos_functions

    logger = logging.getLogger(__name__)
    logger.setLevel(logging.DEBUG)

    plot_name = 'bokeh_aggregate'
    colors = ["#1F77B4", "#1FB69F", "#B61F6D", "#B67A1F", "#72B61F", "#B61F33",
              "#B6B41F"]

#    locations = locations.split(",")
    locations = hymos_functions.parse_locations(locations)

    df = hymos_functions.get_timeseries(locations, parameter, startdate,
                                        enddate)
    logging.info("timeseries imported")

    freq = "%s%s" % (multiplier, unit)

    param_dict = hymos_functions.get_parameter_names(parameter)
    locations, no_data_loc = check_availability(df, locations)
    param = param_dict[parameter]
    df_merged_dict = {}
    sources_dict = {}
    for key, grp in df.groupby(df.location_id):
        logging.info("create new series for %s", key)
        grp = grp.reset_index().drop_duplicates(subset='timestamp',
                                                keep='last')
        grp = grp.set_index('timestamp')
        grp_agg = hymos_functions.aggregate_function(grp, freq,
                                                     param.parametertype)

        df_timestamp = pd.Series(grp_agg.index,
                                 grp_agg.index)
        df_str_time = df_timestamp.dt.strftime("%Y%m%d")

        df_new = pd.concat([df_str_time, grp_agg["data_values"]], axis=1)
        df_merged_dict[key] = df_new.to_dict(orient="records")

        source = bokeh.models.ColumnDataSource(data=grp_agg)
        sources_dict[key] = source

    # plot
    logger.debug("generating plots")
    Tools = "box_zoom, xwheel_zoom, xpan, reset"
    p = bokeh.plotting.Figure(plot_width=1000, plot_height=500,
                              x_axis_type="datetime", tools=Tools,
                              active_scroll="xwheel_zoom")

    i = 0
    for key, source in sources_dict.items():
        p.line("timestamp", "data_values", source=source, color=colors[i],
               legend=key)
        i += 1

    p.yaxis.axis_label = "Aggregate %s, timestep = %s" % (param.name, freq)

    if no_data_loc:
        no_data_text = "No data for:\n{:s}".format(", ".join(no_data_loc))
        no_data_label = create_label(no_data_text, p.plot_height, p.plot_width)
        p.add_layout(no_data_label)

    grd = bokeh.plotting.gridplot([[p]], toolbar_location="right")

    f = generate_output(static_folder, js_folder, mode, plot_name, grd)

    return f


def bokeh_probability_density(parameter, locations, startdate, enddate,
                              interp_method=None, wps=True,
                              mode='static', static_folder="", js_folder=""):
    """
    Creates a timeseries plot based on a selected parameter and location(s).

    Parameters
    ----------
    parameter : string, name of parameter that is selected
    locations : list, list of locations (strings) that are selected in the
        viewer
    startdate : start date of search period
    enddate : end date of search period
    interp_method : default None
        interpolation method, can be one of the following functions:
        None --> removes all nans
        fill_value --> give in value to fill nans
        ffill --> forward fill
        any other function of the fillna function of pandas
    wps : boolean, default True
    mode : string, default static
        determines output of script (static, wps)
    static_folder : string, default .
        Path to the static folder on server

    Returns
    -------
    f : StringIO object containing json with path to html of bokeh plot
    """
    import logging

    import pandas as pd
    import numpy as np
    from scipy.stats.kde import gaussian_kde

    import bokeh
    import bokeh.embed
    import bokeh.plotting
    import bokeh.resources

    import hymos_functions

    logger = logging.getLogger(__name__)
    logger.setLevel(logging.DEBUG)

    plot_name = 'bokeh_probability_density'
    colors = ["#1F77B4", "#1FB69F", "#B61F6D", "#B67A1F", "#72B61F", "#B61F33",
              "#B6B41F"]

#    locations = locations.split(",")
    locations = hymos_functions.parse_locations(locations)

    df = hymos_functions.get_timeseries(locations, parameter, startdate,
                                        enddate)
    logging.info("timeseries imported")
    param_dict = hymos_functions.get_parameter_names(parameter)
    locations, no_data_loc = check_availability(df, locations)

    df_merged_dict = {}
    sources_dict = {}
    for key, grp in df.groupby(df.location_id):
        logging.info("create new series for %s", key)
        grp = grp.reset_index().drop_duplicates(subset='timestamp',
                                                keep='last')
        grp = grp.set_index('timestamp')
        KDEpdf = gaussian_kde(grp.data_values)  # TODO: fout bij constante reeks
        x_app = list(np.linspace(np.min(grp.data_values),
                                 np.max(grp.data_values),
                                 1000))
        df_new = pd.DataFrame(data={"x": x_app,
                                    "pdf": KDEpdf(x_app)},
                              index=x_app, columns=["x", "pdf"])

        df_merged_dict[key] = df_new.to_dict(orient="records")

        source = bokeh.models.ColumnDataSource(data=df_new)
        sources_dict[key] = source

    # plot
    logger.debug("generating plots")
    Tools = "box_zoom, xwheel_zoom, xpan, reset"
    p = bokeh.plotting.Figure(plot_width=1000, plot_height=500,
                              title="Probability density",
                              tools=Tools, active_scroll="xwheel_zoom")

    i = 0
    for key, source in sources_dict.items():
        p.line("x", "pdf", source=source, color=colors[i],
               legend=key)
        i += 1
    p.yaxis.axis_label = "Probability density %s" % param_dict[parameter].name

    if no_data_loc:
        no_data_text = "No data for:\n{:s}".format(", ".join(no_data_loc))
        no_data_label = create_label(no_data_text, p.plot_height, p.plot_width)
        p.add_layout(no_data_label)

    grd = bokeh.plotting.gridplot([[p]], toolbar_location="right")

    f = generate_output(static_folder, js_folder, mode, plot_name, grd)

    return f


def bokeh_availability(parameter, locations, startdate, enddate, multiplier=1,
                       unit="D", wps=True, mode='static',
                       static_folder="", js_folder=""):
    """
    Determines the availability of data for the selected location and
    parameters. Plots a constant line for available data.

    Parameters
    ----------
    parameter : string, name of parameter that is selected
    locations : list, list of locations (strings) that are selected in the
        viewer
    startdate : start date of search period
    enddate : end date of search period
    multiplier : int, multplier of the time-unit
    unit : string, default "D"
        time-unit corresponding to pandas to_period function "D" = day,
    wps : boolean, default True
    mode : string, default static
        determines output of script (static, wps)
    static_folder : string, default .
        Path to the static folder on server

    Returns
    -------
    f : StringIO object containing json with path to html of bokeh plot
    """
    import logging

    import pandas as pd
    import numpy as np
    import datetime

    import bokeh
    import bokeh.embed
    import bokeh.plotting
    import bokeh.resources

    import hymos_functions

    logger = logging.getLogger(__name__)
    logger.setLevel(logging.DEBUG)

    plot_name = 'bokeh_availability'
    colors = ["#1F77B4", "#1FB69F", "#B61F6D", "#B67A1F", "#72B61F", "#B61F33",
              "#B6B41F"]

#    locations = locations.split(",")
    locations = hymos_functions.parse_locations(locations)

    df = hymos_functions.get_timeseries(locations, parameter, startdate,
                                        enddate)

    unit, multiplier, plot_dots = hymos_functions.check_timestep(df, unit,
                                                                 multiplier)
    freq = "%s%s" % (multiplier, unit)

    logging.info("timeseries imported")
    param_dict = hymos_functions.get_parameter_names(parameter)
    locations, no_data_loc = check_availability(df, locations)

    df_grouped = df.groupby(df.location_id)

    dr = pd.date_range(startdate, enddate, freq=freq)
    dummy_val = np.array(np.zeros((len(dr), 1)))
    dummy_val[dummy_val == 0] = np.NaN
    df_dummy = pd.DataFrame(dummy_val, index=dr)
    df_dummy.columns = ["Dummy"]
    df_dummy.index.name = "timestamp"

    df_dummy.index = df_dummy.index.to_period(freq=freq)
    df_merged_dict = {}
    sources_dict = {}
    i = 1
    for key, grp in df_grouped:
        logging.info("create new series for %s", key)
        grp = grp.reset_index().drop_duplicates(subset='timestamp',
                                                keep='last')
        grp = grp.set_index('timestamp')
        grp_period = grp.data_values.to_period(freq=freq)
        grp_aggr = hymos_functions.aggregate_function(grp_period, freq)
        grp_available = pd.concat([df_dummy, grp_aggr], axis=1)
        del grp_available["Dummy"]
        grp_available.index = grp_available.index.to_timestamp()
        grp_available.columns = [key]
        df_mask = grp_available[key].isnull()
        grp_available[key] = grp_available[key].where(df_mask, i)

        df_timestamp = pd.Series(grp_available.index,
                                 grp_available.index)

        df_str_time = df_timestamp.dt.strftime("%Y%m%d")

        df_new = pd.concat([df_str_time, grp_available[key]], axis=1)
        df_merged_dict[key] = df_new.to_dict(orient="records")

        source = bokeh.models.ColumnDataSource(data=grp_available)
        sources_dict[key] = source
        i += 1

    # plot
    logger.debug("generating plots")
    Tools = "box_zoom, xwheel_zoom, xpan, reset"
    p = bokeh.plotting.Figure(plot_width=1000, plot_height=500,
                              x_axis_type="datetime",
                              tools=Tools, active_scroll="xwheel_zoom",
                              y_range=(0, i))

    i = 0
    for key, source in sources_dict.items():
        p.line("timestamp", key, source=source, color=colors[i],
               legend=key)
        if plot_dots:
            p.circle("timestamp", key, source=source, color=colors[i])
        i += 1

    p.yaxis.axis_label = "Availability %s" % param_dict[parameter].name

    if no_data_loc:
        no_data_text = "No data for:\n{:s}".format(", ".join(no_data_loc))
        no_data_label = create_label(no_data_text, p.plot_height, p.plot_width)
        p.add_layout(no_data_label)

    grd = bokeh.plotting.gridplot([[p]], toolbar_location="right")

    f = generate_output(static_folder, js_folder, mode, plot_name, grd)

    return f


def bokeh_timeseries(parameter, locations, startdate, enddate,
                     interp_method=None, wps=True, mode='static',
                     static_folder="", js_folder=""):
    """
    Creates a timeseries plot based on a selected parameter and location(s).

    Parameters
    ----------
    parameter : string, name of parameter that is selected
    locations : list, list of locations (strings) that are selected in the
        viewer
    startdate : start date of search period
    enddate : end date of search period
    interp_method : default None
        interpolation method, can be one of the following functions:
        None --> removes all nans
        fill_value --> give in value to fill nans
        ffill --> forward fill
        any other function of the fillna function of pandas
    wps : boolean, default True
    mode : string, default static
        determines output of script (static, wps)
    static_folder : string, default .
        Path to the static folder on server

    Returns
    -------
    f : StringIO object containing json with path to html of bokeh plot
    """
    import logging

    import pandas as pd

    import bokeh
    import bokeh.embed
    import bokeh.plotting
    import bokeh.resources

    import hymos_functions

    logger = logging.getLogger(__name__)
    logger.setLevel(logging.DEBUG)

    plot_name = 'bokeh_timeseries'
    colors = ["#1F77B4", "#1FB69F", "#B61F6D", "#B67A1F", "#72B61F", "#B61F33",
              "#B6B41F"]

#    locations = locations.split(",")
    locations = hymos_functions.parse_locations(locations)

    df = hymos_functions.get_timeseries(locations, parameter, startdate,
                                        enddate)
    logging.info("timeseries imported")
    param_dict = hymos_functions.get_parameter_names(parameter)
    locations, no_data_loc = check_availability(df, locations)

    df_grouped = df.groupby(df.location_id)

    df_merged_dict = {}
    sources_dict = {}

    for key, grp in df_grouped:
        logging.info("create new series for %s", key)
        grp = grp.reset_index().drop_duplicates(subset='timestamp',
                                                keep='last')
        grp = grp.set_index('timestamp')

        grp = pd.DataFrame(grp["data_values"])

        grp = hymos_functions.add_nans(grp, key)

        df_timestamp = pd.Series(grp.index,
                                 grp.index)
        df_str_time = df_timestamp.dt.strftime("%Y%m%d")

        df_new = pd.concat([df_str_time, grp["data_values"]], axis=1)
        df_merged_dict[key] = df_new.to_dict(orient="records")

        source = bokeh.models.ColumnDataSource(data=grp)
        sources_dict[key] = source

    # plot
    logger.debug("generating plots")

    Tools = "box_zoom, xwheel_zoom, xpan, reset"
    p = bokeh.plotting.Figure(plot_width=1000, plot_height=500,
                              x_axis_type="datetime", tools=Tools,
                              active_scroll="xwheel_zoom")

    i = 0
    for key, source in sources_dict.items():
        p.line("timestamp", "data_values", source=source, color=colors[i],
               legend=key)
        i += 1

    p.yaxis.axis_label = "%s" % param_dict[parameter].name

    if no_data_loc:
        no_data_text = "No data for:\n{:s}".format(", ".join(no_data_loc))
        no_data_label = create_label(no_data_text, p.plot_height, p.plot_width)
        p.add_layout(no_data_label)

    grd = bokeh.plotting.gridplot([[p]], toolbar_location="right")

    f = generate_output(static_folder, js_folder, mode, plot_name, grd)

    return f


def bokeh_rating_curve(parameters, locations, startdate, enddate,
                       interp_method=None, wps=True,
                       mode='static', static_folder="", js_folder=""):
    """
    Creates a rating curve plot based on a selected parameter and location(s).

    Parameters
    ----------
    parameter : string, name of parameter that is selected
    locations : list, list of locations (strings) that are selected in the
        viewer
    startdate : start date of search period
    enddate : end date of search period
    interp_method : default None
        interpolation method, can be one of the following functions:
        None --> removes all nans
        fill_value --> give in value to fill nans
        ffill --> forward fill
        any other function of the fillna function of pandas
    wps : boolean, default True
    mode : string, default static
        determines output of script (static, wps)
    static_folder : string, default .
        Path to the static folder on server

    Returns
    -------
    f : StringIO object containing json with path to html of bokeh plot
    """
    import logging

    import pandas as pd
    import numpy as np
    import scipy.optimize

    import bokeh
    import bokeh.embed
    import bokeh.plotting
    import bokeh.resources

    import hymos_functions

    def funct(x, a, b):
        return a * x ** b

    logger = logging.getLogger(__name__)
    logger.setLevel(logging.DEBUG)

    plot_name = 'bokeh_rating_curve'
    colors = ["#1F77B4", "#1FB69F", "#B61F6D", "#B67A1F", "#72B61F", "#B61F33",
              "#B6B41F"]

#    locations = locations.split(",")
    locations = hymos_functions.parse_locations(locations)

    parameters = parameters.split(",")
    if "H.obs" in parameters and "Q.obs.validated" in parameters:
        pass
    else:
        return
        logger.info("Select waterlevel and discharge parameter")

    df = hymos_functions.get_timeseries(locations, parameters, startdate,
                                        enddate)
    param_dict = hymos_functions.get_parameter_names(parameters)
    locations, no_data_loc = check_availability(df, locations)

    logging.info("timeseries imported")
    param_dict = hymos_functions.get_parameter_names(parameters)
    locations, no_data_loc = check_availability(df, locations)

#    df_merged_dict = {}
    sources_dict = {}

    for key, grp in df.groupby(df.location_id):
        logging.info("create new series for %s", key)
        for key2, grp2 in grp.groupby(grp.parameter_id):
            grp2 = grp2.reset_index().drop_duplicates(subset='timestamp',
                                                      keep='last')
            grp2 = grp2.set_index('timestamp')
            grp2.data_values[grp2.data_values < 0] = 0
            if key2 == "Q.obs.validated":
                Q = grp2.data_values
            elif key2 == "H.obs":
                grp2.data_values[grp2.data_values > 300] = np.nan
                h = grp2.data_values / 100  # correct for cm --> m

        df_new1 = pd.concat([h, Q], axis=1)
        df_new1.columns = ["h", "Q"]
        df_filled = hymos_functions.gap_filling(df_new1)

        error = False
        try:
            popt, pcov = scipy.optimize.curve_fit(funct, df_filled["h"],
                                                  df_filled["Q"])
        except RuntimeError as re:
            print(re)
            error = True

        x_app = list(np.linspace(0, np.max(df_filled["h"]) * 1.25, 1000))

        if not error:
            y_app = funct(x_app, popt[0], popt[1])

        df_obs = pd.DataFrame(data={"h": df_filled["h"],
                                    "Q": df_filled["Q"]})
        df_sim = pd.DataFrame(data={"h_est": x_app,
                                    "Q_est": y_app})

        source_sim = bokeh.models.ColumnDataSource(data=df_sim)
        source_obs = bokeh.models.ColumnDataSource(data=df_obs)

        sources_dict[key] = {}
        sources_dict[key]["sim"] = source_sim
        sources_dict[key]["obs"] = source_obs


#    return df_merged_dict, sources_dict
    logger.debug("generating plots")
    Tools = "box_zoom, xwheel_zoom, xpan, reset"
    p = bokeh.plotting.Figure(plot_width=1000, plot_height=500,
                              title="rating curve",
                              tools=Tools, active_scroll="xwheel_zoom")

    i = 0
    for key, source in sources_dict.items():
        src_sim = source["sim"]
        src_obs = source["obs"]
        p.line("Q_est", "h_est", source=src_sim, color=colors[i],
               legend=key)
#        p.line("Q", "h", source=src_obs, color=colors[i+1])
        p.scatter("Q", "h", source=src_obs, alpha=0.15, size=8,
                  color=colors[i+1])
        i += 1
    p.yaxis.axis_label = "Rating curve %s" % param_dict[parameters[0]].name

    if no_data_loc:
        no_data_text = "No data for:\n{:s}".format(", ".join(no_data_loc))
        no_data_label = create_label(no_data_text, p.plot_height, p.plot_width)
        p.add_layout(no_data_label)

    grd = bokeh.plotting.gridplot([[p]], toolbar_location="right")

    f = generate_output(static_folder, js_folder, mode, plot_name, grd)

    return f


def get_indices(array, value):
    """
    Finds the location of a value in sorted array, returns two indices.
    The indices indicate the value that is <= input value and > input value

    Parameters
    ----------
    array : sorted numpy array
    value : float, int

    Returns
    -------
    i : int, index for value <= input value
    i + 1 : int, index for value > input_value
    """
    for i in range(len(array)-1):
        if array[i] <= value < array[i+1]:
            return i, i + 1
        elif array[0] > value or array[-1] < value:
            return -999.0, -999.0


def check_month(c_year, month, last_month, row):
    """
    Support function for the get_freq function. Checks whether the new month is
    1 month later than the previous month (last_month). If not c_year is filled
    with np.nan, if month number of "month" follows last_month directly the
    value is filled in in c_year.

    Parameters
    ----------
    c_year : list, values per month for the current year
    month : int, month_number of current month (e.g. 1 = January, 2 = Feb)
    last_month : int, month_number of last month (e.g. 1 = January, 2 = Feb)
    row : pandas.DataFrame-row,
        {0: index, 1: [data_values, location_id, parameter_id]}

    Return
    ------
    c_year : list, values per month for the current year
    last_month : int, month_number of last month (e.g. 1 = January, 2 = Feb)
    """
    import numpy as np
    if month == last_month + 1:
        a = month - 1
        c_year[a] = row[1].data_values
        last_month += 1
    else:
        diff = last_month + 1 - month
        for i_month in range(diff):
            last_month += 1
            a = last_month - 1
            c_year[a] = np.nan
        a = month - 1
        c_year[a] = row[1].data_values
        last_month += 1
    return c_year, last_month


def get_freq(df, perc_list):
    """
    Determines input for frequency and duration plots
    The following method is used for calculation:
    1. get data
    2. sort data in ascending order
    3. determine rank and calculate 1/(meff + 1) (assuming equiprobability)
    4. Interpolate to 0.1, 0.2, 0.3 etc. (frequency plot)

    5. sort results from 4 to ascending order (duration plot)

    Parameters
    ----------
    df : pandas.DataFrame, rows are times, column with values should be called
        data_values

    Returns
    -------
    perc_list : list, percentages to be plotted
    df_freq : pandas.DataFrame, frequency data (step 4)
    df_dur : pandas.DataFrame, duration data (step 5)
    """
    import numpy as np
    import pandas as pd
    df = df.sort_index()
    data = []
    years = [df.index[0].year]
    last_year = df.index[0].year
    last_month = 0
    c_year = np.zeros(12)
    for row in df.iterrows():
        year = row[0].year
        month = row[0].month
        if year == last_year:
            c_year, last_month = check_month(c_year, month, last_month, row)
        else:
            years.append(year)
            data.append(c_year)
            last_year = np.copy(year)
            c_year = np.zeros(12)
            last_month = 0
            c_year, last_month = check_month(c_year, month, last_month, row)

    X = np.array(data)
    R = np.sort(X, axis=0)[::-1]
    m_eff = np.array([np.count_nonzero(~np.isnan(R[:, j])) for j in range(12)])
    F = np.zeros((R.shape))
    for i in xrange(len(R)):
        new_row = (i + 1.) / (m_eff + 1)
        F[i, :] = new_row
    shape_y, shape_x = F.shape
    perc_list_str = [str(perc) for perc in perc_list]
    B = np.zeros((len(perc_list), shape_x))
    for i, perc in enumerate(perc_list):
        for col in xrange(shape_x):
            column = F[:, col]
            ind1, ind2 = get_indices(column, perc)
            factor = ((perc - F[ind1, col]) / (F[ind2, col] - F[ind1, col]))
            b = (R[ind2, col] - R[ind1, col])
            B[i, col] = R[ind1, col] + b * factor

    month_names = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                   "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
#    df_m = pd.DataFrame(month_names, index=month_names, columns=["months"])
    df_m = pd.DataFrame(range(1, 13), index=month_names, columns=["months"])
    df = pd.DataFrame(data=np.transpose(B), index=month_names,
                      columns=perc_list_str[::-1])
    df_freq = pd.concat([df_m, df], axis=1)

    B_sort = np.sort(B)
    df2 = pd.DataFrame(data=np.transpose(B_sort), index=month_names,
                       columns=perc_list_str[::-1])
    df_dur = pd.concat([df_m, df2], axis=1)

    return df_freq, df_dur


def bokeh_frequency_duration(parameter, locations, startdate, enddate,
                             mmode="year", nmode="month", wps=True,
                             mode='static', static_folder="", js_folder=""):
    """
    Creates frequency and duration plots based on a selected parameter and
    location.
    The following method is used for calculation:
    1. get data
    2. sort data in ascending order
    3. determine rank and calculate 1/(meff + 1) (assuming equiprobability)
    4. Interpolate to 0.1, 0.2, 0.3 etc. (frequency plot)

    5. sort results from 4 to ascending order (duration plot)

    Parameters
    ----------
    parameter : string, name of parameter that is selected
    locations : list, list of locations (strings) that are selected in the
        viewer
    startdate : start date of search period
    enddate : end date of search period
    mmode : string, default "year"
        time-unit of main axis
    nmode : string, default "month"
        time-unit of secondary axis
    wps : boolean, default True
    mode : string, default static
        determines output of script (static, wps)
    static_folder : string, default .
        Path to the static folder on server

    Returns
    -------
    f : StringIO object containing json with path to html of bokeh plot
    """
    import logging

    import bokeh
    import bokeh.embed
    import bokeh.plotting
    import bokeh.resources

    import hymos_functions

    logger = logging.getLogger(__name__)
    logger.setLevel(logging.DEBUG)

    plot_name = 'bokeh_frequency_duration'
    colors = ["#1F77B4", "#1FB69F", "#B61F6D", "#B67A1F", "#72B61F", "#B61F33",
              "#B6B41F"] * 10

    perc_list = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]
#    locations = locations.split(",")
    locations = hymos_functions.parse_locations(locations)

    df = hymos_functions.get_timeseries(locations, parameter, startdate,
                                        enddate)
    logging.info("timeseries imported")
    param_dict = hymos_functions.get_parameter_names(parameter)
    locations, no_data_loc = check_availability(df, locations)

    df_merged_dict = {}
    sources_dict = {}
    for key, grp in df.groupby(df.location_id):
        logging.info("create new series for %s", key)
        grp = grp.reset_index().drop_duplicates(subset='timestamp',
                                                keep='last')
        grp = grp.set_index('timestamp')
        df_freq, df_dur = get_freq(grp, perc_list)

        df_merged_dict[key] = {}
        df_merged_dict[key]["freq"] = df_freq.to_dict(orient="records")
        df_merged_dict[key]["dur"] = df_dur.to_dict(orient="records")

        source_freq = bokeh.models.ColumnDataSource(data=df_freq)
        source_dur = bokeh.models.ColumnDataSource(data=df_dur)
        sources_dict[key] = {}
        sources_dict[key]["freq"] = source_freq
        sources_dict[key]["dur"] = source_dur

#    return X, R, F, B, perc_list, df_new, sources_dict
    # plot
    logger.debug("generating plots")
    Tools = "box_zoom, xwheel_zoom, xpan, reset"
    p_freq = bokeh.plotting.Figure(plot_width=500, plot_height=500,
                                   title="Frequency",
                                   tools=Tools, active_scroll="xwheel_zoom")

    p_dur = bokeh.plotting.Figure(plot_width=500, plot_height=500,
                                  title="Duration",
                                  tools=Tools, active_scroll="xwheel_zoom")

    i = 0
    perc_list_str = [str(perc) for perc in perc_list]
    for key, source in sources_dict.items():
        for perc in perc_list_str:
            p_freq.line("months", perc, source=source["freq"], color=colors[i],
                        legend=perc)
            p_dur.line("months", perc, source=source["dur"], color=colors[i],
                       legend=perc)
            i += 1
    param = param_dict[parameter].name
    p_freq.yaxis.axis_label = "%s" % param
    p_dur.yaxis.axis_label = "%s" % param
    p_dur.legend.location = "top_left"

    if no_data_loc:
        no_data_text = "No data for:\n{:s}".format(", ".join(no_data_loc))
        no_data_label = create_label(no_data_text, p_dur.plot_height,
                                     p_dur.plot_width)
        p_dur.add_layout(no_data_label)

    grd = bokeh.plotting.gridplot([[p_freq, p_dur]], toolbar_location="right")

    f = generate_output(static_folder, js_folder, mode, plot_name, grd)

    return f
