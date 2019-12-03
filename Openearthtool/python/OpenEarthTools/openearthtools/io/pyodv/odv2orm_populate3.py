"""
Populate RDBMS with odvfile collection
"""
#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2014,2015 Deltares for EMODnet Chemistry
#       Gerben J. de Boer
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
# $Date: 2019-04-01 06:24:10 -0700 (Mon, 01 Apr 2019) $
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
from odv2orm_model2 import *
import odvdir, pyodv, glob
import datetime, odvdatetime, pandas, numpy,os
import re
from sqlalchemy import create_engine
import sqlfunctions




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


"""
for each SDN column, get columnname, index and qualityflag
and export to csv
"""
def ODF2pg(ODV,file,engine,af,Session,credentials):
    import sqlalchemy
    'use work around for pandas to add data to schema'
    
    istimeseries = False
    if ODV.data_type == 'timeseries':
        istimeseries = True
    
    fid = populateODVfile(file)

#    print '--- @i:'
    for i in range(len(ODV.pandas_name)):
        print i,ODV.pandas_name[i],ODV.sdn_name[i],ODV.odv_column[i]

    
    
    """
    for i in range(len(ODV.pandas_name)):
        print i,ODV.pandas_name[i],ODV.sdn_name[i],ODV.odv_column[i]
    
    ['yyyy-mm-ddThh:mm:ss.sss', 'Longitude_[degrees_east]', 'Latitude_[degrees_north]', 'LOCAL_CDI_ID', 'EDMO_code', 
    'column:QV:59', 'column:61', 'column:QV:61', 'column:63']    
    60 column:QV:59 SDN:P01::ADEPZZ01 Depth [m]
    61 column:61  QV:SEADATANET
    62 column:QV:61 SDN:P35::EPC00004 Water body nitrate [umol/l]
    63 column:63  QV:SEADATANET
    """
    cdiloaded = False
    edmoloaded = False
    obssetloaded = False
    cnt = 0
    #loop over all columns not being zero, not time and depth
    for f in ODV.sdn_name:   # sdn_name = list of datavariables
        
