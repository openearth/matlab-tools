# -*- coding: utf-8 -*-
"""
Created on Sat Jun 23 08:59:48 2018

@author: hendrik_gt
"""
import os
import json
import logging
from bokeh_plots import *

import os
os.environ["NUMBER_OF_PROCESSORS"] = "2"

import sqlfunctions as sf
fc = r'c:\pywps\processes\pgconnection.txt'
credentials = sf.get_credentials(fc)

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
    tit = 'cumulatieve deformatie voor punt = {}'.format(locid)

    # Plot per column
    TOOLS = "pan,wheel_zoom,box_zoom,reset,save"
    p = figure(width=650, height=250, x_axis_type="datetime", title=tit, tools=TOOLS)
    p.xaxis.axis_label = 'Datum'
    p.yaxis.axis_label = 'Cumulatieve deformatie (mm)'
    p.line(x, y, color="darkblue")
    #p.circle(x=x, y=y, size=5, color="darkblue")
    
    # - Output HTML
    output_file(output_html, title="generated with bokeh_plot.py")
    save(p)

def getdata(PLOTS_DIR, APACHE_DIR,location,):
    strSql = """with aloc as (
                    select locid,st_distance(geometry,st_transform(st_setsrid(st_point({x},{y}),3857),28992)) as distance
                    from insarlocations
                    order by distance
                    limit 1)
                select 
                date,value,name from insarvalues where locid = (select locid from aloc)
                order by date
    """.format(x=json.loads(location)['x'],y=json.loads(location)['y'])
    
    a = sf.executesqlfetch(strSql,credentials)
    tmpfile = tempfile(PLOTS_DIR)
    logging.info(tmpfile)
    plot_Tseries(a,tmpfile,a[0][2])
    return os.path.join(''.join(['http://',APACHE_DIR]),os.path.basename(tmpfile))
