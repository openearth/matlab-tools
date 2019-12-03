# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
#       Joan Sala
#
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

# $Id: coords.py 13711 2017-09-13 14:52:48Z sala $
# $Date: 2017-09-13 16:52:48 +0200 (Wed, 13 Sep 2017) $
# $Author: sala $
# $Revision: 13711 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/blue2/utils.py $
# $Keywords: $

import collections
import os
import logging
import ConfigParser
import time
import datetime
from osgeo import ogr
from sqlalchemy import create_engine
import numpy as np
import pandas as pd
import re
import json

from coords import change_coords

# Get a unique temporary file
def TempFile(tempdir, typen='plot', extension='.html'):
    fname = typen + str(time.time()).replace('.','')
    return os.path.join(tempdir, fname+extension)

# Read default configuration from file
def readConfig():
	# Default config file (relative path)
	cfile=os.path.join(os.path.dirname(os.path.realpath(__file__)), 'blue2_config.txt')
	cf = ConfigParser.RawConfigParser()  
	cf.read(cfile)
	return cf

# Read naming conventions for scenarios and variables
def readNaming(schema):
    f=open(os.path.join(os.path.dirname(os.path.realpath(__file__)), 'blue2_naming.json'))
    data = json.load(f)
    scenarios = data[schema]['scenarios']
    divisions = data[schema]['divisions']
    variables = data[schema]['variables']
    epsg = data[schema]['epsg']
    sld_style = data[schema]['sld_style']
    thr_map = data[schema]['thresholds_mapping']
    return scenarios, divisions, variables, epsg, sld_style, thr_map

# Read valid timespans for scenario comparison
def readNamingTimeperiods(schema):
    f=open(os.path.join(os.path.dirname(os.path.realpath(__file__)), 'blue2_naming.json'))
    data = json.load(f)
    times = data[schema]['timeperiods']
    return times

# Alter table [scenario import]
def updateGeometries(enginetemp, table, dtable, dtableId, tableId='index', geomschema='division'):    
	# Add new column to temporary table
	sql = """ALTER TABLE {tempschema}."{t}" ADD {c} {d};
	         WITH geomvalues as (select geom, {idgeomtable} from {gschema}."{geomtable}" t1)
             UPDATE {tempschema}."{t}" as t1
             SET geom = nv.geom
             FROM geomvalues nv
             WHERE nv.{idgeomtable} = t1.{idtable};""".format(c='geom', t=table, d='geometry(MultiPolygon)', 
             	gschema=geomschema, geomtable=dtable, idgeomtable=dtableId, idtable=tableId, tempschema='tempresults') 

	enginetemp.execute(sql)
	
# Get coverage for Green model
def getCostsMS(cf, div='nuts0', sc='public'):
    # DB connections
    engine = create_engine('postgresql+psycopg2://'+cf.get('PostGIS', 'user')
        +':'+cf.get('PostGIS', 'pass')+'@'+cf.get('PostGIS', 'host')+':'+str(cf.get('PostGIS', 'port'))
        +'/'+cf.get('PostGIS', 'db_thresholds'), strategy='threadlocal')

    # Perform sql query
    sqlStr = 'select nuts_id, cost_bau, cost_mtf from {}."{}"'.format(sc, div)            
    res = engine.execute(sqlStr)     

    d = dict()
    for r in res: 
        # Identifier
        d[r[0]] = { 'cost_bau': r[1], 'cost_mtf': r[2] }

    return d

# Select a time period
def selectTimePeriod(t0, t1, header):
    # Dates parse
    try:
        tt0=t0.split('-')
        tt1=t1.split('-')
        y0, y1, m0, m1 = int(tt0[0]), int(tt1[0]), int(tt0[1]), int(tt1[1])
    except Exception:
        raise ValueError('Please enter dates in the right format YYYY-MM (year-month)')

    # Get dates indexs [year and month]
    i = 0        
    idx0 = None
    idxn = None # -index [-2+1]
    for h in header:
        nums = re.findall(r'\d+', h)
        if len(nums):
            if y0 == int(nums[0]) and m0 == int(nums[1]):
                idx0 = i+1 # offset index
            if y1 == int(nums[0]) and m1 == int(nums[1]):
                idxn = i+1 # offset index
            i+=1

    logging.info('----------------')
    logging.info('date = {} -> index = {}'.format(t0, idx0))
    logging.info('date = {} -> index = {}'.format(t1, idxn))
    logging.info('----------------')

    # Did we find the data
    if idx0 is None or idxn is None:
        st0 = re.findall(r'\d+', header[1])
        stn = re.findall(r'\d+', header[-1])
        raise ValueError('No results for the selected time period. Available data for this scenario: {} to {}'.format('-'.join(st0[0:2]), '-'.join(stn[0:2])))

    # At least a month selected
    if idx0 == idxn: 
        idxn = idx0 + 1   
    return idx0, idxn

