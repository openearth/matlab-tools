
# -*- coding: utf-8 -*-
"""
Created on Fri Jul 10 13:15:05 2015

@author: hendrik_gt
"""
import psycopg2
import sqlfunctions


cf = r"C:\projecten\emodnet\odvconnection_sql.txt"
#cf = r"C:\projecten\emodnet\odvconnection_local.txt"
credentials = sqlfunctions.get_credentials(cf)
#get list of aggregated parameters = p35

strSql = """drop table if exists p36_colorvalues cascade """
sqlfunctions.perform_sql(strSql, credentials)

p36_valuesview = """CREATE table p36_colorvalues as
select min(value), max(value), p36.id
from observation o
join parameter p on p.id = o.parameter_id
join p36 on p36.id = p.p36_id
join l20 on l20.id = o.flag_id
where l20.identifier in ('1','2','6')
group by p36.id"""
sqlfunctions.perform_sql(p36_valuesview,credentials)

strSql = """
    create or replace view observed_aggregated_cindex as
    select o.id, geom, cdi_id,parameter_id, datetime,p06_id,flag_id as quality,depth,z, 
           (3* 256 * (value - min)/(max+0.00001 - min))::int as colorindex, 
           min as minindx, max as maxindx
    from observation o
    join cdi on cdi.id = o.cdi_id
    join parameter p on p.id = o.parameter_id
    join p36_colorvalues c on c.id = p.p36_id
    --join p01 on p01.identifier = o.p01_id
    --join p35 on p35.identifier = p01.p35_id 
    --join p35_colorvalues c on c.identifier = p01.p35_id
    """
sqlfunctions.perform_sql(strSql,credentials)

"""discuss if this should be materialized view or .... """
strSql = """DROP TABLE IF EXISTS observed_cindex"""
sqlfunctions.perform_sql(strSql,credentials)

strSql = """
create table observed_cindex as
select
        o.id,        
        cdi.geom, 
        local_cdi_id as cdi,
        edmo.code as edmo,
        p.identifier as p35_id, 
        p35, 
        p.origin as origin, 
        p36.id as parameter_id,
        p36.preflabel as p36, 
        datetime, 
        p06_id as unit, 
        p06.altlabel as unitdescription,
        p06.preflabel as unitpreflabel,
        l20.identifier as quality, 
        l20.preflabel as qualitydescription,depth,z,
        (3* 256 * (value - min)/(max - min))::int as colorindex, 
        min as minindx, max as maxindx
    from observation o
    join cdi on cdi.id = o.cdi_id
    join edmo on edmo.id = cdi.edmo_code_id
    join parameter p on p.id = o.parameter_id
    join p06 on p06.id = o.p06_id
    join l20 on l20.id = o.flag_id
    join p36 on p36.id = p.p36_id
    join p36_colorvalues c on c.id = p.p36_id
    join p35_used u on u.p35_id = p.identifier
    where l20.identifier in ('1','2','6')
"""
sqlfunctions.perform_sql(strSql,credentials)

# new table observed_cindex, so it can be used to query
# it is assumed the table is there
strSql = """drop table temp.obscindex"""
sqlfunctions.perform_sql(strSql,credentials)

strSql = """
create table temp.obscindex as 
    SELECT distinct
    o.datetime, st_x(cdi.geom),
                    st_y(cdi.geom),
                    cdi.geom, 
                    p.identifier as pidentifier,
                    p.altlabel as paltlabel,
                    edmo.code as edmo,
                    local_cdi_id,
                    value, 
                    l20.identifier as qid, 
                    p06.identifier as uid,
                    p06.altlabel as ualtlabel,
                    z,
                    z.identifier as identifier,
                    z.preflabel as zlabel,
                    z.p06_unit as p06_unit,
                    z.altlabel as altlabel
            from observation o
            join cdi on cdi.id = o.cdi_id
            join parameter p on p.id = o.parameter_id
            join p06 on p06.id = o.p06_id
            join l20 on l20.id = flag_id
            join edmo on edmo.id = cdi.edmo_code_id
            join z on z.parameterid = o.z_id
            where l20.identifier in ('1','2','6')"""
sqlfunctions.perform_sql(strSql,credentials)

# set indices on following columns for temp.obscindex
strSql = """CREATE INDEX obscindex_geom
            ON temp.obscindex
            USING gist
            (geom);""".format()
sqlfunctions.perform_sql(strSql,credentials)

# create active p35 list
strSql = """drop table p35_used"""
sqlfunctions.perform_sql(strSql,credentials)

strSql = """create table p35_used
select p.identifier as p35_id, p.preflabel as p35, p.p36_id,
p36.preflabel,min(geom)::geometry as geom,z.identifier as zidentifier
from observation o
join cdi on cdi.id = o.cdi_id
join parameter p on p.id = o.parameter_id
join l20 on l20.id = o.flag_id
join p36 on p36.id = p.p36_id
join parameter z on z.id = o.z_id
where l20.identifier in ('1','2','6')
group by p.identifier,p.preflabel,p.p36_id,p36.preflabel,z.identifier
order by p.identifier"""
sqlfunctions.perform_sql(strSql,credentials)

# for each p35 create different table used as quick get locations in Oceanbrowser
strSql = """select p35_id from p35_used"""
a = sqlfunctions.executesqlfetch(strSql,credentials)

for p35 in a:
    # first drop the table
    strSql = """DROP TABLE IF EXISTS observed_cindex_{p};""".format(p=p35[0])
    sqlfunctions.perform_sql(strSql, credentials)
    
    print 'creating observed index for',p35
    strSql = """CREATE TABLE observed_cindex_{p} AS 
                SELECT * FROM observed_cindex 
                WHERE p35_id = '{p}' 
                ORDER BY geom, datetime, z;""".format(p=p35[0])
    sqlfunctions.perform_sql(strSql,credentials)
    
    strSql = """CREATE INDEX p35_{p}_cindex_btreeid
                ON observed_cindex_{p}
                USING btree
                (id);""".format(p=p35[0])
    sqlfunctions.perform_sql(strSql,credentials)
    #-- Index: p35_8_cindex_datetime
    
    #-- DROP INDEX p35_8_cindex_datetime;
    
    strSql = """CREATE INDEX p35_{p}_cindex_datetime
                ON observed_cindex_{p}
                USING btree
                (datetime);""".format(p=p35[0])
    sqlfunctions.perform_sql(strSql,credentials)
    #-- Index: p35_8_cindex_gistindex
    
    #-- DROP INDEX p35_8_cindex_gistindex;
    
    strSql = """CREATE INDEX p35_{p}_cindex_gistindex
                ON observed_cindex_{p}
                USING gist
                (geom);""".format(p=p35[0])
    sqlfunctions.perform_sql(strSql,credentials)
    #-- Index: p35_8_cindex_indexz
    
    #-- DROP INDEX p35_8_cindex_indexz;
    
    strSql = """CREATE INDEX p35_{p}_cindex_indexz
                ON observed_cindex_{p}
                USING btree
                (z);""".format(p=p35[0])
    sqlfunctions.perform_sql(strSql,credentials)
    #-- Index: p35_8_cindex_p35
    
    #-- DROP INDEX p35_8_cindex_p35;
    
    strSql = """CREATE INDEX p35_{p}_cindex_p35
                ON observed_cindex_{p}
                USING btree
                (p35_id COLLATE pg_catalog."default");""".format(p=p35[0])
    sqlfunctions.perform_sql(strSql,credentials)