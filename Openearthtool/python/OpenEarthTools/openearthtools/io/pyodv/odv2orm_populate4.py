"""
Populate RDBMS with odvfile collection
"""
#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2014 - 2019 Deltares for EMODnet Chemistry
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

# $Id: odv2orm_populate3.py 15306 2019-04-01 13:24:10Z hendrik_gt $
# $Date: 2019-04-01 15:24:10 +0200 (ma, 01 apr 2019) $
# $Author: hendrik_gt $
# $Revision: 15306 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/pyodv/odv2orm_populate3.py $
# $Keywords: $


""" for older versions of postgresql it is necessary to add sequences manually
create sequence cdi_id_seq
alter table cdi alter column id set default nextval('cdi_id_seq')

create sequence odvfile_id_seq
alter table odvfile alter column id DEFAULT nextval('odvfile_id_seq'::regclass)

"""

   
import hashlib
#http://stackoverflow.com/questions/3431825/generating-a-md5-checksum-of-a-file
from odv2orm_model3 import *
import odvdir, pyodv, glob
import datetime, odvdatetime, pandas, numpy,os
import re
from sqlalchemy import create_engine
import sqlfunctions
from sqlalchemy.orm import sessionmaker

# necessary function to find the correct columnname
# due to some aggreeement (2014-12)
def findcolumn(F,columnname):
    acolumn = ''.join(['_',columnname])
    columns = [columnname]
    try:
        ac = F.data.columns[F.odv_column.index(acolumn)]
        columns.append(ac)
    except Exception:
        print 'message: column',acolumn,'not found'
    return columns

def findcolumn2(F,columnname):
    columns = [columnname,''.join(['_',columnname])]
    for c in columns:
        try:
            F.odv_column.index(c)
        except Exception:
            columns.remove(c)
    return columns


def hashfile(fname, blocksize=65536):
    hasher = hashlib.sha256()  
    f = open(fname, 'rb')
    buf = f.read(blocksize)
    while len(buf) > 0:
        hasher.update(buf)
        buf = f.read(blocksize)
    return hasher.digest()


## add unique odv files
# returns the ID that belongs to this ODV File (is most safest way I think)
# TODO in stead of a file for each CDI the enriched ODV's host several cdi's per file
# TODO, first add a ODV file and connect to each cdi that particular id
def populateODVfile(filename):
    session.rollback()
    FileName         = os.path.basename(filename) # excl. path
    FileSize         = os.stat(filename).st_size
    FileLastModified = datetime.datetime.utcfromtimestamp(os.stat(filename).st_mtime)
    Sha256Hash       = hashfile(filename)
    # check unique constraints
    exist1           = session.query(Odvfile).filter_by(name=FileName).first()
    exist2           = session.query(Odvfile).filter_by(sha256hash=Sha256Hash).first()
    rid              = False
    if exist1==None and exist2==None:
        try:
            element = Odvfile(name=FileName,
                          sha256hash=Sha256Hash,
                          lastmodified=FileLastModified,
                          entrydate=datetime.datetime.now(),
                          version=1,
                          size=FileSize)
            session.add(element)
            session.commit()
            rid = element.id
        except:
            print('Error inserting (despite name and sha256hash being unique) %s%s' % (filename, exist1.id))
    else:
        if exist1 != None:
            rid = exist1.id
        else:
            rid = exist2.id
        msg = ''.join(['Message: ODVfile %s' % filename,'already present, id %s' % rid, ' returned'])
        print msg
    #get the id of this instance and return it
    return rid

## checks whether a string is an int, if so, converts it to an int and returns as a string
def is_int(s):
    try:
        if int(s):
            return str(int(s))
        if float(s):
            return str(int(s))
    except ValueError:
        return str(s)

#checks whether a string is a float, if so returns a float object, due to history records 
#in some cases the variable longitude was read as a string
def is_float(s):
    r = False
    try:
        r = float(s)
    except Exception:
        print Exception.message
    finally:
        return r

def refresh_observedindex(session,fid):
    session.rollback()
    strSql = """
    INSERT INTO observed_cindex (id,geom,cdi,edmo,istimeseries,p35_id,p35,origin,p36_id,p36,datetime,unit,unitdescription,quality,qualitydescription,depth,z,colorindex,minindx,maxindx) as
     SELECT o.id, 
    o.geom, 
    cdi.local_cdi_id as cdi,
    edmo.code as edmo, 
    cdi.istimeseries, 
    p.identifier AS p35_id, 
    p.preflabel AS p35, 
    p.origin, 
    p36.id AS p36_id, 
    p36.preflabel AS p36, 
    o.datetime, 
    p06.altlabel AS unit, 
    p06.preflabel AS unitdescription, 
    l20.identifier AS quality, 
    l20.preflabel AS qualitydescription, 
    o.depth, 
    o.z, 
    ((3 * 256)::double precision * (o.value - c.min) / (c.max - c.min))::integer AS colorindex, 
    c.min::integer AS minindx, 
    c.max::integer AS maxindx
       FROM observation o
       JOIN cdi ON cdi.id = o.cdi_id
       join edmo on edmo.id = cdi.edmo_code_id
       JOIN parameter p ON p.id = o.parameter_id
       JOIN p06 ON p06.id = o.p06_id
       JOIN l20 ON l20.id = o.flag_id
       JOIN parameter_colorvalues c ON c.parameter_id = o.parameter_id
       JOIN p36 ON p36.id = p.p36_id
      WHERE o.value <> 'NaN'::double precision AND (l20.identifier::text = ANY (ARRAY['1'::text, '2'::text, '6'::text]))
      AND o.odvfile_id = {f};
    """.format(f=fid)
    session.execute(strSql)
    session.commit()




