#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares for <projectdata>
#       Lilia Angelova
#       Lilia.Angelova@deltares.nl
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


from bokeh.plotting import figure, show, output_file, save
from bokeh.models import (
    HoverTool,
    LabelSet,
    Legend,
    ColumnDataSource,
    DatetimeTickFormatter,
)
import logging
from bokeh.layouts import column
import configparser, os
import pandas
import pyodbc


def sql_connect(location):
    config = configparser.ConfigParser()
    # config.read_file(open(r'c:\Users\angelova\OneDrive - Stichting Deltares\Desktop\A27\wps2\processes\connection.txt'))
    config.read_file(open("/opt/pywps/processes/connection.txt"))
    details_dict = dict(config.items("param"))
    conn_str = "DRIVER={}; SERVER={};Database={};UID={}; PWD={};".format(
        details_dict["driver"],
        details_dict["server"],
        details_dict["db"],
        details_dict["uid"],
        details_dict["pwd"],
    )
    cnxn = pyodbc.connect(conn_str)
    cursor = cnxn.cursor()
    sql = "select * from dbo.VIEWER_GW_HEADS_VW where LOCATION_DBK = {}".format(
        location
    )
    data = pandas.read_sql(sql, cnxn)
    # logging.info("Connection to database is successful")
    return data


def heads_plot(location):
    data = sql_connect(location)
    color_dict = {
        "01": "#a1dab4",
        "02": "#bebada",
        "03": "#fb8072",
        "04": "#80b1d3",
        "05": "#fdbf6f",
        "06": "#469990",
        "07": "#fccde5",
        "08": "#c0bb8f",
        "09": "#a6cee3",
        "010": "#ccebc5",
        "011": "#ffed6f",
        "012": "#f1dbb9",
        "013": "#24b5a1",
        "014": "#7591b0",
    }
    data["color"] = data["PIEZOMETER_NR"].map(color_dict)
    data_sources = data["DATA_SOURCE"].unique()
    data.sort_values("MONITOR_DATE", ascending=False, inplace=True)

    # bokeh plot
    title_plot = "Location:{}--Monitoring:{}--Data sources:{}(tip: click the legend to activate and deactivate piezometers)".format(
        data["LOCATION_NM"].iloc[0], data["MONITORINGPROGRAM"].iloc[0], data_sources
    )

    TOOLS = "save,pan,box_zoom,reset,wheel_zoom,hover"
    p = figure(
        title=title_plot,
        plot_height=500,
        x_axis_type="datetime",
        tools=TOOLS,
        plot_width=1200,
    )

    # "%Y-%m-%d %H:%M:%S"
    p.xaxis.formatter = DatetimeTickFormatter(
        seconds=["%Y-%m-%d"],
        minutes=["%Y-%m-%d"],
        hourmin=["%Y-%m-%d"],
        hours=["%Y-%m-%d"],
        days=["%Y-%m-%d"],
        months=["%Y-%m-%d"],
        years=["%Y-%m-%d"],
    )

    # ['LOCATION_NM', 'SURFACE_ELEVATION_CM_NAP', 'PIEZOMETER_NR', 'TOP_SCREEN_CM_NAP', 'BASE_SCREEN_CM_NAP', 'MONITOR_DATE', 'GW_LEVEL_CM_NAP', 'DATA_SOURCE', 'AQUIFER',
    # 'MONITORINGPROGRAM', 'TO_BE_REALISED', 'ID_DELTARES', 'ID_GEM_UTRECHT', 'LOCATION_DBK']
    p.xaxis.axis_label = "Monitoring date"
    p.yaxis.axis_label = "Ground water level"

    for piezometer, data in data.groupby("PIEZOMETER_NR"):  #
        source = ColumnDataSource(
            data
        )  # convert to ColumnDataSource which can handle legends
        # p.circle(x = data["MONITOR_DATE"].iloc[1], y = data["GW_LEVEL_CM_NAP"].iloc[1], size=0.00000001, color= "#ffffff", legend="Piezometer:")#workaround for legend title (very small dot added on the plot)
        p.line(
            source=source,
            x="MONITOR_DATE",
            y="GW_LEVEL_CM_NAP",
            legend="PIEZOMETER_NR",
            line_dash=[2, 1],
            line_color=data["color"].iloc[0],
            line_width=2.5,
            line_alpha=0.9,
            muted_color=data["color"].iloc[0],
            muted_alpha=0.2,
        )
        hover = HoverTool(
            tooltips=[
                ("MONITOR_DATE", "@MONITOR_DATE{%Y-%m-%d}"),
                ("MONITORINGPROGRAM", "@MONITORINGPROGRAM"),
                ("GW_LEVEL_CM_NAP", "@GW_LEVEL_CM_NAP"),
                ("TOP_SCREEN_CM_NAP", "@TOP_SCREEN_CM_NAP"),
                ("BASE_SCREEN_CM_NAP", "@BASE_SCREEN_CM_NAP"),
                ("DATA_SOURCE", "@DATA_SOURCE"),
                ("ID_DELTARES", "@ID_DELTARES"),
                ("ID_GEM_UTRECHT", "@ID_GEM_UTRECHT"),
            ],
            formatters={"MONITOR_DATE": "datetime"},
        )
        p.add_tools(hover)
        p.legend.click_policy = "mute"
    return p


# if __name__ == "__main__":
#         location = 7479807
#         plot = heads_plot(location)
#         #tempdir = r"C:\Users\angelova\OneDrive - Stichting Deltares\Desktop\A27\wps2\data\{}.html".format(location)
#         #output_file(tempdir)
#         #save(plot)
#         show(plot)
