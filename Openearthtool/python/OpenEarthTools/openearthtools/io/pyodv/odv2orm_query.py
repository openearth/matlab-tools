"""
Query RDBMS with odvfile collection based on cdi or wgs84 bbox, and return Odv object (same as from Odv file)

"""

#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2014-2017 Deltares for EMODnet Chemistry
#       Giorgio Santinelli, Gerrit Hendriksen, Gerben J. de Boer
#
#       giorgio.santinelli@deltares.nl, gerrit.hendriksen@deltares.nl, gerben.deboer@deltares.nl
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

# $Id: odv2orm_query.py 13491 2017-07-26 08:49:58Z hendrik_gt $
# $Date: 2017-07-26 01:49:58 -0700 (Wed, 26 Jul 2017) $
# $Author: hendrik_gt $
# $Revision: 13491 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/pyodv/odv2orm_query.py $
# $Keywords: $
    
# TODO import extracing multiple p01 at once, for making profile plot
# TODO implement filter on time
# TODO implement filter on z
# TODO implement sorting of z, or of original file row order


## Import the ORM
from odv2orm_model  import *
from sqlalchemy     import create_engine
from sqlalchemy.orm import sessionmaker
import geoalchemy2.functions as ga_func

import logging

def odvsplit(O):
    """ split Odv object based on cdi into list of Odv objects.
    Rather slow, although based in pandas indexing, but still 100x 
    faster than seperate database queries per cdi."""
    
    import copy
    from sys import stdout
    cdis = set(O.data["LOCAL_CDI_ID"])
    P  = []
    Osplit = copy.deepcopy(O)
    O.data.index = O.data.LOCAL_CDI_ID
    n = len(cdis)
    print n
    for i, cdi in enumerate(cdis):
        if divmod(i,100)[1]==0:
            print(i),
        Osplit.data = O.data.loc[[cdi],:]
        #Osplit.data = O.data[O.data["LOCAL_CDI_ID"]==cdi]
        P.append(Osplit)
        
    print(n)
        
    return Osplit
    
def orm_cdi_get_parameters(dbstring, edmo, localcdi):
    """request list of p01 based on cdi"""
    import sqlfunctions
    
    Engine = create_engine(dbstring, echo=False) # echo=True is very slow, and hackable
    
    credentials = {}
    credentials['dbname'] = Engine.url.database
    credentials['host'] = Engine.url.host
    credentials['user'] = Engine.url.username
    credentials['password'] = Engine.url.password
    
    lineage = Engine.url.drivername + '://' + Engine.url.username + ':********@'+Engine.url.host+':'+str(Engine.url.port)+'/'+Engine.url.database # dbstring
    
    # strSql = """select p01_id, "altLabel", "prefLabel",to_char(min(datetime),'YYYY-MM-DD HH24:MI:SS'),
    # to_char(max(datetime),'YYYY-MM-DD HH24:MI:SS') from observation o
    # join p01 on p01.identifier = o.p01_id 
    # where cdi_id = '{cdi}'
    # group by p01_id, "altLabel", "prefLabel" """.format(cdi=localcdi)
    
    strSql = """SELECT p.identifier AS code, p.altlabel, p.preflabel, p36.identifier, p36.altlabel, p36.preflabel, min(o.datetime) AS min, max(o.datetime) AS max
   FROM observation o
   JOIN cdi ON cdi.id = o.cdi_id
   JOIN edmo ON edmo.id = cdi.edmo_code_id
   JOIN parameter p ON p.id = o.parameter_id
   JOIN p36 ON p36.id = p.p36_id
   WHERE local_cdi_id = 'Nutrients_ITNUTS0711_H09' and edmo.code = '3009'
   GROUP BY edmo.code, p.identifier, p.altlabel, p.preflabel, p36.identifier, p36.altlabel, p36.preflabel""".format(edmo=edmo,localcdi=localcdi)
    

    a = sqlfunctions.executesqlfetch(strSql,credentials)
    
    return a
    
