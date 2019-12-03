# -*- coding: utf-8 -*-
"""
Created on Tue Sep 23 15:24:15 2014
@author: hendrik_gt

http://naivasha.openearth.eu/thredds/wms/opendap/head/head_20100101_l1.nc?service=WMS&request=GetMap&version=1.3.0&layers=Band1&crs=EPSG%3A4326&bbox=-0.936645167488,36.0555086165,-0.467574442414,36.5939045735&width=800&height=600&styles=boxfill/redblue&format=image/png

Repository information:
Date of last commit:    $Date: 2015-04-08 22:18:09 -0700 (Wed, 08 Apr 2015) $
Revision of last commi: $Revision: 11861 $
Author of last commit:  $Author: hendrik_gt $
URL of source:          $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/naivasha/waterinformation.py $
CodeID:                 $ID$

"""
import logging
import numpy as np

cf = r'C:\pywps\pywps_processes\naivasha\pgconnection.txt'
#cf = r'C:\pywps_processes\naivasha\pgconnection_local.txt'
url = 'http://naivasha.openearth.eu/thredds/catalog/opendap'
ncparameter = 'head'
url = 'http:\\naivasha.openearth.eu\thredds\catalog\opendap'

def credentials():
    cr = get_credentials(cf)
    return cr    

def get_credentials(credentialfile,dbase=None):
    fdbp = open(credentialfile,'rb')
    credentials = {}
    if dbase != None:
        credentials['dbname'] = dbase
    for i in fdbp:
        item = i.split('=')
        if str.strip(item[0]) == 'dbname':
            if dbase == None:
                credentials['dbname'] = str.strip(item[1])
        if str.strip(item[0]) == 'uname':
            credentials['user'] = str.strip(item[1])
        if str.strip(item[0]) == 'pwd':
            credentials['password'] = str.strip(item[1])
        if str.strip(item[0]) == 'host':
            credentials['host'] = str.strip(item[1])
    return credentials

def executesqlfetch(strSql,credentials):
    import psycopg2
    conn = psycopg2.connect("dbname={dbname} host={host} user={user} password={password}".format(**credentials))
    cur = conn.cursor()
    try:
        cur.execute(strSql)
        p = cur.fetchall()
        return p
    except Exception,e:
        print e.message
    finally:
        cur.close()
        conn.close()

def getparameters():
    import json
    import StringIO
    credentials = get_credentials(cf)
    strSql = """
    select distinct id,name 
    from fews.parameterstable tsv
    join fews.timeserieskeys ts on ts.parameterkey = tsv.parameterkey"""
    a = executesqlfetch(strSql,credentials)
    io = StringIO.StringIO()
    json.dump(a, io)
    io.seek(0)
    return io

def getlocation(parameterid):
    import json
    import StringIO
    from pandas import DataFrame as adf
    credentials = get_credentials(cf)
    strSql = """select distinct st_srid(wgs_geom) as srid,st_x(wgs_geom),st_y(wgs_geom), l.id,l.name
        FROM fews.locations As l 
        join fews.timeserieskeys t on t.locationkey = l.locationkey
        join fews.parameterstable p on p.parameterkey = t.parameterkey
        --join fews.timeseriesvaluesandflags ts on ts.serieskey = t.serieskey
        where p.id = '{pid}' """.format(pid=parameterid)
#        where p.id = '{pid}' and to_char(datetime,'YYYY-MM-DD') BETWEEN '{sd}' and '{ed}'""".format(pid=parameterid,sd=sdate,ed=edate)
        
    product = False
    try:
        a = executesqlfetch(strSql,credentials)
        df = adf(a,columns=['srid','x','y','lid','lname'])
        
        geos = []
        for i in range(len(df)):
                pnt = {'geometry':{
                'type': 'Point',
                'coordinates': [df['x'][i],df['y'][i]]        
                },'type': 'Feature',
                         'properties':{'id':df['lid'][i],'name':df['lname'][i]}}
                geos.append(pnt)
        
        geometries = {
            'EPSG' : str(df['srid'][0]),
            'type': 'FeatureCollection',
            'features': (geos)}
        logging.info('succesfully retrieved data')
        logging.info(''.join(['number of observations ',str(len(a))]))
        io = StringIO.StringIO()
        json.dump(geometries, io)
        io.seek(0)
        product = io
    except Exception,e:
        logging.info('error occurred')
        logging.info(e.message)
    finally:
        return product


def gettimeseries(parameterid,locationid,sdate,edate,wps=True):
    import json
    import StringIO
    logging.info('requesting timeseries for paramter {p}, for location {id}, between {s}, {e}'.format(p=parameterid,id=locationid,s=sdate,e=edate))
    credentials = get_credentials(cf)
    strSql = """select 
                to_char(datetime,'YYYY-MM-DD HH24:mi:ss')
                , p.name
                , scalarvalue
                , pt.displayunit
                , st_x(l.wgs_geom)
                , st_y(l.wgs_geom)
                , l.id
                from fews.locations l
                join fews.timeserieskeys t on t.locationkey = l.locationkey
                join fews.parameterstable p on p.parameterkey = t.parameterkey
                join fews.timeseriesvaluesandflags ts on ts.serieskey = t.serieskey
                join fews.parametergroups pt on pt.groupkey = p.groupkey
                where p.id = '{pid}' and l.id = '{lid}' and to_char(datetime,'YYYY-MM-DD') BETWEEN '{sd}' and '{ed}' """.format(pid=parameterid,lid=locationid,sd=sdate,ed=edate)
    product = False
    try:
        a = executesqlfetch(strSql,credentials)
        logging.info('succesfully retrieved data')
        logging.info(''.join(['number of observations ',str(len(a))]))
        if wps:
            io = StringIO.StringIO()
            json.dump(a, io)
            io.seek(0)
            product = io
        else:
            product = a
    except Exception,e:
        logging.info('error occurred')
        logging.info(e.message)
    finally:
        return product