def getcolindex(lstcsvcols,ODV):
    lstcols = []
    for c in lstcsvcols:
        lstcols.append(ODV.pandas_name.index(c))
    return lstcols
    
def createlstcolnames(ODV):
    lstcols = []
    for ci in ODV.usecolindices:
        if ODV.sdn_name[ci].find('::') > 0:
            pname = ODV.sdn_name[ci].split('::')[1]
            nxtcol = '_'.join(['qv',pname])
            lstcols.append(pname)
            lstcols.append(nxtcol)
        else:
            lstcols.append(ODV.sdn_name[ci])
        
def appendlstusedindices(ODV):
    ODV.usecolindices = []
    lstcols = ['Longitude_[degrees_east]', 'Latitude_[degrees_north]','Longitude [degrees_east]', 'Latitude [degrees_north]',  'LOCAL_CDI_ID', 'EDMO_code','P01 Codes']
    #    if ODV.data_type == 'timeseries':
    #        if ODV.odv_column.index('_LOCAL_CDI_ID') <> 0:
    #            lstcols.append('_LOCAL_CDI_ID')
    #            ODV.usecolindices.append(ODV.odv_column.index('_LOCAL_CDI_ID'))
    #        if ODV.odv_column.index('_EDMO_code') <> 0:
    #            lstcols.append('_EDMO_code')
    #            ODV.usecolindices.append(ODV.odv_column.index('_EDMO_code'))
    #        
    for i in lstcols:
        if i == 'Longitude_[degrees_east]': dt = 'float32'
        if i == 'Latitude_[degrees_north]': dt = 'float32'
        if i == 'Longitude [degrees_east]': dt = 'float32'
        if i == 'Latitude [degrees_north]': dt = 'float32'
        if i == 'LOCAL_CDI_ID': dt = 'object'
        if i == 'EDMO_code' : dt = 'int64'
        if i == 'P01 Codes' : dt = 'string'
#        if i == 'P01_codes' : dt = 'string'

        print i
        
#        print i.replace(' ','_')
#        print '---test2'
        
        for j in ODV.pandas_name:
            k = i.replace(' ','_')      #workaround alleen geldig voor p01_codes
            if i == 'P01 Codes' and j == 'P01_Codes':
                ODV.usecolindices.append(ODV.pandas_name.index(k))
                print ODV.pandas_name.index(k)
            if i == j:
                ODV.usecolindices.append(ODV.pandas_name.index(j))
                #ODV.usecolindices[ODV.pandas_name.index(j)] = dt
                
    return lstcols
    print lstcols

def checkdf(ODV,col):
    return len(numpy.unique(ODV.data[col]))


def finddepthfield2(ODV):
    # get complete list of depth parameters from z table
    # return a list of depth columnnames
    dctdepth = {}
    strSql = """select identifier,p06_unit from z where identifier not similar to ('%MINCDIST|MAXCDIST|MINWDIST%')"""
    a = sqlfunctions.executesqlfetch(strSql,credentials)
    i = 0
    for f in ODV.sdn_name:
        if not f == '':
            for d in a:
                if f.find(d[0]) >= 0:
                    dctdepth[d[0]] = (ODV.odv_column[i],d[1])
        i = i + 1
    return dctdepth

   
def finddepthfield(ODV):
    # get complete list of depth parameters from z table
    strSql = """select identifier from z"""
    a = sqlfunctions.executesqlfetch(strSql,credentials)
    for f in ODV.sdn_name:
        for d in a:
            if f.find(d[0]) >= 0:
                return d[0]

def findtimefield(ODV):
    tf = False
    for f in ODV.sdn_name:
        if f.find('DTUT8601') >= 0:
            tf = True
    return tf

       