def orm_from_bbox_get_parameters(dbstring, W,E,S,N):
    """request list of p01 based on bbox"""
    
    import sqlfunctions
    
    Engine = create_engine(dbstring, echo=False) # echo=True is very slow, and hackable
    
    credentials = {}
    credentials['dbname'] = Engine.url.database
    credentials['host'] = Engine.url.host
    credentials['user'] = Engine.url.username
    credentials['password'] = Engine.url.password
    
    lineage = Engine.url.drivername + '://' + Engine.url.username + ':********@'+Engine.url.host+':'+str(Engine.url.port)+'/'+Engine.url.database # dbstring
    
    logging.info(N)
    logging.info(S)
    logging.info(W)
    logging.info(E)
    coordinate_string = '{3} {1},{2} {1},{2} {0},{3} {0},{3} {1}'.format(N,E,S,W)
    
    # strSql = """select p01_id, "altLabel", "prefLabel", to_char(min(datetime), 'YYYY-MM-DD HH24:MI:SS'), 
    # to_char(max(datetime),'YYYY-MM-DD HH24:MI:SS') from observation o
    # join p01 on p01.identifier = o.p01_id
    # where st_contains(st_geomfromtext('POLYGON(({coordstr}))',4326),geom)
    # group by p01_id, "altLabel", "prefLabel" """.format(coordstr=coordinate_string)
    
    # # this was the official query (on the guide), now commented
    # strSql = """SELECT local_cdi_id,edmo.code,p.identifier, p.altlabel, p.preflabel, min(o.datetime) AS min, max(o.datetime) AS max
    # FROM observation o
    # JOIN cdi ON cdi.id = o.cdi_id
    # JOIN edmo ON edmo.id = cdi.edmo_code_id
    # JOIN parameter p ON p.id = o.parameter_id
    # where st_contains(st_geomfromtext('POLYGON(({coordstr}))',4326),o.geom)
    # GROUP BY local_cdi_id,edmo.code, p.identifier,p.altlabel, p.preflabel""".format(coordstr=coordinate_string)
    
    # # the following is a test, under Alex request 1/2.
    # strSql = """select code, identifier,altlabel,preflabel,min as mindate,max as maxdate from parameter_timerange"""
    # strSql="""select distinct p.identifier, p.altlabel, p.preflabel, p06.identifier, p06.altlabel, p06.preflabel, to_char(min(datetime), 'YYYY-MM-DD HH24:MI:SS'), to_char(max(datetime), 'YYYY-MM-DD HH24:MI:SS')
    # from observation o
    # join parameter p on p.id=o.parameter_id
    # join p06 on p06.id=o.p06_id
    # group by p.identifier, p.altlabel, p.preflabel, p06.identifier, p06.altlabel, p06.preflabel"""
    
    # # the following is a test, under Alex request 2/2.
    strSql1="""select p.identifier as codes, 
           p.altLabel as altTitle, 
           p.prefLabel as prefTitle,
           p06.identifier as id,
           p06.altlabel as units,
           p06.prefLabel as units_title,
           to_char(min(datetime), 'YYYY-MM-DD HH24:MI:SS'),
           to_char(max(datetime), 'YYYY-MM-DD HH24:MI:SS'),
           p36.prefLabel as p36_title,
           p36.identifier as p36_code
    from observation o
    join cdi on cdi.id = o.cdi_id
    join parameter p on p.id = o.parameter_id
    join p06 on p06.id = o.p06_id
    join p36 on p36.id = p.p36_id
    where st_contains(st_geomfromtext('POLYGON(({coordstr}))',4326),cdi.geom)
    group by p.identifier, p.altLabel, p.prefLabel, p06.identifier, p06.altlabel, p06.prefLabel, p36.identifier, p36.prefLabel""".format(coordstr=coordinate_string)

    # this should ask for istimeseries rows!
    strSql2="""select p.identifier as codes, 
           p.altLabel as altTitle, 
           p.prefLabel as prefTitle,
           p06.identifier as id,
           p06.altlabel as units,
           p06.prefLabel as units_title,
           to_char(min(o.datetime), 'YYYY-MM-DD HH24:MI:SS'),
           to_char(max(o.datetime), 'YYYY-MM-DD HH24:MI:SS'),
           p36.prefLabel as p36_title,
           p36.identifier as p36_code,
           cdi.istimeseries as istimeseries
    from observation o
    join cdi on cdi.id = o.cdi_id
    join parameter p on p.id = o.parameter_id
    join p06 on p06.id = o.p06_id
    join p36 on p36.id = p.p36_id
    where st_contains(st_geomfromtext('POLYGON(({coordstr}))',4326),cdi.geom)
    group by p.identifier, p.altLabel, p.prefLabel, p06.identifier, p06.altlabel, p06.prefLabel, p36.identifier, p36.prefLabel, cdi.istimeseries""".format(coordstr=coordinate_string)
    
    logging.info(strSql2)
    a = sqlfunctions.executesqlfetch(strSql2,credentials)
    n = len(a); values = a
    #logging.info(a)
    keys = [("codes","altTitle","prefTitle","id","units","units_title","starttime","endtime","p36_title","p36_code")]*n # keys manually inserted
    adict1 = []; adict2 = []
    for vv in range(n):
        adict1.append(dict(zip(keys[0], values[vv]))) # these are "all_monitoring"
        if values[vv][-1:][0]==True:
            adict2.append(dict(zip(keys[0], values[vv]))) # these are "time_series"
    
    #logging.info(n)
    #logging.info(a)
    #logging.info(adict1)
    #logging.info(adict2)
        
    adict = [adict2, adict1]
    return adict
    
   