#        print '--- @f: SDN_NAME:'
#        print f
        
        tf = findtimefield(ODV)
        if f <> '' and f.find('DTUT8601') <0:
            fd = finddepthfield(ODV)
            print ' '.join(['depthfield',fd])
            if f.find(fd) < 0:
                cnt = cnt + 1
                if cnt > 1:
                    session = Session()
                    session.rollback()
                    af,ODV = pyodv.Odv.fromfile(file)
                meta = sqlalchemy.MetaData(engine, schema='temp')
                meta.reflect()
                pdsql = pandas.io.sql.SQLDatabase(engine, meta=meta)    
                parameter = f.split('::')[1]
                print 'inserting ', parameter
                '''create list with columns to retrieve from csv'''   
                #lstcsvcols= ['Longitude_[degrees_east]', 'Latitude_[degrees_north]',  'LOCAL_CDI_ID', 'EDMO_code']
                lstcsvcols = appendlstusedindices(ODV)
                             
                '''create list of columns to be read from the file
                in case timeseries is true, then time is not in yyyy-mm field but in sdn:p01::dtut8601 field'''
                timefield = 'yyyy-mm-ddThh:mm:ss.sss'
                fld = timefield
                if istimeseries:
                    #print 'switch timefield to SDN:P01::DTUT8601'
                    fld = 'SDN:P01::DTUT8601'
                    try:
                        ODV.sdn_name.index(fld)
                        timefield = ODV.pandas_name[ODV.sdn_name.index(fld)]
                        ODV.usecolindices.append(ODV.sdn_name.index(fld))
                    except ValueError:
                        ODV.usecolindices.append(ODV.pandas_name.index(timefield))
                    #ODV.usecolindices[ODV.sdn_name.index(fld)] = 'object'
                else:
                    #ODV.usecolindices[ODV.pandas_name.index(fld)] = 'object'
                    ODV.usecolindices.append(ODV.pandas_name.index(fld))
                    
                print 'time column assigned = ',timefield
                lstcsvcols.append(timefield)
                               
                'determine column names of depth column and qualityflag of depthcolumn'
                #fd = 'ADEPZZ01'
                try:
                    #cdepth = ODV.pandas_name[ODV.sdn_name.index('::'.join(['SDN:P01',fd]))]
                    #qvdepth = ODV.pandas_name[ODV.sdn_name.index('::'.join(['SDN:P01',fd]))+1]
                    colnr = ODV.sdn_name.index('::'.join(['SDN:P01',fd]))
                except:
                    try:
                        #cdepth = ODV.pandas_name[ODV.sdn_name.index('SDN:P01::{d} ULAA | SDN:P01::{d}'.format(d=fd))]
                        #qvdepth = ODV.pandas_name[ODV.sdn_name.index('SDN:P01::{d} ULAA | SDN:P01::{d}'.format(d=fd))]
                        colnr = ODV.sdn_name.index('SDN:P01::{d} ULAA | SDN:P01::{d}'.format(d=fd))
                    except:
                        print('depth field not found',fd)
                        exit()
                finally:
                    cdepth = ODV.pandas_name[colnr]
                    qvdepth = ODV.pandas_name[colnr+1]
                    print(' '.join(['depth parameter',fd,'and associated column in file',cdepth]))
                lstcsvcols.append(cdepth)
                lstcsvcols.append(qvdepth)
                #ODV.usecolindices[ODV.sdn_name.index('::'.join(['SDN:P01',fd]))] = 'float64'
                #ODV.usecolindices[ODV.sdn_name.index('::'.join(['SDN:P01',fd]))+1] = 'int8'
                #ODV.usecolindices.append(ODV.sdn_name.index('::'.join(['SDN:P01',fd])))
                #ODV.usecolindices.append(ODV.sdn_name.index('::'.join(['SDN:P01',fd]))+1)
                ODV.usecolindices.append(colnr)
                ODV.usecolindices.append(colnr+1)
                ODV.usecolindices.append(colnr+2)

                             
                'determine column name of parameter column and qualityflag column of this parameter'
                cparam = ODV.pandas_name[ODV.sdn_name.index(f)]
                qvparam = ODV.pandas_name[ODV.sdn_name.index(f)+1]
                infoparam = ODV.pandas_name[ODV.sdn_name.index(f)+2]
                lstcsvcols.append(cparam)
                lstcsvcols.append(qvparam)
                #ODV.usecolindices[ODV.sdn_name.index(f)]= 'float64'
                #ODV.usecolindices[ODV.sdn_name.index(f)+1]= 'int8'
                ODV.usecolindices.append(ODV.sdn_name.index(f))
                ODV.usecolindices.append(ODV.sdn_name.index(f)+1)
                ODV.usecolindices.append(ODV.sdn_name.index(f)+2)
                unit = ODV.sdn_units[ODV.sdn_name.index(f)].split('SDN:P06::')[1]
                pname = ODV.odv_name[ODV.sdn_name.index(f)]
                """read only those columns that are necessary"""

                print 'before pandas.read'
                ODV.data = pandas.read_csv(af,sep='\t',names=ODV.pandas_name,
                                           index_col=False, usecols = ODV.usecolindices, 
                                           na_values=numpy.nan,low_memory=False)
                ODV.data = pandas.read_csv(af,sep='\t',names=ODV.pandas_name, 
                                           na_values=numpy.nan,low_memory=False)
                df = ODV.data.ffill()
                #df[df['yyyy-mm-ddThh:mm:ss.sss'].str.contains("from^")]
                print 'number of elements in df',len(df)
                pdsql.to_sql(df,'tdata')
                #dfp = df[0:100000]
                #ldf = np.array_split(df,10)
                af.close()
                #df = ODV.data.loc[:,lstcsvcols]
                #df2 = df.ffill()                
                if not edmoloaded:
                    loadedmo(ODV,fid,engine,credentials,timefield)
                    print 'EDMO codes inserted in the database'
                    edmoloaded = True
                
                'load the data into the table'
                #pdsql.to_sql(ODV.data.ffill(),'tdata')
                'only once for each file insert CDI, they don t change with parameter'
                if not cdiloaded:
                    loadcdi(fid,istimeseries,timefield,credentials,Session)
                    print 'cdi s loaded in the database'
                    cdiloaded=True
                    
                if not obssetloaded:
                    loadObservationSet(fid,istimeseries,timefield,credentials,Session)
                    print 'observation sets loaded in the database'
                    obssetloaded=True
                
                loaddata(fid,istimeseries,parameter,unit,cdepth,cparam,qvparam,timefield,credentials,Session,fd)
                                    
    print fid
    loadObservationSetParameter(fid,credentials,Session)
    print 'observation_set/parameter combinations loaded in the database'


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
    