def loaddataintottable(ODV, file,credentials,eutro):
    'use work around for pandas to add data to schema'
        
    fid = populateODVfile(file)

    ODV.data = pandas.read_csv(af,sep='\t',names=ODV.pandas_name, na_values=numpy.nan,low_memory=False)

    df = ODV.data.ffill()
    


    # dictionary with basic fields
    # this could also be the answer for the columns to get in case of timeseries or profils
    dctbasefields = {}
    lstcols = ['LOCAL_CDI_ID', 'EDMO_code']
    for f in lstcols:
        try:
            dctbasefields[f] = ODV.odv_column.index(f)
        except:
            print("")
    
    # by default timefield is first time field found, except for timeseries
    if ODV.data_type == 'timeseries': 
        tfindx = ODV.odv_column.index('time_ISO8601')
        dctbasefields['time'] = tfindx
        tfld=ODV.pandas_name[tfindx]
    else:
        tfindx = ODV.odv_column.index('yyyy-mm-ddThh:mm:ss.sss')
        dctbasefields['time'] = ODV.odv_column.index('yyyy-mm-ddThh:mm:ss.sss')
        tfld = 'yyyy-mm-ddThh:mm:ss.sss'
    
    # in case of eutrofication
    if not eutro:
        lstcolumns = ['Cruise',
                      'Station',
                      tfld,
                      'column:QV:{localcdi}'.format(localcdi=dctbasefields['LOCAL_CDI_ID']-1),
                      'column:QV:{edmo}'.format(edmo=dctbasefields['EDMO_code']-1),
                      'Longitude_[degrees_east]',
                      'Latitude_[degrees_north]']
    else:
        lstcolumns = ['Cruise',
                      'Station',
                      tfld,
                      'LOCAL_CDI_ID',
                      'EDMO_code',
                      'Longitude_[degrees_east]',
                      'Latitude_[degrees_north]']


    # here we should assign a columnname if it is not found
    # for water this should be ADEPZZ01
    # for sediment this should be COREDIST
    # for biota no necesissity to have a column, but .. if there is one, why not use it
    dctdepth = finddepthfield2(ODV)
    if len(dctdepth) <> 1 and ODV.data_type != 'timeseries':
        if ODV.matrix == 'ocean':
            dfld = 'ADEPZZ01'
            dfldu = 'UPDB'
            lstcolumns.append(dfld)
            lstcolumns.append('QV:{d}'.format(d=dfld))
        elif ODV.matrix == 'sediment':
            dfld = 'COREDIST'
            dfldu = 'ULAA'
            lstcolumns.append(dfld)
            lstcolumns.append('QV:{d}'.format(d=dfld))
        elif ODV.matrix == 'biota':
            try:
                di = ODV.odv_column.index('Depth [m]')  #arbitrary choice!!!
                dfld = 'ADEPZZ01' #dctdepth.keys()[0]
                dfldu = 'UPDB'    #dctdepth[dfld][1]
            except:
                dfld = ''
                dfldu = ''
            finally:
                lstcolumns.append(df.columns[di])
                lstcolumns.append(df.columns[di+1])
    elif ODV.data_type == 'timeseries' and len(dctdepth) == 1:
        dfld = dctdepth.keys()[0]
        dfldu = dctdepth[dfld][1]
        try:
            di = ODV.odv_column.index(dfld)
        except:
            di = ODV.odv_column.index(dctdepth[dfld][0])
        lstcolumns.append(df.columns[di])
        lstcolumns.append(df.columns[di+1])
    else:
        dfld = dctdepth.keys()[0]
        dfldu = dctdepth[dfld][1]
        #di = ODV.odv_column.index(dfld)
        lstcolumns.append(dfld)
        lstcolumns.append('QV:{d}'.format(d=dfld))
        
    # find first column with data, this should either be the time column (in case of timeseries)
    # either be the depth column in case of profiles.
    # create complete list of indices with
    dctcolumns = {}
    nr = 1
    for i in range(len(ODV.sdn_name)):
        if ODV.sdn_name[i].find(dfld) <> -1:
            nr = 2
        if ODV.sdn_name[i] != '':
            try:
                dctcolumns[i] = (ODV.sdn_name[i].split('SDN:P01::')[1], ODV.sdn_units[i].split('SDN:P06::')[1].split('|')[0],nr)
                nr = 1
            except:
                dctcolumns[i] = (ODV.sdn_name[i].split('SDN:P35::')[1], ODV.sdn_units[i].split('SDN:P06::')[1],nr)
                nr = 1
        else: nr = nr+1
    
    # start session         
    strSql = 'drop table if exists temp.data'
    sqlfunctions.perform_sql(strSql,credentials)
    strSql = """create table temp.data (
    cruise text,
    dtime timestamp,
    local_cdi_id text,
    edmo text,
    lon double precision,
    lat double precision,
    depthp text,
    depth double precision,
    dqv text,
    dunit text,
    parameter text,
    pvalue double precision,
    pqv text,
    punit text
    )"""
    sqlfunctions.perform_sql(strSql,credentials)

    #dft = df[['Cruise','Station','yyyy-mm-ddThh:mm:ss.sss','column:QV:11','column:QV:13','Longitude_[degrees_east]','Latitude_[degrees_north]','ADEPZZ01','QV:ADEPZZ01','AI18GCD1','QV:AI18GCD1']]
   
    for i in dctcolumns.keys():
        lstinsertcols = list(lstcolumns)
        p = dctcolumns[i][0]
        if p not in ['DTUT8601','PRESPR01','COREDIST','ADEPZZ01']:
            n = dctcolumns[i][2] #number of columns varies, pvalue, pqualityflag, pinfos are mixed with pvalue, pqaulity
            u = dctcolumns[i][1]
            lstinsertcols.append(df.columns[i])
            lstinsertcols.append(df.columns[i+1])
            fp=df.columns[i]
            qfp=df.columns[i+1]
            i = i + n
            # drop intermediate table
            strSql = 'drop table if exists temp.tdata'
            sqlfunctions.perform_sql(strSql,credentials)
            
            # create session to start bulkinsert
            session,pdsql = startinserting(credentials)
            pdsql.to_sql(df[lstinsertcols],'tdata',chunksize=10000)
            session.close()
            
            #for the cases when Cruise is 0 and the column is double not text
            check_type = "select a.attname, format_type(a.atttypid, a.atttypmod) from pg_attribute a where attname = 'Cruise';"
            result = sqlfunctions.executesqlfetch(check_type,credentials)
            if result[0][1]== "double precision":
                #clean up sql's
                strSql = """delete from temp.tdata where "{c}" is null""".format(c=lstinsertcols[-2])
                sqlfunctions.perform_sql(strSql,credentials)
                print("Cleaned table tdata")
            else:
                #clean up sql's
                strSql = """delete from temp.tdata where 
                lower("Cruise") like ('//<history>%') or "{c}" is null""".format(c=lstinsertcols[-2])
                sqlfunctions.perform_sql(strSql,credentials)
                print("Cleaned table tdata")
                