def orm_from_bbox(dbstring, p01,W,E,S,N,zp01='ADEPZZ01'): # here the z is required!
    """request one p01 based on wgs84 bounding box, and return 1 object across ignoring source"""

    ## Connect to the DB
    # Engine = create_engine(dbstring, echo=False) # echo=True is very slow, and hackable
    # lineage = Engine.url.drivername + '://' + Engine.url.username + ':********@'+Engine.url.host+':'+str(Engine.url.port)+'/'+Engine.url.database # dbstring
    
    # ## Create a Session
    # Session = sessionmaker(bind=Engine)
    # session = Session()
    
    # ## get data
    # from geoalchemy2.elements import WKTElement

    # coordinate_string = '{3} {2},{1} {2},{1} {0},{3} {0},{3} {2}'\
        # .format(N,E,S,W)
    # wkt = WKTElement('POLYGON((' + coordinate_string + '))',4326) 
    # logging.info(wkt)
    
                         
    # rows = session.query(Observation.datetime,
            # ga_func.ST_X(Observation.geom),
            # ga_func.ST_Y(Observation.geom),
                         # Observation.value,
                         # Observation.flag_id,
                         # Observation.p06_id,
                         # Observation.cdi_id,
                         # Observation.z,
                         # Observation.z_id).filter(ga_func.ST_Contains(wkt,Observation.geom),
                                                    # Observation.p01_id==p01)
    
    # p01altLabel = session.query(P01.altLabel).filter_by(identifier=p01       ).one()[0]
    # p06 = rows[0][5]
    # if rows.count() > 0:
        # p06altLabel = session.query(P06.altLabel).filter_by(identifier=p06).one()[0] # first one, subsequently check for uniqueness
    # else:
        # p06altLabel = ''
        
    # zp01 = rows[0][8]
    # zp01altLabel  = session.query(Z.altLabel).filter_by(identifier=zp01).one()[0]
    # zp06          = session.query(Z.p06     ).filter_by(identifier=zp01).one()[0]
    # if rows.count() > 0:
        # zp06altLabel = session.query(P06.altLabel).filter_by(identifier=zp06).one()[0] # first one, subsequently check for uniqueness
    # else:
        # zp06altLabel = ''
        
    # session.close()
    
    import sqlfunctions
    
    Engine = create_engine(dbstring, echo=False) # echo=True is very slow, and hackable
    
    credentials = {}
    credentials['dbname'] = Engine.url.database
    credentials['host'] = Engine.url.host
    credentials['user'] = Engine.url.username
    credentials['password'] = Engine.url.password
    
    lineage = Engine.url.drivername + '://' + Engine.url.username + ':********@'+Engine.url.host+':'+str(Engine.url.port)+'/'+Engine.url.database # dbstring
    
    coordinate_string = '{3} {1},{2} {1},{2} {0},{3} {0},{3} {1}'.format(N,E,S,W)
    
    strSql="""WITH observations as
(
select 
distinct z_id
        from observation o
        join cdi on cdi.id = o.cdi_id
        join parameter p on p.id = o.parameter_id
        join p06 on p06.id = o.p06_id
        join l20 on l20.id = flag_id
        join edmo on edmo.id = cdi.edmo_code_id
        where l20.identifier in ('1','2','6')
        and st_contains(st_geomfromtext('POLYGON(({coordstr}))',4326),cdi.geom) 
        and p.identifier='{p01}'
        )
,zid as 
(
select p.altlabel as zlabel from parameter p
where p.identifier = '{zp01}'
)
,pzu as
(select p06_unit 
from z
join parameter p on p.identifier = z.identifier
where p.identifier = '{zp01}'
)
SELECT 
o.datetime, st_x(cdi.geom),
                st_y(cdi.geom), 
                p.identifier,
                p.altlabel,
                edmo.code as edmo,
                local_cdi_id,
                value, 
                l20.identifier, 
                p06.identifier,
                p06.altlabel,
                local_cdi_id, 
                z,
                (select identifier from z where altlabel = (select zlabel from zid)),
                (select zlabel from zid),
                (select p06_unit from pzu),
                (select altlabel from p06 where identifier = (select p06_unit from pzu))
        from observation o
        join cdi on cdi.id = o.cdi_id
        join parameter p on p.id = o.parameter_id
        join p06 on p06.id = o.p06_id
        join l20 on l20.id = flag_id
        join edmo on edmo.id = cdi.edmo_code_id
        where l20.identifier in ('1','2','6')
        and st_contains(st_geomfromtext('POLYGON(({coordstr}))',4326),cdi.geom) 
        and p.identifier = '{p01}'""".format(coordstr=coordinate_string,p01=p01,zp01=zp01)
        