def loadedmo(ODV,fid,fc,credentials,timefield):
    import numpy as np
    import sqlfunctions
    import sqlalchemy
    
    correcttemp(credentials,Session,timefield)
    
    'get max id from edmo table'    
    strSql = """select max(id) from edmo"""
    p = sqlfunctions.executesqlfetch(strSql,credentials)
    
    'fill a new datafram with unique list of EDMO_codes'
    dfE = pandas.DataFrame(np.unique(ODV.data.ffill().loc[:,'EDMO_code']),columns=['EDMO_code'],index=None)
    'create and fill column odvfile_id'
    dfE['odvfile_id'] = fid
    sv = p[0][0]
    if sv == None:
        sv = 0
        
    'add unique id based on max id already in the database'
    dfE['id'] = np.where(dfE.index[:] >= 0,dfE.index+sv+1,dfE.index[:])
    
    'use work around for pandas to add data to schema'
    meta = sqlalchemy.MetaData(engine, schema='temp')
    meta.reflect()
    pdsql = pandas.io.sql.SQLDatabase(engine, meta=meta)
    pdsql.to_sql(dfE,'tedmo')
    
    try:
        '''add column cdi_id to temp table'''
        strSql = """alter table temp.tedmo add column edmo_id integer"""
        sqlfunctions.perform_sql(strSql,credentials)
        
        '''add cdi_id to table temp'''
        strSql = """update temp.tedmo set edmo_id = sq.id
                    from (select id,code from edmo) as sq
                    where "EDMO_code" = sq.code"""
        sqlfunctions.perform_sql(strSql,credentials)
        'insert data in to edmo table'
        strSql = """insert into edmo (id,code,odvfile_id) 
                    select id,"EDMO_code",odvfile_id from temp.tedmo 
                    where edmo_id is Null"""
        
        sqlfunctions.perform_sql(strSql,credentials)
    except Exception:
        print 'error while performing query to add edmo ',strSql 
    finally: #'drop table temp.tedmo'
        strSql = """drop table temp.tedmo"""
        sqlfunctions.perform_sql(strSql,credentials)

def correcttemp(credentials,Session,timefield):
    import sqlfunctions
    session = Session()
    session.rollback()
    
    print 'remove some mess from table'        
    'first some clean up, apparantly in some cases strings with /History appear in latitude longitude fields'
    strSql = """
            delete from temp.tdata
            where "{tf}" like '%/History%'
            or "Longitude_[degrees_east]"::text like '%/History%'
            or "Latitude_[degrees_north]"::text like '%/History%'
            """.format(tf=timefield)
    sqlfunctions.perform_sql(strSql,credentials)
    
    # following sqls need to be executed due to the fact that there are longitude > 180
    strSql = """alter table temp.tdata add column lon double precision"""
    sqlfunctions.perform_sql(strSql,credentials)
    
    strSql = """
    update temp.tdata set lon = "Longitude_[degrees_east]"::double precision-360
    where "Longitude_[degrees_east]"::double precision > 180
    and "Longitude_[degrees_east]" <> 'Longitude [degrees_east]' and "Longitude_[degrees_east]" is not null
    """
    sqlfunctions.perform_sql(strSql,credentials)
    
    strSql = """update temp.tdata set lon = "Longitude_[degrees_east]"::double precision
    where "Longitude_[degrees_east]"::double precision <= 180
    and "Longitude_[degrees_east]" <> 'Longitude [degrees_east]' and "Longitude_[degrees_east]" is not null
    """
    sqlfunctions.perform_sql(strSql,credentials)
    return
    

def loadcdi(fid,istimeseries,timefield,credentials,Session):
    import sqlfunctions
    session = Session()
    session.rollback()
    print 'loading cdi s'
    'get max id from cdi table'    
    correcttemp(credentials,Session,timefield)

    '''add column cdi_id to temp table'''
    strSql = """alter table temp.tdata add column cdi_id integer"""
    sqlfunctions.perform_sql(strSql,credentials)
    
    '''add cdi_id to table temp'''
    print 'check if cdi is unique in temporary table'
    strSql = """update temp.tdata set cdi_id = sq.id
                from (select id,cdi from cdi) as sq
                where "EDMO_code"::text||':'||"LOCAL_CDI_ID" = sq.cdi"""
    sqlfunctions.perform_sql(strSql,credentials)
    
    #'add unique id based on max id already in the database'
    #dfj['id'] = np.where(dfj.index[:] >= 0,dfj.index+sv+1,dfj.index[:])
    '''insert all data in cdi expect those that already are available'''
    try:
        'insert data in to cdi table'
        strSql = """insert into cdi (geom,istimeseries,cdi,local_cdi_id,edmo_code_id, odvfile_id) 
                    select distinct st_setsrid(st_point(lon,"Latitude_[degrees_north]"::double precision),4326),{ist},
                    "EDMO_code"||':'||"LOCAL_CDI_ID","LOCAL_CDI_ID",edmo.id,{ofid} from temp.tdata
                    join edmo on edmo.code="EDMO_code"
                    where cdi_id is Null and "Longitude_[degrees_east]"::double precision > -360.0 and "Latitude_[degrees_north]"::double precision > -180.0
                    """.format(ist=istimeseries,ofid=fid)
        
        #print strSql
        sqlfunctions.perform_sql(strSql,credentials)
    except Exception:
        print 'Error occurred while performing ',strSql
    finally:
        return