#            #clean up sql's
#            strSql = """delete from temp.tdata where 
#            lower("Cruise"::text) like ('//<history>%') or "{c}" is null""".format(c=lstinsertcols[-2])
#            sqlfunctions.perform_sql(strSql,credentials)
#            #print("Cleaned table tdata")
            
            if not eutro:
                if dfld == '':
                    strSqld = """insert into temp.data 
                    select 
                    "Cruise",
                    "{tfld}"::timestamp,
                    "column:QV:{localcdi}",
                    "column:QV:{edmo}",
                    "Longitude_[degrees_east]",
                    "Latitude_[degrees_north]",
                    null,
                    null,
                    null,
                    null,
                    '{pt}',
                    "{fpt}",
                    "{qfpt}",
                    '{pu}' from temp.tdata""".format(localcdi=dctbasefields['LOCAL_CDI_ID']-1,
                            edmo=dctbasefields['EDMO_code']-1,pt=p,fpt=fp,pu=u,qfpt=qfp,tfld=tfld)        
                else:
                    #print('not eutro, timeseries and depthfield found')
                    dqv = 'QV:{d}'.format(d=dfld)
                    strSqld = """insert into temp.data 
                    select 
                    "Cruise",
                    "{tfld}"::timestamp,
                    "column:QV:{localcdi}",
                    "column:QV:{edmo}",
                    "Longitude_[degrees_east]",
                    "Latitude_[degrees_north]",
                    '{d}',
                    "{d}",
                    "{dqv}",
                    '{du}',
                    '{pt}',
                    "{fpt}",
                    "{qfpt}",
                    '{pu}' from temp.tdata""".format(localcdi=dctbasefields['LOCAL_CDI_ID']-1,
                            edmo=dctbasefields['EDMO_code']-1,d=dfld,dqv=dqv,pt=p,fpt=fp,pu=u,du=dfldu,qfpt=qfp,tfld=tfld)
            else:
                    dqv = 'QV:{d}'.format(d=dfld)
                    strSqld = """insert into temp.data 
                    select 
                    "Cruise",
                    "{tfld}"::timestamp,
                    "LOCAL_CDI_ID",
                    "EDMO_code",
                    "Longitude_[degrees_east]",
                    "Latitude_[degrees_north]",
                    '{d}',
                    "{d}",
                    "{dqv}",
                    '{du}',
                    '{pt}',
                    "{fpt}",
                    "{qfpt}",
                    '{pu}' from temp.tdata""".format(localcdi=dctbasefields['LOCAL_CDI_ID']-1,
                            edmo=dctbasefields['EDMO_code']-1,d=dfld,dqv=dqv,pt=p,fpt=fp,pu=u,du=dfldu,qfpt=qfp,tfld=tfld)
            sqlfunctions.perform_sql(strSqld,credentials)
            
            print('inserted',p)
        
    print('updating z data')
    # update table temp.data, add column with z_id (parameter ID for z field)
    updatedepth_pid(credentials)
    
    print('upating parameter data')
    # update table temp.data, add column parameter_id and update
    updateparameter_pid(credentials)
    
    # update edmo and cdi tables
    istimeseries = False
    print('updating cdi edmo tables and update temp.data')
    if ODV.data_type == 'timeseries': istimeseries = True
    update_edmo_cdi(credentials,fid,istimeseries)
    
    # load data into observation table
    loadobservationdata(fid,credentials)    
    return fid

def loadobservationdata(fid,credentials):
    strSql = """insert into observation (
                value,
                datetime,
                z,
                z_id,
                parameter_id,
                p06_id,
                flag_id,
                cdi_id,
                odvfile_id) 
            select 
                pvalue,
                dtime,
                depth,
                t.z_id,
                t.parameter_id,
                t.p06_id,
                t.flag_id,
                t.cdi_id,
                {f}
            from temp.data t where p06_id is not null and parameter_id is not null""".format(f=fid)
    try:
        sqlfunctions.perform_sql(strSql,credentials) 
        print 'data loaded in the database'
    except Exception:
        print 'error while loading data'
        print strSql
    finally:
        strSql = """drop table temp.data"""
        #sqlfunctions.perform_sql(strSql,credentials)


def startinserting(credentials):
    import sqlalchemy
    Session = sessionmaker(bind=engine)
    session = Session()
    session.rollback()

    meta = sqlalchemy.MetaData(engine, schema='temp')
    meta.reflect()

    pdsql = pandas.io.sql.SQLDatabase(engine, meta=meta)
    return session,pdsql    

def updatedepth_pid(credentials):
    strSql = """
    alter table temp.data add column z_id integer;"""
    sqlfunctions.perform_sql(strSql,credentials)

    strSql = """
    UPDATE temp.data
    SET z_id = pids.id
    FROM (select id, identifier from parameter) as pids
    WHERE depthp = pids.identifier;"""
    sqlfunctions.perform_sql(strSql,credentials)
    
    #drop column depth paramter 
    strSql = """alter table temp.data drop column depthp"""
    sqlfunctions.perform_sql(strSql,credentials)
    
    print('updated parameter id for z column')
    return