# Calculate a layer, save it to PostGIS
def calculateLayer(cf, df_thr, tablein, outname, division, division_id, schema, t0, t1, ot, timeseries=True):
    # DB connections
    engine = create_engine('postgresql+psycopg2://'+cf.get('PostGIS', 'user')
        +':'+cf.get('PostGIS', 'pass')+'@'+cf.get('PostGIS', 'host')+':'+str(cf.get('PostGIS', 'port'))
        +'/'+cf.get('PostGIS', 'db_results'), strategy='threadlocal')
    engine_temp = create_engine('postgresql+psycopg2://'+cf.get('PostGIS', 'user')
        +':'+cf.get('PostGIS', 'pass')+'@'+cf.get('PostGIS', 'host')+':'+str(cf.get('PostGIS', 'port'))
        +'/'+cf.get('PostGIS', 'db_temp'), strategy='threadlocal')

    # Get DATA - Perform sql query
    sqlStr = 'select * from {}."{}"'.format(schema, tablein)       
    if not timeseries: sqlStr += ' where {} is NOT NULL'.format(outname)
    logging.info(sqlStr)  
    try:   
        res = engine.execute(sqlStr)
        header = res.keys()      
    except:
        raise ValueError('Information not available for the current selection')

    # Time series or single value
    if timeseries:
        # Find valid indexes for the tseries data
        idx0, idxn = selectTimePeriod(t0, t1, header)       
        
    # Extract values  
    df = pd.DataFrame(columns=[outname])
    if 'thresholds' in ot:      
        df = pd.DataFrame(columns=[outname, 'status'])
    for r in res:    
        # Identifier         
        iden = r[0]  
        # Values
        if len(r) > 2:                                 
            val = np.asarray(r[idx0:idxn]).mean() # mean of dates
        else:
            val = r[1]            
        # Calculate status
        thr = 0
        if 'threshold' in ot:
            thr = df_thr.loc[iden]['threshold']        
            if float(thr) > 0: 
                st = float(val)/float(thr)
            else:
                st = 0
            df.loc[iden] = pd.Series({outname: val, 'status': st})
        else:
            df.loc[iden] = pd.Series({outname: val})
    
    # Write database
    if 'thresholds' in ot:  
        tag = 'thr'
    elif 'results' in ot:
        tag = 'res'
    else:
        tag = 'cost'
    tmptable = 'calc_{}'.format(str(time.time()).replace('.',''))
    df.to_sql(name=tmptable, con=engine_temp, schema='tempresults', if_exists='replace')

    # Add geometry column
    updateGeometries(engine_temp, tmptable, division, division_id)

    return tmptable, df

# Calculate a layer, save it to PostGIS
def getTimeSeries(sel_id, cf, df_thr, tablein, outname, division, division_id, schema, t0, t1, ot):
    # DB connections
    engine = create_engine('postgresql+psycopg2://'+cf.get('PostGIS', 'user')
        +':'+cf.get('PostGIS', 'pass')+'@'+cf.get('PostGIS', 'host')+':'+str(cf.get('PostGIS', 'port'))
        +'/'+cf.get('PostGIS', 'db_results'), strategy='threadlocal')

    # Perform sql query
    sqlStr = 'select * from {}."{}" where {} = \'{}\''.format(schema, tablein, 'id', sel_id)     
    logging.info(sqlStr)       
    res = engine.execute(sqlStr)
    header = res.keys()        

    # Find valid indexes for the tseries data
    idx0, idxn = selectTimePeriod(t0, t1, header)  

    # X axis build
    time=[]
    for h in header[idx0:idxn]:
        nums = re.findall(r'\d+', h)                
        time.append(datetime.datetime.strptime('{}-{}'.format(nums[0], nums[1]), '%Y-%m'))    

    # Y axis build
    data = dict()
    for r in res:
        if 'thresholds' in ot:  
            # Calculate status
            thr = df_thr.loc[r[0]]['threshold']            
            data[r[0]] = []
            # For all the columns [time-series]            
            for v in r[idx0:idxn]:
                try:
                    data[r[0]].append(float(v) / float(thr))
                except:
                    data[r[0]].append(0.0)
        elif 'results' in ot:
            # Just value
            data[r[0]] = r[idx0:idxn]

    return time, data