#    strSql1 = """SELECT st_x(geom),st_y(geom),* FROM obs
#    WHERE st_contains(st_geomfromtext('POLYGON(({coordstr}))',4326),cdi.geom) and p.identifier = '{p01}' and p.identifier = 'ADEPZZ01'
#    """.format(coordstr=coordinate_string,p01=p01)

        
    logging.info(strSql)
    
    a = sqlfunctions.executesqlfetch(strSql,credentials)
    logging.info(a)
    if len(a)==0:
        logging.info('No data found for the query')
        O = pyodv.Odv()
        return O
    
    # logging.info(a[0])
    
    nr = a[0]
    p01altLabel = a[0][4]
    p06 = a[0][9]
    p06altLabel = a[0][10]
    
    
    zp01 = a[0][13]
    # zp01 = 'ADEPZZ01'
    zp01altLabel = a[0][14]
    # zp01altLabel = 'DepBelowSurf'
    zp06 = a[0][15]
    # zp06 = 'ULAA'
    zp06altLabel = a[0][16]
    # zp06altLabel = 'm'
    
    return orm2odv(a, p01, p01altLabel, p06, p06altLabel,
                        zp01,zp01altLabel,zp06,zp06altLabel,lineage)
                        
   
    # strSql = """select datetime, st_x(geom),st_y(geom), value, flag_id, p06_id, cdi_id, z, z_id, p01_id from observation 
    # where st_contains(st_geomfromtext('POLYGON(({coordstr}))',4326),geom) 
    # and p01_id = '{p01}'   """.format(coordstr=coordinate_string,p01=p01)
    
    # logging.info(strSql)
        
    # a = sqlfunctions.executesqlfetch(strSql,credentials)
    # nr = a[0]

    # strSql="""select "altLabel" from p01 where identifier = '{p01id}'""".format( p01id=p01)
    # p01altLabelmany = sqlfunctions.executesqlfetch(strSql,credentials) 
    # p01altLabel = p01altLabelmany[0][0]
    
    # p06 = a[0][5]
    
    # strSql="""select "altLabel" from p06 where identifier = '{p06id}'""".format( p06id=p06)
    # if len(a) > 0:
        # p06altLabelmany = sqlfunctions.executesqlfetch(strSql,credentials)
        # p06altLabel = p06altLabelmany[0][0]
    # else:
        # p06altLabel = ''
    
    # zp01 = a[0][8]
    
    # strSql="""select "altLabel" from Z where identifier = '{zpid}'""".format( zpid=zp01)
    # zp01altLabelmany  = sqlfunctions.executesqlfetch(strSql,credentials)
    # zp01altLabel = zp01altLabelmany[0][0]
    # strSql="""select "p06" from Z where identifier = '{zpid}'""".format( zpid=zp01)
    # zp06many  = sqlfunctions.executesqlfetch(strSql,credentials)
    # zp06 = zp06many[0][0]
    
    # strSql="""select "altLabel" from p06 where identifier = '{zp06id}'""".format( zp06id=zp06)
    # if len(a) > 0:
        # zp06altLabelmany = sqlfunctions.executesqlfetch(strSql,credentials)
        # zp06altLabel = zp06altLabelmany[0][0]
    # else:
        # zp06altLabel = ''
        