def updateparameter_pid(credentials):
    strSql = """
    alter table temp.data add column parameter_id integer;"""
    sqlfunctions.perform_sql(strSql,credentials)

    strSql = """
    UPDATE temp.data
    SET parameter_id = pids.id
    FROM (select id, identifier from parameter) as pids
    WHERE trim(both ' ' from parameter) = pids.identifier;"""
    sqlfunctions.perform_sql(strSql,credentials)
    
    print('updated parameter id for parameter column')
    
    strSql = """alter table temp.data drop column parameter"""
    sqlfunctions.perform_sql(strSql,credentials)
    return    

def correctcoords(credentials):
    # following sqls need to be executed due to the fact that there are longitude > 180
    strSql = """
    update temp.data set lon = lon-360
    where lon::double precision > 180
    """
    sqlfunctions.perform_sql(strSql,credentials)
    return

def update_edmo_cdi(credentials,fid,istimeseries):
    # in order to load the cdi, geometry needs to be there as well as concatenated local_cdi_id and edmo
    correctcoords(credentials) #(to be executed due to the fact that there are longitude > 180)
    
    # bear in mind, this requires some settings in the database which can not be done by ORM
    # alter edmo id column, 
    #    identiy -> always
    #    increment -> 1
    #    minimum -> 1
    # alter edmo table, set constraint unique to code
    strSql = """
    INSERT INTO edmo(code,name,odvfile_id,geom)
    SELECT DISTINCT edmo::integer,'',{},st_setsrid(st_point(0,0),4326) FROM temp.data
    ON CONFLICT (code) DO NOTHING;    
    """.format(fid)
    sqlfunctions.perform_sql(strSql,credentials)
    
    # alter table temp.data and add the emdo_code id
    strSql = """ALTER TABLE temp.data ADD COLUMN edmo_id integer"""
    sqlfunctions.perform_sql(strSql,credentials)
    
    strSql = """
    UPDATE temp.data
    SET edmo_id = edmocodes.id
    FROM (select id, code from edmo) as edmocodes
    WHERE edmo = edmocodes.code::text;"""
    sqlfunctions.perform_sql(strSql,credentials)
    
    # similar for cdi
    strSql = """
    INSERT INTO cdi(geom,istimeseries,cdi,local_cdi_id,edmo_code_id,odvfile_id)
    SELECT DISTINCT st_setsrid(st_point(lon,lat),4326),{it},local_cdi_id||'_'||edmo,local_cdi_id,edmo_id,{fi} 
    FROM temp.data
    ON CONFLICT (cdi) DO NOTHING;    
    """.format(fi=fid,it=istimeseries)
    sqlfunctions.perform_sql(strSql,credentials)
    
    # alter table temp.data and add the emdo_code id
    strSql = """ALTER TABLE temp.data ADD COLUMN cdi_id integer"""
    sqlfunctions.perform_sql(strSql,credentials)
    
    strSql = """
    UPDATE temp.data
    SET cdi_id = cdis.id
    FROM (select id, cdi from cdi) as cdis
    WHERE local_cdi_id||'_'||edmo = cdis.cdi::text;"""
    sqlfunctions.perform_sql(strSql,credentials)
    
    #remove the local_cdi_id column from the temp.data table
    strSql = """ALTER TABLE temp.data DROP COLUMN local_cdi_id"""
    sqlfunctions.perform_sql(strSql,credentials)
    
    # alter table temp.data and add the flag_id columns
    strSql = """ALTER TABLE temp.data ADD COLUMN flag_id integer"""
    sqlfunctions.perform_sql(strSql,credentials)
    
    strSql = """
    UPDATE temp.data
    SET flag_id = flags.id
    FROM (select id, identifier from l20) as flags
    WHERE trim(both ' ' from pqv) = flags.identifier;"""
    sqlfunctions.perform_sql(strSql,credentials)

    # alter table temp.data and add the p06 id
    strSql = """ALTER TABLE temp.data ADD COLUMN p06_id integer"""
    sqlfunctions.perform_sql(strSql,credentials)
    
    strSql = """
    UPDATE temp.data
    SET p06_id = units.id
    FROM (select id, identifier from p06) as units
    WHERE trim(both ' ' from punit) = units.identifier;"""
    sqlfunctions.perform_sql(strSql,credentials)
    
    # additionally, to overcome this specific error, UPTC is also available and should be UPCT
    strSql = """
    UPDATE temp.data
    SET p06_id = units.id
    FROM (select id, identifier from p06 where identifier = 'UPCT') as units
    WHERE punit = 'UPTC';"""
    sqlfunctions.perform_sql(strSql,credentials)

    return

