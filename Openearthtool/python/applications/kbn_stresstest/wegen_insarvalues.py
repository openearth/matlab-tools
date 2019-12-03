# -*- coding: utf-8 -*-
"""
Created on Sat Jun 23 08:59:48 2018

@author: hendrik_gt
"""
import os
from bokeh_plots import *

import sqlfunctions as sf

def tempfile(tempdir, typen='plot', extension='.html'):
    import time
    fname = typen + str(time.time()).replace('.','')
    return os.path.join(tempdir, fname+extension)

def plot_Tseries(data,output_html,locid):
    # Data preparation
    x=[]
    for t in data: x.append(t[0])
    y=[]
    for d in data: y.append(d[1])
    tit = 'Time series for location with ID = {}'.format(locid)

    # Plot per column
    TOOLS = "pan,wheel_zoom,box_zoom,reset,save"
    p = figure(width=650, height=250, x_axis_type="datetime", title=tit, tools=TOOLS)
    p.xaxis.axis_label = 'Datum'
    p.yaxis.axis_label = 'Cumulative deformatie (mm)'
    p.line(x, y, color="darkblue")
    #p.circle(x=x, y=y, size=5, color="darkblue")
    
    # - Output HTML
    output_file(output_html, title="generated with bokeh_plot.py")
    save(p)

# some globals
PLOTS_DIR = r'd:\temp\wegen'

fc = r'D:\projecten\datamanagement\Nederland\wegen\credentials.txt'

credentials = sf.get_credentials(fc)

id = 'L334360P12850'
strSql = """select date,value from insarvalues v
join insarlocations l on l.locid = v.locid
where l.name = '{id}'
order by date
""".format(id=id)

a = sf.executesqlfetch(strSql,credentials)

tmpfile = tempfile(PLOTS_DIR)

plot_Tseries(a,tmpfile,id)
