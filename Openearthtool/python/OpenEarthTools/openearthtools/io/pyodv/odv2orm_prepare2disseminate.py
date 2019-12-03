# -*- coding: utf-8 -*-
"""
Created on Fri Mar 18 11:45:20 2016

@author: hendrik_gt

#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2014-2016 Deltares for EMODnet Chemistry
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

# $Id: odv2orm_prepare2disseminate.py 12625 2016-03-18 14:43:41Z hendrik_gt $
# $Date: 2016-03-18 07:43:41 -0700 (Fri, 18 Mar 2016) $
# $Author: hendrik_gt $
# $Revision: 12625 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/pyodv/odv2orm_prepare2disseminate.py $
# $Keywords: $
"""


# create view p01_colorindex, first create value for each p01 based on min max
from sqlalchemy import create_engine
import sqlfunctions
f = open(r'c:\projecten\emodnet\odvconnection.txt')
engine = create_engine(f.read(), echo=False)
f.close()

## Create a Session
from sqlalchemy.orm import sessionmaker
Session = sessionmaker(bind=engine)

session = Session()
session.rollback()

parameter_valuesview = """CREATE OR REPLACE VIEW parameter_colorvalues AS 
 SELECT min(observation.value) AS min, max(observation.value) AS max, observation.parameter_id
   FROM observation
  WHERE observation.value <> 'NaN'::double precision
  GROUP BY observation.parameter_id;
         """
session.execute(parameter_valuesview)
session.commit()

"""----------------------------------------------------------------------------"""
# then create view with all observations based on colorindex values

# uptdate table observed_cindex, convert this into materialized view in postgresql9.x
"""
INSERT INTO observed_cindex (id,geom,cdi,obsdensity,edmo,istimeseries,p35_id,p35,origin,p36_id,p36,datetime,unit,unitdescription,quality,qualitydescription,depth,z,colorindex,minindx,maxindx integer) as
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
  WHERE o.value <> 'NaN'::double precision AND (l20.identifier::text = ANY (ARRAY['1'::text, '2'::text, '6'::text]));
"""
#drop table observed_cindex 

strSql = """drop table observed_cindex"""
session.execute(strSql)
session.commit()

observed_cindex = """
create table observed_cindex as
 SELECT o.id, 
cdi.geom, 
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
  WHERE o.value <> 'NaN'::double precision AND (l20.identifier::text = ANY (ARRAY['1'::text, '2'::text, '6'::text]));"""
session.execute(observed_cindex)
session.commit()

"""set indices for observed_cindex"""
strSql = """CREATE INDEX idx_oc_cdi
  ON observed_cindex
  USING btree
  (cdi);"""
session.execute(strSql)
session.commit()

strSql = """CREATE INDEX idx_oc_geom
  ON observed_cindex
  USING gist
  (geom);
"""
session.execute(strSql)
session.commit()

strSql = """CREATE INDEX idx_oc_datetime
  ON observed_cindex
  USING btree
  (datetime);
"""
session.execute(strSql)
session.commit()

"""----------------------------------------------------------------------------"""
"""set indices for observation"""
#--DROP INDEX idx_cdi_id;

strSql = """CREATE INDEX idx_cdi_id
  ON observation
  USING btree
  (cdi_id);"""

#-- Index: idx_observation_geom
#-- DROP INDEX idx_observation_geom;

strSql = """CREATE INDEX idx_observation_geom
  ON observation
  USING gist
  (geom);"""

#-- Index: idx_p06_id
#-- DROP INDEX idx_p06_id;

strSql = """CREATE INDEX idx_p06_id
  ON observation
  USING btree
  (p06_id);"""

#-- Index: idx_parameter_id
#-- DROP INDEX idx_parameter_id;

strSql = """CREATE INDEX idx_parameter_id
  ON observation
  USING btree
  (parameter_id);"""