def loadDOIs(engine,credentials):
    # for now this is a manual process, DOI's will be added to the ODV files in future
    # format of the file is filedescription (at this time may 2019 group of files per region and doi)
    strSql = """drop table if exists dois;"""
    sqlfunctions.perform_sql(strSql,credentials)
    csvdoi = r'D:\emodnet\data\DOIs_v2018.xlsx'
    #read the csv, filter by strange values
    dois = pandas.read_excel(csvdoi,keep_default_na=False,skip_blank_lines=True,na_values=['','NaN','null','Title','DOI'])
    
    # clean up the dataframe by dropping all records where data is null
    idx = dois[dois['Title'].isnull()].index
    dois.drop(idx,inplace=True)
    
    # load the data into the database
    pdsql = pandas.io.sql.SQLDatabase(engine)
    pdsql.to_sql(dois,'dois')
    
def updateodvwithdoi(credentials):
    # there is not a direct match for now possible. so you need to compile a file with filename and coupled dois
    csvdoi = r'D:\emodnet\data\DOIs_v2018.csv'
    dois = pandas.read_csv(csvdoi,sep=';',keep_default_na=False,skip_blank_lines=True,na_values=['','NaN'])
    
    # since the files are split it it necesarry to loop over the files and try to find everything
    strSql = """select name FROM odvfile where version = 1;"""
    a = sqlfunctions.executesqlfetch(strSql,credentials)
    
    for f in a:
        # split filenames in odvfile table on .txt and _split and concatenate to filename.txt
        of = '.'.join([f[0].split('.txt')[0].split('_split')[0],'txt'])
        adoi = dois.loc[dois['filename'] == of]['DOI'].values[0]
        strSql = """UPDATE odvfile SET doi = '{d}' 
                    WHERE name similar to '{f}%' """.format(d=adoi,f=of.split('.txt')[0])
        sqlfunctions.perform_sql(strSql,credentials)

def createconnectiontodatabase():
    credentials={}

    def getConnStrFromFile(connFile):
        connFile = open(connFile, 'r')
        connStr = connFile.read()
        connFile.close()
        return connStr
    
    def getCredentialsFromConnectionString(connStr):
        credentials['user'] = connStr.split('//')[1].split(':')[0]
        credentials['password'] = connStr.split(":")[2].split('@')[0] 
        credentials['host'] = connStr.split('@')[1].split(":")[0]
        credentials['port'] = connStr.split(credentials['host']+':')[1].split("/")[0]
        credentials['dbname'] = connStr.split(credentials['port']+"/")[1].split("\n")[0]
        return credentials
    def localcredentials(credentials={}):
        credentials['user'] = 'postgres'
        credentials['password'] = 'ghn@D3lt@r3s'
        credentials['host'] = 'localhost'
        credentials['port'] = '5432'
        credentials['dbname'] = 'emodnet'
        return credentials
    
    #connectionstring in file "odvconnection_local.txt", for example: postgresql://user:password@localhost:5432/databasename
    ## Connect to the DB; load connection credentials from file:
    local=True
    if local:
        connFile=r"D:\emodnet\data\odvconnection_local.txt"
        connStr=getConnStrFromFile(connFile)
        credentials=getCredentialsFromConnectionString(connStr)
    else:
        connFile=r'D:\emodnet\data\odvconnection_ddp.txt'
        connStr=getConnStrFromFile(connFile)
        credentials=getCredentialsFromConnectionString(connStr)
    
   
    ## Create a Session
    engine = create_engine(connStr, echo=False) # echo=True is very slow
    
    Session = sessionmaker(bind=engine)
    
    session = Session()
    session.rollback()
    session.close()
    return credentials,engine
    
# =============================================================================
# 2019 data
 #loading files    
file = r"D:\emodnet\data\2019\Eutrophication_all_withDIN\North_sea_eutrophication_DIN_TS_split0.txt"
credentials,engine = createconnectiontodatabase() 
eutro = True  
af,ODV = pyodv.Odv.fromfile(file)
Session = sessionmaker(bind=engine)
session = Session()
session.rollback()
fid=loaddataintottable(ODV, file,credentials,eutro)
#####

file = r'D:\projecten\eu\EMODNet\chemistry\2019\Contaminants\Regional-Contaminants-Validated-ODV-Collections-Feb2019-V2\Baltic-Biota-Water_harmonized_ocean_depth_profiles.txt'
numerous erros, duplicate P01, duplicate columns, not investigate further
parameter like TPHFIWAT? is read, not in the file, so .... something went wrong with reading!!!
also, could be covered easily is the case thing aca07137

file = r'D:\projecten\eu\EMODNet\chemistry\2019\Contaminants\Regional-Contaminants-Validated-ODV-Collections-Feb2019-V2\Baltic-Sediment_harmonized_depth_profiles.txt'
unit SRAD should be BQM3, also here UPTC and UPCT

file = r'D:\projecten\eu\EMODNet\chemistry\2019\Contaminants\Regional-Contaminants-Validated-ODV-Collections-Feb2019-V2\Med-Biota_harmonised_Time_series.txt'
column "pvalue" is of type double precision but expression is of type text
LINE 14:         "DTUT8601",


#to be read

# perhaps should be read by old version
eutro = True
file = r'Eutrophication_all_withDIN\Atlantic_eutrophication_profiles_DIN_TS.txt'
file = r'Eutrophication_all_withDIN\Artic_eutrophication_DIN_TS.txt'
file = r'Eutrophication_all_withDIN\Atlantic_eutrophication_time_series_DIN_TS.txt'
file = r'Eutrophication_all_withDIN\Baltic_Sea_eutrophication_DIN_TS.txt'
file = r'Eutrophication_all_withDIN\Black_Sea_Eutrophication_DIN_TS.txt'
file = r'Eutrophication_all_withDIN\Mediterranean_Eutrophication_Profiles_DIN_TS.txt'
file = r'Eutrophication_all_withDIN\Mediterranean_Eutrophication_Time-Series_DIN_TS.txt'
file = r'Eutrophication_all_withDIN\North_sea_eutrophication_DIN_TS.txt'