# url = base URL of the highest level of 'http://naivasha.openearth.eu/thredds/catalog/opendap'
def gettsfromnc(parameter,url,lon,lat,sdate,edate,wps=True):
    import os
    import StringIO
    import pandas
    product = False
    try:
        if not os.path.isdir(url):
            from naivasha.opendap import catalog
            catalogurl = ''.join([url,'/',parameter,'/','catalog.xml'])
            logging.info(catalogurl)
            urls = list(catalog.getchildren(catalogurl))
        else:
            urls=[]
            import glob
            for nc in glob.glob(os.path.join(url,parameter, '*.nc')):
                urls.append(nc)
        # since the nc's are considered to be of equal dimensions get dimensions of first array
        data = get_arrays(urls[0])
        arrlon = np.sort(data['lon'])
        arrlat = np.sort(data['lat'])
        indices = []
        
        # find indices using closest
        ilon = find_closest(arrlon,lon)
        ilat = find_closest(arrlat,lat)
        indices.append((ilat,ilon))
        data = get_datafromurls(urls,indices,sdate,edate)       # dictionary
        df = pandas.DataFrame(data)
        
        if wps:
            io = StringIO.StringIO()
            df.to_json(io)
            io.seek(0)
            product = io    
        else:
            product = df
    except Exception,e:
        logging.info(e.message)
    finally:
        return product
        


""" 
mergetsdf merges dataframes from timeseries to one dataframe based on dates
"""
def mergetsdf(parameterid,locationid,sdate,edate,url,ncparameter='head',wps=True):
    import io
    import pandas
    logging.info('parameterid '+parameterid)
    logging.info('locationid ',locationid)
    logging.info(''.join(['sdate',sdate]))
    logging.info(''.join(['edate',edate]))
    logging.info(''.join(['url',url]))
    logging.info(''.join(['ncparameter',ncparameter]))
    
    
    # database part
    a = gettimeseries(parameterid,locationid,sdate,edate,wps=False)
    columns = ['date','parameter','extraction','unit','lon','lat','pid']
    df = pandas.DataFrame(a,columns = columns)
    lon = a[0][4]
    lat = a[0][5]
    mindate = a[0][0]
    maxdate = a[len(a)-1][0]    
    parameter = a[0][1]
    unit = a[0][3]
    print lon,lat,mindate,maxdate,unit
    # Do some cleaning of the dataframe
    df = df.drop('pid',1)
    df = df.drop('lat',1)
    df = df.drop('lon',1)
    df = df.drop('unit',1)
    df = df.drop('parameter',1)
    
    # get timeseries from netCDF's
    dfnc = gettsfromnc(ncparameter,url,lon,lat,mindate.split()[0],maxdate.split()[0],False)
    print 'nc bepaling'
    
    # merge the dataframes to a new 
    mergeddf = pandas.merge(dfnc,df,on='date')
    
    mdf = pandas.ordered_merge(dfnc, df, left_on = 'date', right_on = 'date',fill_method='ffill', left_by='date')
    #fjson = r'd:\temp\test.sjon'
    fjson = io.BytesIO()
    mergeddf.to_json(fjson)
    fjson.seek(0)
    return fjson,[locationid,unit,ncparameter]    


def get_datafromurls(urls,indices,sdate,edate):
    import os
    #from datetime import datetime
    import netCDF4
    import time
    sdt = time.strptime(sdate, "%Y-%m-%d")   
    edt = time.strptime(edate, "%Y-%m-%d")   
    values = {'date':[],'mvalue':[]}
    for nc in urls:
        logging.info(''.join(['getting data from ', nc]))
        #adate = datetime.strptime(os.path.basename(nc).split('_')[1],'%Y%M%d').isoformat().replace('T',' ')
        adate = os.path.basename(nc).split('_')[1]
        adt = time.strptime(adate, "%Y%m%d")   
        if adt >= sdt and adt <= edt:
            adate = ''.join([adate[:4],'-',adate[4:6],'-',adate[6:],' 00:00:00'])
            #datetime.strptime(os.path.basename(nc).split('_')[1],'%Y%M%d')
            dataset = netCDF4.Dataset(nc)
            value = dataset.variables["Band1"][indices[0]]
            dataset.close()
            values['date'].append(adate)
            values['mvalue'].append(value)
    return values        

def get_arrays(url):
    #print url
    import netCDF4
    dataset = netCDF4.Dataset(url,)
    #date = datetime.strptime(os.path.basename(nc).split('_')[1],'%Y%M%d')
    #times =  netcdftime.num2date(dataset.variables['time'][:], dataset.variables['time'].units)
    #conc = dataset.variables["Band1"][:]
    # lookup space for the first dataset
    lon = dataset.variables["lon"][:]
    lat = dataset.variables["lat"][:]
    dataset.close()
    return {'lat': lat, 'lon': lon}

"""http://stackoverflow.com/questions/8914491/finding-the-nearest-value-and-return-the-index-of-array-in-python"""
def find_closest(A, target):
    #A must be sorted
    idx = A.searchsorted(target)
    idx = np.clip(idx, 1, len(A)-1)
    left = A[idx-1]
    right = A[idx]
    idx -= target - left < right - target
    return idx