def loadObservationSet(fid,istimeseries,timefield,credentials,Session):
    import sqlfunctions
    session = Session()
    session.rollback()
    print 'loading observation sets'
    
    try:
        print 'insert data into table observationset'
        strSql = """with newobs as (
        select distinct 
         {ofid} as odvfile_id
        ,cdi.id as cdi_id
        ,to_timestamp("{tf}",'YYYY-MM-DD HH24:MI:SS') as datetime
        ,t."P01_Codes" as p01codes
        from cdi
        JOIN "temp".tdata t on cdi.cdi = t."EDMO_code"||':'||t."LOCAL_CDI_ID"
        )
        insert into observationset(odvfile_id, cdi_id, datetime, p01codes)
        select newobs.*
        from newobs 
        left join observationset obs 
            on obs.odvfile_id=newobs.odvfile_id
            and obs.cdi_id=newobs.cdi_id
            and obs.datetime=newobs.datetime
        where obs.odvfile_id is null
        """.format(ofid=fid,tf=timefield)            
                    
        print strSql
        sqlfunctions.perform_sql(strSql,credentials)
    except Exception:
        print 'Error occurred while performing ',strSql
    finally:
        print 'ready loading observation set'
        return

def loadObservationSetParameter(fid,credentials,Session):
    import sqlfunctions
    session = Session()
    session.rollback()
    print 'loading observation sets'
    
    try:
        print 'insert data into table observationset_parameter'
        strSql = """insert into observationset_parameter (odvfile_id, cdi_id, datetime, parameter_id, p01list)
        select x.odvfile_id, x.cdi_id, x.datetime, x.parameter_id, x.p01list
        from vw_observationset_parameter x
        left join observationset_parameter y 
        	on y.odvfile_id=x.odvfile_id
        	and y.cdi_id=x.cdi_id
        	and y.datetime=x.datetime
        	and y.parameter_id=x.parameter_id
        where y.odvfile_id is null
        and x.odvfile_id={ofid};
        """.format(ofid=fid)            
                    
        print strSql
        sqlfunctions.perform_sql(strSql,credentials)
    except Exception:
        print 'Error occurred while performing ',strSql
    finally:
        print 'ready loading observation set'
        return


def prepareimport(credentials):
    import sqlfunctions
    strSql = """SELECT table_name FROM information_schema.tables 
                WHERE table_schema='temp'
             """
    a = sqlfunctions.executesqlfetch(strSql,credentials)
    
    if len(a) != 0:
        strSql = """drop table temp.tedmo"""
        sqlfunctions.perform_sql(strSql,credentials)
        strSql = """drop table temp.tdata"""
        sqlfunctions.perform_sql(strSql,credentials)
                     