files=[r'Eutrophication_all_withDIN\Atlantic_eutrophication_time_series_DIN_TS.txt'
,r'Eutrophication_all_withDIN\Mediterranean_Eutrophication_Time-Series_DIN_TS.txt'
,r'Eutrophication_all_withDIN\Black_Sea_Eutrophication_DIN_TS.txt'
,r'Eutrophication_all_withDIN\Artic_eutrophication_DIN_TS.txt'
,r'Eutrophication_all_withDIN\Baltic_Sea_eutrophication_DIN_TS.txt'
,r'Eutrophication_all_withDIN\Atlantic_eutrophication_profiles_DIN_TS.txt'
,r'Eutrophication_all_withDIN\Mediterranean_Eutrophication_Profiles_DIN_TS.txt'
,r'Eutrophication_all_withDIN\North_sea_eutrophication_DIN_TS.txt']


eutro = True
# ============= BIOTA - no depth ============= 
# read
file = r'Contaminants\Regional-Contaminants-Validated-ODV-Collections-Feb2019-V2\Black-Sea-Biota_harmonized_profiles.txt'
file = r'Contaminants\Regional-Contaminants-Validated-ODV-Collections-Feb2019-V2\Baltic-Biota-time_series.txt'

# to be read
file = r'Contaminants\Regional-Contaminants-Validated-ODV-Collections-Feb2019-V2\North-Sea_Biota_Contaminants_from_harmonized_ocean_depth_profiles.txt'
file = r'Contaminants\Regional-Contaminants-Validated-ODV-Collections-Feb2019-V2\Atlantic-Biota_harmonised_time_series.txt'
file = r'Contaminants\NorthSea-ContaminantsSpreadsheetFiles\data_from_harmonized_Biota_harmonized_NS_2019.txt'
file = r'Contaminants\Regional-Contaminants-Validated-ODV-Collections-Feb2019-V2\Med-Biota_harmonised_Time_series.txt'
# error

# ============= SEDIMENT - COREDIST ============= 
# read
file = r'Contaminants\Regional-Contaminants-Validated-ODV-Collections-Feb2019-V2\Arctic-Sediment_harmonized_depth_profiles.txt'
file = r'Contaminants\Regional-Contaminants-Validated-ODV-Collections-Feb2019-V2\Atlantic-Sediment_harmonized_depth_profiles.txt'
file = r'Contaminants\Regional-Contaminants-Validated-ODV-Collections-Feb2019-V2\Black-Sea-Sediment_harmonized_profiles.txt'
file = r'Contaminants\Regional-Contaminants-Validated-ODV-Collections-Feb2019-V2\Med-Sediment_harmonised_Cont_Profiles.txt'
file = r'Contaminants\Regional-Contaminants-Validated-ODV-Collections-Feb2019-V2\Med-Sediment_harmonised_Time_series.txt'

# to be read
file = r'Contaminants\Regional-Contaminants-Validated-ODV-Collections-Feb2019-V2\Atlantic-Sediment_harmonised_time_series.txt'

# error
file = r'Contaminants\Regional-Contaminants-Validated-ODV-Collections-Feb2019-V2\North-Sea_Sediment_Contaminants_harmonized_time_series.txt'
file = r'Contaminants\NorthSea-ContaminantsSpreadsheetFiles\data_from_Sediment_harmonized_NS_2019.txt'

# ============= WATER - ADEPZZ01 ============= 
# read
file = r'Contaminants\Regional-Contaminants-Validated-ODV-Collections-Feb2019-V2\Arctic-Water_harmonized_ocean_depth_profiles.txt'
file = r'Contaminants\Regional-Contaminants-Validated-ODV-Collections-Feb2019-V2\Atlantic-Water_harmonized_ocean_depth_profiles.txt'
file = r'Contaminants\Regional-Contaminants-Validated-ODV-Collections-Feb2019-V2\Black-Sea-Water_harmonized_profiles.txt'
file = r'Contaminants\Regional-Contaminants-Validated-ODV-Collections-Feb2019-V2\Med-Water_harmonised_Cont_Profiles.txt'
file = r'Contaminants\Regional-Contaminants-Validated-ODV-Collections-Feb2019-V2\Med-Water_harmonised_Time_series.txt'

# to be read, lost of errors raised
file = r'Contaminants\Regional-Contaminants-Validated-ODV-Collections-Feb2019-V2\North-Sea_Water_Contaminants_harmonized_ocean_depth_profiles.txt'
file = r'Contaminants\NorthSea-ContaminantsSpreadsheetFiles\data_from_aggregated_all_harmonized_Water_harmonized_NS_2019.txt'

northsea eutro files splitted into chuncke

