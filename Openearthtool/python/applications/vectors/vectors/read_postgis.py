# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <codecell>

import psycopg2
import pandas
from shapely.geometry import Polygon
import shapely.wkt
from psycopg2.extensions import adapt
# <codecell>

def get_credentials():
    """public postgis access"""
    # TODO: move these to configuration (development/production)
    credentials = {}
    credentials['user'] = 'dbices'
    credentials['password'] = 'vectors'
    credentials['host'] = 'postgresx03.infra.xtr.deltares.nl'
    credentials['dbname'] = 'ICES'
    return credentials

#    credentials = {}
#    credentials['user'] = 'postgres'
#    credentials['password'] = 'ghn'
#    credentials['host'] = 'localhost'
#    credentials['dbname'] = 'ICES'
#    return credentials

# TODO, we don't want to open connections here....
# See pyramid manual for database connections
# generic function that returns a dataframe of the SQL string passed
def executesqlfetch(credentials, sql, *args):
    """get a pandas dataframe from a sql"""
    conn = psycopg2.connect("dbname={dbname} host={host} user={user} password={password}".format(**credentials))
    cur = conn.cursor()
    try:
        if args:
            cur.execute(sql, (args))
        else:
            cur.execute(sql)
        rs = cur.fetchall()
        if rs:
            df = pandas.DataFrame(rs)
            df.columns = [x[0] for x in cur.description]
        else:
            df = pandas.DataFrame(columns=[x[0] for x in cur.description])
        return df
    finally:
        conn.close()


def get_ices_polygon(statsq="34F2"):
    """
    get boundary box for icessquare
    """
    # set credentials
    credentials = get_credentials()
    
    # create sql string using variable
    sql = """
    select ST_AsEWKT(the_geom) as wkt from
    icessquares where statsq = (%s)
    """
    # code below works only for one polygon
    df = executesqlfetch(credentials,sql,statsq)
    apoly = shapely.wkt.loads(df['wkt'][0].split(';')[1])
    
    #test (2.0, 52.5, 3.0, 53.0)
    return apoly

def get_unique_points():
    # set credentials
    credentials = get_credentials()

    sql ="""
    select distinct on (statsq) st_x(the_geom),st_y(the_geom),statsq
    from unique_locations;
    """
    #df = pandas.io.sql.read_frame(sql,conn)
    df = executesqlfetch(credentials,sql)
    return df


def get_ices_squares():
    # set credentials
    credentials = get_credentials()
    sql ="""
    select st_askml(the_geom),box2d(the_geom),statsq
    from icessquares
    where sea_region similar to ('North Sea%');
    """
    df = executesqlfetch(credentials,sql)
    return df

def get_points_in_ices(statsq='32F3'):
    """returns unique number of observations for a specific ICES square statsq identification number"""
    # set credentials
    credentials = get_credentials()

    strsql = """
    select 
      platform,
      station, 
      st_astext(st_union(the_point)) as collect 
    from
      ocean where statsq = (%s)
    group by platform, station
    """

    df = executesqlfetch(credentials,strsql,statsq)
    return df
    #cur.execute(strsql, vars=[statsq])
    #df2 = pandas.DataFrame(cur.fetchall())
    #df2.columns = [rec[0] for rec in cur.description]

def query_ices(aspecies,statsq):
    """
    get the time series of the species within the ICES square
    using a lookup table for the right species name (species in nc are named different than the species name in de postgis database)
    the dictionary below gives the species from the nc as key and the value as species from the database
    atomich weights from http://www.chem.qmul.ac.uk/iupac/AtWt/
    Delwaq name     Unit        ConvertTo	ByMultiplyingWith	Reverse
    NH4             (gN/m3)     (mu-mol/l)	71.425			0.0140
    NO3             (gN/m3)     (mu-mol/l)	71.425			0.0140
    PO4             (gP/m3)     (mu-mol/l)	32.285			0.0310
    Si              (gSi/m3)    (mu-mol/l)	35.606			0.0281
    ExtVl           (1/m)       
    Temp            (°C)        
    Phyt            (gC/m3)     
    Chlfa           (mg/m3)     
    
    Depth integrat
    fPPtot          (gC/m2/d)   
    Chlfa           (mg/m2)     
    """
    dictaltspecs={'PO4':['phos','0.0310'],
                  'NO3':['ntra','0.0140'],
                  'NO2':['ntri','0.0140'],
                  'Si' :['slca','0.0281'],
                  'NH4':['amon','0.0140'],
                  'Chlfa':['cphl','1']}
    
    afactor = dictaltspecs[aspecies][1]
    aspecies = dictaltspecs[aspecies][0]
    credentials = get_credentials()
    #print 'pg query',aspecies,statsq
    assert aspecies in ('phos', 'amon','ntra','ntri','cphl','slca')
    
    sql = """
    select 
      to_date(to_char(year,'9999')||'-'||to_char(month,'00'),'YYYY-MM') as date,
      year, 
      avg({species})*{factor} as avg,
      stddev_samp({species})*{factor} as stddev
    from ocean
    where sdepth < 30 and statsq = (%s)
    group by date,year
    having avg({species}) > 0 and year > 2002
    order by date,year
    """.format(species=aspecies,factor=afactor)
    df = executesqlfetch(credentials,sql,statsq)
    return df

    #where sdepth < 30 and statsq = '"""+statsq+"""'
    #having avg("""+aspecies+""") > 0 and year > 2002