def loaddata(fid,istimeseries,parameter,unit,cdepth,cparam,qvparam,timefield,credentials,Session,depthfield):
    import sqlfunctions
    session = Session()
    session.rollback()
    
    'call function to add lon to table and remove record with %History labels'
    correcttemp(credentials,Session,timefield)
    
    'get parameterid and unitid form resp. parameter and p06 table'
    strSql = """SELECT id from parameter where identifier = '{p}'""".format(p=parameter)
    p = sqlfunctions.executesqlfetch(strSql,credentials)   
    print parameter
    pid = p[0][0]
    if pid == None:
        print 'serious error while retrieving parameterid for parameter',parameter
        exit()
    else:
        print ' '.join(['parameter id is',str(pid)])
    
    strSql = """SELECT id from parameter where identifier = '{fd}'""".format(fd=depthfield)
    zar = sqlfunctions.executesqlfetch(strSql,credentials)
    zid = zar[0][0] 
    if zid == None:
        print 'serious error while retrieving parameterid for parameter ADEPZZ01 (depth)'
        exit()
    else:
        print ' '.join(['z parameter id is',str(zid)])
        
    
    strSql = """SELECT id from p06 where identifier = '{u}'""".format(u=unit)
    u = sqlfunctions.executesqlfetch(strSql,credentials)   
    print u
    uid = u[0][0]
    if uid == None:
        print 'serious error while retrieving parameterid for unit ',unit
        exit()
    else:
        print ' '.join(['unit id is',str(uid)])

    
    '''- in some cases there is repetative text in the datum string, by extracting the first 4 characters evaluation on 
       datestring is inserted. Could be replaced by a function that really checks if value is a date value
       - tf = assigned timefield
    '''
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
                    "{v}",
                    to_timestamp("{tf}",'YYYY-MM-DD HH24:MI:SS'),
                    "{d}",
                    {z_id},
                    {pid},
                    {u},
                    l20.id,
                    cdi.id,
                    {f}
                from temp.tdata t
                join cdi on cdi.cdi = t."EDMO_code"||':'||t."LOCAL_CDI_ID"
                join l20 on l20.identifier = t."{qvp}"::text
                where cdi.geom = st_setsrid(st_point(lon,"Latitude_[degrees_north]"::double precision),4326)
                and substr("{tf}", 1, 4) < 'a'
            """.format(v=cparam,d=cdepth,pid=pid,qvp=qvparam,u=uid,f=fid,z_id=zid,tf=timefield)
    try:
        sqlfunctions.perform_sql(strSql,credentials) 
        print 'data loaded in the database'
    except Exception:
        print 'error while loading data'
        print strSql
    finally:
        strSql = """drop table temp.tdata"""
        sqlfunctions.perform_sql(strSql,credentials)
        
def loaddataintottable(fid,ODV, file,credentials):
    import sqlalchemy
    'use work around for pandas to add data to schema'
        
    fid = populateODVfile(file)

    meta = sqlalchemy.MetaData(engine, schema='temp')
    meta.reflect()
    pdsql = pandas.io.sql.SQLDatabase(engine, meta=meta) 

    ODV.data = pandas.read_csv(af,sep='\t',names=ODV.pandas_name, 
                           na_values=numpy.nan,low_memory=False)

    df = ODV.data.ffill()
    #df[df['yyyy-mm-ddThh:mm:ss.sss'].str.contains("from^")]
    print 'number of elements in df',len(df)
    pdsql.to_sql(df,'tdata')


if __name__ == '__main__':
    """handling arguments
    """

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
    connFile='C:\projecten\EMODnet\odvconnection_local.txt'
    connFile=r"D:\projecten\eu\EMODNet\chemistry\repos\odvconnection_local.txt"
    ## Connect to the DB; load connection credentials from file:
    connStr=getConnStrFromFile(connFile)
    credentials=getCredentialsFromConnectionString(connStr)
    credentials = localcredentials()
   
    ## Create a Session
    engine = create_engine(connStr, echo=False) # echo=True is very slow
    from sqlalchemy.orm import sessionmaker
    Session = sessionmaker(bind=engine)
    
    session = Session()
    session.rollback()
    session.close()
    
    # TODO check if database already exists
    #Base.metadata.drop_all(engine)
    
    #Base.metadata.create_all(engine)
    
    #TODO after creation of new database, also initial filling of vocabs is necessary


# =============================================================================
#     root = r'D:\projecten\EU\emodnet_chemistry\data'
#     folders = os.listdir(root)
#     folder = r'D:\projecten\EU\emodnet_chemistry\data\blacksea'
#     folder = r'D:\projecten\EU\emodnet_chemistry\data\atlantic'
#     folder = r"D:\projecten\EU\emodnet_chemistry\data\mediterranean"
#     folder = r'D:\projecten\EU\emodnet_chemistry\data\blacksea\BS_aggregated_v01'
#     file = r"D:\projecten\emodnet\data\blacksea\BS_2_aggregated_v01\BS_NH4_final_v01.txt"
#     file = r"D:\projecten\EU\emodnet_chemistry\data\baltic\Baltic_DIVA_PO4_SiO4_NO3_20150209.txt"    
#     file = r"D:\projecten\emodnet\data\blacksea\BS_2_aggregated_v01\BS_NO2_final_v01.txt"
#     file = r"D:\projecten\emodnet\data\blacksea\BS_2_aggregated_v01\BS_NOx_final_v01.txt"
#     
#     file = r"D:\projecten\EU\emodnet_chemistry\data\mediterranean\Mediterranean_Nutrients_Profiles.txt" 
#     file = r"D:\projecten\EU\emodnet_chemistry\data\mediterranean\Mediterranean_TimeSeries.txt"
#     file = r"D:\projecten\emodnet\data\northsea\NS_final_QA_upto1992_1.txt"
#     file = r"D:\projecten\emodnet\data\blacksea\BS_2_aggregated_v01\BS__aggregated_TimeSeries_v01.txt"
#     file = r"D:\projecten\emodnet\data\northsea\NS_final_QA_1993-2000_1.txt"
#     file = r"D:\projecten\emodnet\data\northsea\NS_final_QA_1993-2000_2.txt"
#     file = r"D:\projecten\emodnet\data\northsea\NS_final_QA_1993-2000_3.txt"
#     file = r"D:\projecten\emodnet\data\northsea\NS_final_QA_1993-2000_4.txt"
#     file = r"D:\projecten\emodnet\data\northsea\NS_final_QA_1993-2000_5.txt"
#     file = r"D:\projecten\emodnet\data\blacksea\BS__aggregated_TimeSeries_v02_with_depth.txt"
#     file = r"D:\projecten\emodnet\data\northsea\NS_final_QA_1993-2000_6.txt"
#     file = r"D:\projecten\emodnet\data\northsea\NS_final_QA_1993-2000_7.txt"
#     file = r"D:\projecten\emodnet\data\northsea\NS_final_QA_1993-2000_8.txt"
#     file = r"D:\projecten\emodnet\data\northsea\NS_final_QA_2001forward.txt"
#     file = r"C:\projecten\emodnet\data\northsea\NS_final_QA_2001forward_1.txt"    
#     file = r"C:\projecten\emodnet\data\blacksea\BS_SiO4_final_v01.txt"
# 
#     file = r'C:\projecten\emodnet\data\blacksea\Baltic_DIVA_PO4_SiO4_NO3_20150209_2.txt'
#     
#     root = r'C:\projecten\emodnet\data\adriatic'
#     root = r'C:\projecten\emodnet\data\blacksea'
#     
#     root = r'C:\projecten\emodnet\data\baltic\EMODnet_Baltic_Sea_20160128'
#     root = r'c:\projecten\emodnet\data\blacksea\BS3_aggregated_v01'
#     
#     file = r"C:\projecten\emodnet\data\baltic\EMODnet_Baltic_Sea_NOx.txt"
#     
#     file = r"C:\projecten\emodnet\data\mediterranean\Mediterranean_TN_data_from_Water_Profiles.txt"
#     file = r"C:\projecten\emodnet\data\mediterranean\Mediterranean_TP_data_from_Water_Profiles.txt"
#     
#     # other parameters carried out from July 2016
#     # BALTIC
#     file = r"C:\projecten\emodnet\data\baltic\EMODnet_Baltic_Sea_pH.txt"
# 
#     file = r"C:\projecten\emodnet\data\baltic\EMODnet_Baltic_Sea_Oxygen1.txt"
#     file = r"C:\projecten\emodnet\data\baltic\EMODnet_Baltic_Sea_Oxygen2.txt"
#     file = r"C:\projecten\emodnet\data\baltic\EMODnet_Baltic_Sea_Alkalinity1.txt"
#     file = r"C:\projecten\emodnet\data\baltic\EMODnet_Baltic_Sea_Alkalinity2.txt"
# 
#     file = r"C:\projecten\emodnet\data\baltic\EMODnet_Baltic_Sea_Chl-a1.txt"
#     file = r"C:\projecten\emodnet\data\baltic\EMODnet_Baltic_Sea_Chl-a2.txt"
#     
#     file = r"C:\projecten\emodnet\data\baltic\EMODnet_Baltic_Sea_pH_1.txt"
#     file = r"C:\projecten\emodnet\data\baltic\EMODnet_Baltic_Sea_pH_2.txt"
#     
#     folder = r'C:\projecten\emodnet\data\baltic\contaminants'
#     file = r"C:\projecten\emodnet\data\baltic\contaminants\EMODnet_Baltic_Sea_Contaminants_sediment_depth_profilesm2.txt"  #renamed it, originally it was EMODnet_Baltic_Sea_Contaminants_sediment_depth_profiles_cm_now_m.txt which is too long for the name field
# 
#     #BLACK SEA
#     file = r"C:\projecten\emodnet\data\blacksea\BS_WBDOC_v01.txt"
#     file = r"C:\projecten\emodnet\data\blacksea\WBDOC_TimeSeries_v01.txt"
#     file = r'C:\projecten\emodnet\data\blacksea\BS_WBChl_a\BS_WBChl_a.txt'
#     file = r"C:\projecten\emodnet\data\blacksea\BS_WBpH\BS_WBpH.txt"
#     folder = r'C:\projecten\emodnet\data\blacksea\nov2016'
#     
#     # med
#     root = r'C:\projecten\emodnet\data\mediterranean\Mediter_Contaminants'
#     file = r'C:\projecten\emodnet\data\mediterranean\Mediter_Contaminants\Biota\Antifoulants_Biota_time_series.txt'
#     file = r'C:\projecten\emodnet\data\mediterranean\Mediter_Contaminants\Biota\Hydrocarbons_biota_time_series.txt'
#     file = r'C:\projecten\emodnet\data\mediterranean\Mediter_Contaminants\Biota\Metals_biota_time_series.txt'
#     file = r'C:\projecten\emodnet\data\mediterranean\Mediter_Contaminants\Biota\PCBs_biota_time_series.txt'
#     file = r'C:\projecten\emodnet\data\mediterranean\Mediter_Contaminants\Biota\Pesticides_biota_time_series.txt'
#     files = [r'C:\projecten\emodnet\data\mediterranean\Mediter_Contaminants\Sediment\Antifoulants_Sediment_Times_Series.txt'
#             ,r'C:\projecten\emodnet\data\mediterranean\Mediter_Contaminants\Sediment\HeavyMetals_Sediment_Profiles.txt'
#             ,r'C:\projecten\emodnet\data\mediterranean\Mediter_Contaminants\Sediment\Hydrocarbons_Sediment_Profiles.txt'
#             ,r'C:\projecten\emodnet\data\mediterranean\Mediter_Contaminants\Sediment\OrgC_Sediment_Profiles.txt'
#             ,r'C:\projecten\emodnet\data\mediterranean\Mediter_Contaminants\Sediment\Polychlorinated-PCBs_Sediment_Profiles.txt']
#     folder = r'C:\projecten\emodnet\data\mediterranean\Mediter_Contaminants\Water'    
#     file = r'C:\projecten\emodnet\data\mediterranean\Mediter_Contaminants\Water\Cs137_Water_Profiles.txt'
#     file = r'C:\projecten\emodnet\data\mediterranean\Mediter_Contaminants\Water\HeavyMetals_Water_Profiles.txt'
#     file = r'C:\projecten\emodnet\data\mediterranean\Mediter_Contaminants\Water\Hydrocarbons_Water_Profiles.txt'
#     file = r'C:\projecten\emodnet\data\mediterranean\Mediter_Contaminants\Water\PCB118_Water_Profiles.txt'
#     
#     #2ndpart profiles MED
#     folder = r'C:\projecten\emodnet\data\mediterranean\secondpart'
#     files = [r'C:\\projecten\\emodnet\\data\\mediterranean\\secondpart\\Chla_Prof_3.txt',
#              r'C:\\projecten\\emodnet\\data\\mediterranean\\secondpart\\Chla_Prof_4.txt']
#     files = [r'C:\\projecten\\emodnet\\data\\mediterranean\\secondpart\\Chla_Prof_5.txt',
#              r'C:\\projecten\\emodnet\\data\\mediterranean\\secondpart\\DIC_Prof.txt',
#              r'C:\\projecten\\emodnet\\data\\mediterranean\\secondpart\\DIN_Prof.txt',
#              r'C:\\projecten\\emodnet\\data\\mediterranean\\secondpart\\PH_Prof.txt',
#              r'C:\\projecten\\emodnet\\data\\mediterranean\\secondpart\\TotalAlkalinity_Prof.txt']
#     files = [r"C:\projecten\emodnet\data\mediterranean\secondpart\DO_Prof_1.txt",
#              r"C:\projecten\emodnet\data\mediterranean\secondpart\DO_Prof_2.txt"]
#     files = [r"C:\projecten\emodnet\data\mediterranean\secondpart\DO_Prof_3.txt",
#              r"C:\projecten\emodnet\data\mediterranean\secondpart\DO_Prof_4.txt"]
#     files = [r"C:\projecten\emodnet\data\mediterranean\secondpart\DO_Prof_5.txt",
#              r"C:\projecten\emodnet\data\mediterranean\secondpart\DO_Prof_6.txt"]
#     files = [r"C:\projecten\emodnet\data\mediterranean\secondpart\DO_Prof_7.txt",
#              r"C:\projecten\emodnet\data\mediterranean\secondpart\DO_Prof_8.txt",
#              r"C:\projecten\emodnet\data\mediterranean\secondpart\DO_Prof_9.txt"]         
#     files = [r'C:\projecten\emodnet\data\mediterranean\Mediter_Contaminants\Mediterranean-Updated-Collections\Biota\Update_Hydrocarbons_Biota_time_series.txt',
#              r'C:\projecten\emodnet\data\mediterranean\Mediter_Contaminants\Mediterranean-Updated-Collections\Biota\Update_Pesticides_Biota_time_series.txt',
#              r'C:\projecten\emodnet\data\mediterranean\Mediter_Contaminants\Mediterranean-Updated-Collections\Sediment\Sediment_Pesticides_Timeseries.txt',
#              r'C:\projecten\emodnet\data\mediterranean\Mediter_Contaminants\Mediterranean-Updated-Collections\Sediment\Update_Sediment_Antifoulants_Timeseries.txt',
#              r'C:\projecten\emodnet\data\mediterranean\Mediter_Contaminants\Mediterranean-Updated-Collections\Sediment\Update_Sediment_Heavy_Metals.txt',
#              r'C:\projecten\emodnet\data\mediterranean\Mediter_Contaminants\Mediterranean-Updated-Collections\Sediment\Update_Sediment_Hydrocarbons.txt',
#              r'C:\projecten\emodnet\data\mediterranean\Mediter_Contaminants\Mediterranean-Updated-Collections\Sediment\Update_Sediment_Organic_Carbon.txt',
#              r'C:\projecten\emodnet\data\mediterranean\Mediter_Contaminants\Mediterranean-Updated-Collections\Sediment\Update_Sediment_PCBs.txt']
#     files = [r'C:\projecten\emodnet\data\mediterranean\Mediter_Contaminants\Mediterranean-Updated-Collections\Water\Update_Water_Body_Hydrocarbons.txt',
#              r'C:\projecten\emodnet\data\mediterranean\Mediter_Contaminants\Mediterranean-Updated-Collections\Water\Update_Water_Body_PCB118.txt']
#     
#     # atlantic
#     file = r"C:\projecten\emodnet\data\atlantic\data_from_Chla_from_ALL_ocean_depth_filt.txt"
#     # file data_from_Oxygen_from_ALL_ocean_depth_filt.txt split into 7 subfiles and stored in a seperate dir.
#     folder = r'C:\projecten\emodnet\data\atlantic\Oxygen'    
#     folder = r'C:\projecten\emodnet\data\atlantic\acidity_ATL'
#     folder = r'C:\projecten\emodnet\data\atlantic\nov2016'
#     file = r"C:\projecten\emodnet\data\atlantic\nov2016\data_from_aggregated_time_series2_Atl.txt" 
# 
#     
#     # north sea
#     file = r"C:\projecten\emodnet\data\northsea\chemicals\data_from_O2_chla_aggregation -1991 final.txt"    
#     folder = r'C:\projecten\emodnet\data\northsea\O2'
#     folder = r'C:\projecten\emodnet\data\northsea\okt2016'
# 
# =============================================================================
# 2019 data
    file = r"D:\projecten\eu\EMODNet\chemistry\2019\NorthSea\data_from_aggregated_all_harmonized_Water_harmonized_NS_2019.txt"

# =============================================================================

    root = r'D:\Data\EMODnet_testdata'
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
                Session = sessionmaker(bind=engine)
                
                session = Session()
                session.rollback()
                print 'reading',file
                strSql = 'drop table if exists temp.tdata'
                sqlfunctions.perform_sql(strSql,credentials)
                af,ODV = pyodv.Odv.fromfile(file)
                """append list of column indices to use with standard list"""
                
                # prepare database (drop tables tedmo and tdata) 
                prepareimport(credentials)                
                
                #write odv-file to db
                ODF2pg(ODV,file,engine,af,Session,credentials)
                
                #refresh_observedindex(session)
            except IOError:
                sys.exit(-1)
            finally:
                session.close()