files read = [
r'Eutrophication_all_withDIN\Atlantic_eutrophication_profiles_DIN_TS_split1.txt'
,r'Eutrophication_all_withDIN\Atlantic_eutrophication_profiles_DIN_TS_split2.txt'
,r'Eutrophication_all_withDIN\Atlantic_eutrophication_profiles_DIN_TS_split3.txt'
,r'Eutrophication_all_withDIN\North_sea_eutrophication_DIN_TS_split1.txt'
,r'Eutrophication_all_withDIN\North_sea_eutrophication_DIN_TS_split2.txt'
,r'Eutrophication_all_withDIN\North_sea_eutrophication_DIN_TS_split3.txt'
,r'Eutrophication_all_withDIN\North_sea_eutrophication_DIN_TS_split4.txt'
,r'Eutrophication_all_withDIN\North_sea_eutrophication_DIN_TS_split5.txt'
,r'Eutrophication_all_withDIN\North_sea_eutrophication_DIN_TS_split6.txt'
,r'Eutrophication_all_withDIN\North_sea_eutrophication_DIN_TS_split7.txt'
,r'Eutrophication_all_withDIN\North_sea_eutrophication_DIN_TS_split8.txt'
,r'Eutrophication_all_withDIN\North_sea_eutrophication_DIN_TS_split9.txt'
,r'Eutrophication_all_withDIN\North_sea_eutrophication_DIN_TS_split10.txt'
,r'Eutrophication_all_withDIN\North_sea_eutrophication_DIN_TS_split11.txt'
,r'Eutrophication_all_withDIN\North_sea_eutrophication_DIN_TS_split12.txt'
,r'Eutrophication_all_withDIN\North_sea_eutrophication_DIN_TS_split13.txt'
,r'Eutrophication_all_withDIN\North_sea_eutrophication_DIN_TS_split14.txt'
,r'Eutrophication_all_withDIN\North_sea_eutrophication_DIN_TS_split15.txt'

file nor read
,r'Eutrophication_all_withDIN\Baltic_Sea_eutrophication_DIN_TS_split1.txt'
,r'Eutrophication_all_withDIN\Baltic_Sea_eutrophication_DIN_TS_split2.txt'
r'Eutrophication_all_withDIN\Mediterranean_Eutrophication_Profiles_DIN_TS_split1.txt'
,r'Eutrophication_all_withDIN\Mediterranean_Eutrophication_Profiles_DIN_TS_split2.txt'
,r'Eutrophication_all_withDIN\Mediterranean_Eutrophication_Profiles_DIN_TS_split3.txt'

files=[
]



# =============================================================================

credentials,engine = createconnectiontodatabase()


    root = r'D:\emodnet\data\2019'
    folders = os.listdir(root)
#    folder = r'test'
#    files = [r"D:\Data\testdata\test\EMODnet_testdata2.txt"]

    folders = os.listdir(root)
    for folder in folders:
#        print folder
#        files = glob.glob(os.path.join(os.path.join(root,folder), '*.txt'))
        files = glob.glob(os.path.join(root, '*.txt'))
#        print files
        #files = glob.glob(os.path.join(root, '*.txt'))
        for file in files:
            try:
                print file
                file = os.path.join(root,file)
                Session = sessionmaker(bind=engine)
                
                session = Session()
                session.rollback()
                print 'reading',file

                strSql = 'drop table if exists temp.tdata'
                sqlfunctions.perform_sql(strSql,credentials)
                af,ODV = pyodv.Odv.fromfile(file)
                
                #logging.info(file)
                #logging.info(finddepthfield2(ODV))
                
                """append list of column indices to use with standard list"""
                fid = loaddataintottable(ODV, file,credentials,eutro)
                updateodvwithdoi(credentials)
                # prepare database (drop tables tedmo and tdata) 
                #prepareimport(credentials)                
                
                #write odv-file to db
                #ODF2pg(ODV,file,engine,af,Session,credentials)
                
                #refresh_observedindex(session)
            except IOError:
                sys.exit(-1)
            finally:
                session.close()

def checkcolumns(file):
    af, ODV = pyodv.Odv.fromfile(file)
    #ODV.data = pandas.read_csv(af,sep='\t',names=ODV.pandas_name, na_values=numpy.nan,low_memory=False)
    
    print(ODV.data_type)
    print(ODV.matrix)
    
    dctdepth = finddepthfield2(ODV)
    if len(dctdepth.keys()) <> 1:
        print('depth parameters',dctdepth.keys())
    dfld = dctdepth.keys()[0]
    print('depth var', dfld)
    
    dctcolumns = {}
    nr = 1
    for i in range(len(ODV.sdn_name)):
        if ODV.sdn_name[i].find(dfld) <> -1:
            nr = 2
            continue
        elif ODV.sdn_name[i] != '':
            unit = ODV.sdn_units[i].split('SDN:P06::')[1].split('|')[0]
            try:
                parameter = ODV.sdn_name[i].split('SDN:P01::')[1]
            except:
                parameter = ODV.sdn_name[i].split('SDN:P35::')[1]
            #print(i, parameter, unit,nr)
            dctcolumns[i] = (parameter, unit,nr)
            # check unit
            a = sqlfunctions.executesqlfetch("""select * from p06 where identifier = trim(both ' ' from '{}')""".format(unit),credentials)
            if not a:
                print('no valid unit',unit)
            p = sqlfunctions.executesqlfetch("""select * from parameter where identifier = trim(both '' from '{}')""".format(parameter),credentials)
            if not p:
                print('no valid parameter',parameter)
            nr = 1
        else: nr = nr+1