def orm_from_cdi(dbstring, p01, edmo, localcdi):
    """request one p01 based on cdi"""

    ## Connect to the DB
    # Engine = create_engine(dbstring, echo=False) # echo=True is very slow, and hackable
    # lineage = Engine.url.drivername + '://' + Engine.url.username + ':********@'+Engine.url.host+':'+str(Engine.url.port)+'/'+Engine.url.database # dbstring
    
    # ## Create a Session
    # Session = sessionmaker(bind=Engine)
    # session = Session()
    # logging.info(Engine)
    # ## get data
    # rows = session.query(Observation.datetime,
            # ga_func.ST_X(Observation.geom),
            # ga_func.ST_Y(Observation.geom),
                         # Observation.value,
                         # Observation.flag_id,
                         # Observation.p06_id, # in fact cdi is redundant, but orm2odv() needs it
                         # Observation.cdi_id,
                         # Observation.z,
                         # Observation.z_id).filter_by(cdi_id=cdi,p01_id=p01)
    # logging.info(rows.all())

    # p01altLabel = session.query(P01.altLabel).filter_by(identifier=p01).one()[0]
    # p06 = rows[0][5]
    # if rows.count() > 0:
        # p06altLabel = session.query(P06.altLabel).filter_by(identifier=p06).one()[0] # first one, subsequently check for uniqueness
    # else:
        # p06altLabel = ''
    
    # zp01 = rows[0][8]
    # zp01altLabel  = session.query(Z.altLabel).filter_by(identifier=zp01).one()[0]
    # zp06          = session.query(Z.p06     ).filter_by(identifier=zp01).one()[0]    
    # if rows.count() > 0:
        # zp06altLabel = session.query(P06.altLabel).filter_by(identifier=zp06).one()[0] # first one, subsequently check for uniqueness
    # else:
        # zp06altLabel = ''

    # session.close()
    
    
    # # select datetime, st_x(geom),st_y(geom), cdi_id, p01_id, z, z_id from observation
    # # where cdi_id = '486.0:FI35200711007_00010_H09' and p01_id='PHPBXXXX'
    
    import sqlfunctions
    
    Engine = create_engine(dbstring, echo=False) # echo=True is very slow, and hackable
    
    credentials = {}
    credentials['dbname'] = Engine.url.database
    credentials['host'] = Engine.url.host
    credentials['user'] = Engine.url.username
    credentials['password'] = Engine.url.password
    
    lineage = Engine.url.drivername + '://' + Engine.url.username + ':********@'+Engine.url.host+':'+str(Engine.url.port)+'/'+Engine.url.database # dbstring
    
    strSql = """WITH observations as
(
select 
distinct z_id
        from observation o
        join cdi on cdi.id = o.cdi_id
        join parameter p on p.id = o.parameter_id
        join p06 on p06.id = o.p06_id
        join l20 on l20.id = flag_id
        join edmo on edmo.id = cdi.edmo_code_id
        where l20.identifier in ('1','2','6')
        and edmo.code = '{edmo}' and cdi.local_cdi_id = '{localcdi}' and p.identifier='{p01}'
        )
,zid as 
(
select p.altlabel as zlabel from parameter p
where id = (select z_id from observations)
)
,pzu as
(select p06_unit 
from z
join parameter p on p.identifier = z.identifier
where p.id = (select z_id from observations)
)
SELECT 
o.datetime, st_x(cdi.geom),
                st_y(cdi.geom), 
                p.identifier,
                p.altlabel,
                edmo.code as edmo,
                local_cdi_id,
                value, 
                l20.identifier, 
                p06.identifier,
                p06.altlabel,
                local_cdi_id, 
                z,
                (select identifier from z where altlabel = (select zlabel from zid)),
                (select zlabel from zid),
                (select p06_unit from pzu),
                (select altlabel from p06 where identifier = (select p06_unit from pzu))
        from observation o
        join cdi on cdi.id = o.cdi_id
        join parameter p on p.id = o.parameter_id
        join p06 on p06.id = o.p06_id
        join l20 on l20.id = flag_id
        join edmo on edmo.id = cdi.edmo_code_id
        where l20.identifier in ('1','2','6')
        and edmo.code = '{edmo}' and cdi.local_cdi_id = '{localcdi}' and p.identifier = '{p01}'""".format(edmo=edmo,localcdi=localcdi,p01=p01)
    
    # # In order to implement a time based query. 
    # and o.datetime between '2006-01-01T00:00:00Z'::timestamp and '2015-01-01T00:00:00Z'::timestamp
    