def compareScenarios(cf, df1, df2, previewtype, division, division_id, col1, col2):
    # DB connection
    engine_temp = create_engine('postgresql+psycopg2://'+cf.get('PostGIS', 'user')
        +':'+cf.get('PostGIS', 'pass')+'@'+cf.get('PostGIS', 'host')+':'+str(cf.get('PostGIS', 'port'))
        +'/'+cf.get('PostGIS', 'db_temp'), strategy='threadlocal')

    # Iterate and compare    
    colname=df1.columns[0]
    df = pd.DataFrame(columns=[colname+'_ref', colname+'_sec', 'parameter_difference', 'relative_increment', 'cost_effectiveness'])
    
    # Costs per Member State
    costs = getCostsMS(cf)
    
    for index, row1 in df1.iterrows():
        row2 = df2.loc[index]
               
        # Difference[-]
        d = row1[colname]-row2[colname]
        
        # Increment[%]
        try:
            p = 100.0 * float(d)/float(row1[colname])
        except:
            p = 0.0 # division by zero

        # Cost[conc/Meuro] 
        try: 
            c1 = float(costs[index][col1]) / 1000000.0
            c2 = float(costs[index][col2]) / 1000000.0           
            c = float(d) / (float(c1) - float(c2))            
        except:
            c = 0.0 # division by zero

        df.loc[index] = pd.Series({colname+'_ref':row1[colname], colname+'_sec':row2[colname], 'parameter_difference': d, 'relative_increment': p, 'cost_effectiveness': c})

    # Write table to DB
    tmptable = 'compare_{}'.format(str(time.time()).replace('.',''))
    df.to_sql(name=tmptable, con=engine_temp, schema='tempresults', if_exists='replace')

    # Add geometry column
    updateGeometries(engine_temp, tmptable, division, division_id)  

    return tmptable, df

def getClosestDivision(cf, xin, yin, division, division_id, epsg, geomschema='division'):
    # DB connections
    engine_temp = create_engine('postgresql+psycopg2://'+cf.get('PostGIS', 'user')
        +':'+cf.get('PostGIS', 'pass')+'@'+cf.get('PostGIS', 'host')+':'+str(cf.get('PostGIS', 'port'))
        +'/'+cf.get('PostGIS', 'db_temp'), strategy='threadlocal')

    # Perform sql query
    sqlStr = """select {i}, ST_AsText(ST_Transform(geom, {eout})), ST_Distance(geom, 'SRID={e};POINT({x} {y})'::geometry) as dist from {s}."{t}" 
    			order by dist
    			limit 1""".format(s=geomschema, i=division_id, t=division, x=xin, y=yin, e=epsg, eout=3857)            
    logging.info(sqlStr)
    res = engine_temp.execute(sqlStr)
    iden = ''
    wkt = ''
    for r in res:  
    	iden = r[0]    
    	wkt = r[1]
    return iden, wkt

# Gives back an HTML summary table
def getHTMLSummary(df):

    html_str='<div class="scrollit"><table class=\"blueTable\">'
    html_str+='<thead><tr><th><p>Geographical division</p></th><th><p>Value</p></th></tr></thead>'        
    html_str+='<tbody>'

    for key, values in df.to_dict().iteritems():
    	od = collections.OrderedDict(sorted(values.items())) # alphabetical order
        for key, val in od.iteritems():            
            html_str+='<tr><td><p>{}</p></td><td><p class="greenok">{}</p></td></tr>'.format(key, val)
                
    html_str+='</tbody></table></div>'	

    return html_str