#    strSql = """select datetime, st_x(geom),st_y(geom), value, flag_id, p06_id, cdi_id, z, z_id from observation
#    where cdi_id = '{cdi}' and p01_id='{p01}'""".format(cdi=cdi,p01=p01)
    
    #logging.info(strSql)
    
    a = sqlfunctions.executesqlfetch(strSql,credentials)
    # logging.info(a)
    
    if len(a[0])==0:
        logging.info('No data found for the query')
        return None
    
    # logging.info(a[0])
    
    nr = a[0]
    p01altLabel = a[0][4]
    p06 = a[0][9]
    p06altLabel = a[0][10]
    
    zp01 = a[0][13]
    zp01altLabel = a[0][14]
    zp06 = a[0][15]
    zp06altLabel = a[0][16]
    
    # strSql="""select altlabel from p01 where identifier = '{p01id}'""".format( p01id=p01)
    # p01altLabelmany = sqlfunctions.executesqlfetch(strSql,credentials) 
    # p01altLabel = p01altLabelmany[0][0]
    
    # p06 = a[0][5]
    
    # strSql="""select "altLabel" from p06 where identifier = '{p06id}'""".format( p06id=p06)
    # if len(a) > 0:
        # p06altLabelmany = sqlfunctions.executesqlfetch(strSql,credentials)
        # p06altLabel = p06altLabelmany[0][0]
    # else:
        # p06altLabel = ''
    
    # zp01 = a[0][8]
    
    # strSql="""select "altLabel" from Z where identifier = '{zpid}'""".format( zpid=zp01)
    # strSql="""select altlabel from parameter where identifier = '{zpid}'""".format(zpid=zp01)
    # zp01altLabelmany  = sqlfunctions.executesqlfetch(strSql,credentials)
    # zp01altLabel = zp01altLabelmany[0][0]
    # strSql="""select "p06" from Z where identifier = '{zpid}'""".format( zpid=zp01)
    # strSql="""select p06_unit,altlabel from Z where identifier = '{zpid}'""".format( zpid=zp01)
    # zp06many  = sqlfunctions.executesqlfetch(strSql,credentials)
    # zp06 = zp06many[0][0]
    # zp06altLabel = zp06many[0][1]
    
#    strSql="""select "altLabel" from p06 where identifier = '{zp06id}'""".format( zp06id=zp06)

    # if len(a) > 0:
        # zp06altLabelmany = sqlfunctions.executesqlfetch(strSql,credentials)
        # zp06altLabel = zp06altLabelmany[0][0]
    # else:
        # zp06altLabel = ''

         
    return orm2odv(a, p01, p01altLabel, p06, p06altLabel,
                        zp01,zp01altLabel,zp06,zp06altLabel,lineage)

def orm2odv(rows, p01, p01altLabel, p06, p06altLabel,
                 zp01,zp01altLabel,zp06,zp06altLabel,sourcename=''):
                 
    """cast orm result into Odv object"""
        
    import odvdir, pyodv, datetime, pandas
    import numpy as np
    
    #n = rows.count()
    n = len(rows)
    logging.info(n)
    
    O = pyodv.Odv()
    
    if n==0:
        print('NO DATA FOUND')
        return O    
    
    # Re-definition (after pyodv has changed..)
    pd_name    = ['Cruise', 'Station', 'Type', 'yyyy-mm-ddThh:mm:ss.sss', 'Longitude_[degrees_east]', 'Latitude_[degrees_north]', 'LOCAL_CDI_ID', 'EDMO_CODE', 'Bot._Depth_[m]', 
    zp01, p01, 'QV:'+p01, ] # no spaces
    O.data     = pandas.DataFrame([[0 for y in range(12)] for x in range(n)], columns=pd_name)
    O.data['yyyy-mm-ddThh:mm:ss.sss'] = datetime.datetime(1900,1,1)  # whole column needs to be same datatype, so overrule 0.
    
    # this one is a bit of a hard code, due to a change in O.pyodv
    O.time_column = 'yyyy-mm-ddThh:mm:ss.sss'
    
    # remember database source, without password
    O.filename         = sourcename
    logging.info(zp01)
    logging.info(p01)
    O.data[zp01]       = None
    O.data[ p01]       = None
    O.data['QV:'+p01]  = None
    
    O.z_column = zp01
        
    # rows fields changed as a consequence of a different query.
    
    arows=np.asarray(rows)

    O.data.loc[:,'EDMO_CODE']                 = arows[:,5]
    O.data.loc[:,'LOCAL_CDI_ID']              = arows[:,6]
    O.data.loc[:,O.time_column]               = arows[:,0] #.isoformat() NO: pandas contains datetime.datetime
    O.data.loc[:,'Longitude_[degrees_east]']  = arows[:,1]
    O.data.loc[:,'Latitude_[degrees_north]']  = arows[:,2]
    O.data.loc[:,zp01]                        = arows[:,12]
    O.data.loc[:,p01]                         = arows[:,7]
    O.data.loc[:,'QV:'+p01]                   = arows[:,8]
    
    for i,row in enumerate(rows):    
        if i==0:
            sdn_units = [row[9]]
        else:
           if not(sdn_units[0]==row[9]):
              sdn_units.append(row[9])
        
## handle Odv meta-data columns
    O.pandas_name.append(zp01)
    O.pandas_name.append( p01)
    O.pandas_name.append('')
    
    O.odv_column = O.pandas_name
    
    O.odv_name   = O.pandas_name    
    
    O.sdn_name.append(zp01altLabel)
    O.sdn_name.append( p01altLabel)
    O.sdn_name.append('')
              
    if len(sdn_units)==1    :
        pass
    else:
        p06altLabel = '<UNITS UNDEFINED: MULTIPLE UNITS FOUND>'    
        print('UNITS UNDEFINED: MULTIPLE UNITS FOUND')
        
    O.sdn_units_code.append(zp06altLabel)
    O.sdn_units_code.append( p06altLabel)
    O.sdn_units_code.append('')
    
    O.sdn_units = O.sdn_units_code
    
    O.odv_units = O.sdn_units_code
    
## determine data_type    
    
#TODO add data_type to DB ORM model
          
    
    if len(np.unique(O.data['Longitude_[degrees_east]']))==1 and len(np.unique(O.data['Latitude_[degrees_north]']))==1:
       if len(np.unique(O.data[O.time_column]))==1:
             O.data_type = 'profile'    # 1 (lat,lon), 1 time
       else:
             O.data_type = 'timeseries' # 1 (lat,lon), N time
    else:
       if len(np.unique(O.data[O.time_column]))==1:
             O.data_type = 'shape'      # N (lat,lon), 1 time (not part of SeaDataNet library)
       else:
             O.data_type = 'trajectory' # N (lat,lon), N time
             
    return O

