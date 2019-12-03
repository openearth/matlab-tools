"""
Declare ORM mapping of ODV data to a RDBMS
"""

#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2014 Deltares for EMODnet Chemistry
#       Gerben J. de Boer, Gerrit Hendriksen
#
#       Gerrit Hendriksen@deltares.nl
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

# $Id: odv2orm_model2.py 15359 2019-04-19 15:06:09Z hendrik_gt $
# $Date: 2019-04-19 08:06:09 -0700 (Fri, 19 Apr 2019) $
# $Author: hendrik_gt $
# $Revision: 15359 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/pyodv/odv2orm_model2.py $
# $Keywords: $

from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy  import Sequence, ForeignKey, Column
from sqlalchemy  import Binary, Boolean, Integer, Float, DateTime, String, Text
from geoalchemy2 import Geometry
from geoalchemy2.functions import ST_X, ST_Y
import pyodv     as pyodv

Base = declarative_base()

## controlled vocabularies

class Odvfile(Base): # each file contains only one CDI
    __tablename__ = 'odvfile'

    id            = Column(Integer,Sequence('odvfile_id_seq'),primary_key=True) # internal DB only
    name          = Column(String(64),unique=True)
   #cdi           = Column(Integer, ForeignKey('cdi.cdi', ondelete='CASCADE'),nullable=False)
   #cdi           = Column(String , ForeignKey('cdi.cdi', ondelete='CASCADE'),nullable=False)
    lastmodified  = Column(DateTime(timezone=True))
    size          = Column(Integer)
    sha256hash    = Column(Binary(32),unique=True)
    
    def __repr__(self):
        return "<Odvfile: name=%s, id=%s)>" % (self.name,self.id)


class Edmo(Base):
    __tablename__ = 'edmo'
    id            = Column(Integer,Sequence('edmo_id_seq'),primary_key=True) # internal DB only
    code          = Column(Integer, index=True,unique=True)                  # unique EDMO_code number, could be PK?
    name          = Column(String)
    odvfile_id    = Column(Integer  , ForeignKey('odvfile.id', ondelete='CASCADE'),nullable=False)
    geom          = Column(Geometry('POINT', srid=4326)) # SDN requires WGS84
    
    def __repr__(self):
        return "<Edmo: id=%s, code=%d, name='%s')>" % (self.id, self.code, self.name)

class Parameter(Base):
    __tablename__ = 'parameter'
    id            = Column(Integer,Sequence('parameter_id_seq'),primary_key=True)  # technical key as PK
    identifier    = Column(String, index=True,unique=True)         # candidate key, fixed length 8 confirmed by Roy Lowry
    preflabel     = Column(String)
    altlabel      = Column(String)
    definition    = Column(String)
    origin	  = Column(String)
    p36_id        = Column(Integer , ForeignKey('p36.id', ondelete='CASCADE'),nullable=True)
    
    def __repr__(self):
        return "<Parameter: id=%s, identifier='%s', altlabel='%s',p36_id='%s')>" % (self.id, self.identifier, self.altlabel,self.p36_id)

class P36(Base): # MFSD
    __tablename__ = 'p36'
    id            = Column(Integer,Sequence('p36_id_seq'),primary_key=True)  # technical key as PK
    identifier    = Column(String, index=True,unique=True)         # candidate key, variable length confirmed by Roy Lowry
    preflabel     = Column(String)
    altlabel      = Column(String)
    definition    = Column(String)
    def __repr__(self):
        return "<P36: id=%s, identifier='%s', altlabel='%s')>" % (self.id, self.identifier, self.altlabel)

class P02(Base): # MFSD
    __tablename__ = 'p02'
    id            = Column(Integer,Sequence('p02_id_seq'),primary_key=True)  # technical key as PK
    identifier    = Column(String, index=True,unique=True)         # candidate key, variable length confirmed by Roy Lowry
    preflabel     = Column(String)
    altlabel      = Column(String)
    definition    = Column(String)
    def __repr__(self):
        return "<P02: id=%s, identifier='%s', altlabel='%s')>" % (self.id, self.identifier, self.altlabel)

class L04(Base): # MFSD
    __tablename__ = 'l04'
    id            = Column(Integer,Sequence('l04_id_seq'),primary_key=True)  # technical key as PK
    identifier    = Column(String, index=True,unique=True)         # candidate key, variable length confirmed by Roy Lowry
    preflabel     = Column(String)
    altlabel      = Column(String)
    definition    = Column(String)
    def __repr__(self):
        return "<L04: id=%s, identifier='%s', altlabel='%s')>" % (self.id, self.identifier, self.altlabel)
    
    
class P06(Base): # units
    __tablename__ = 'p06'
    id            = Column(Integer,Sequence('p06_id_seq'),primary_key=True)  # technical key as PK
    identifier    = Column(String, index=True,unique=True)         # candidate key, variable length confirmed by Roy Lowry
    preflabel     = Column(String)
    altlabel      = Column(String)
    definition    = Column(String)
    
    def __repr__(self):
        return "<P06: id=%s, identifier='%s', altLabel='%s')>" % (self.id, self.identifier, self.altLabel)
    
class L20(Base): # quality flags
    __tablename__ = 'l20'
    id            = Column(Integer,Sequence('l20_id_seq'),primary_key=True)  # technical key as PK
    identifier    = Column(String(length=1), index=True, unique=True)        # candidate key, variable length confirmed by Roy Lowry
    preflabel     = Column(String)
    altlabel      = Column(String)
    definition    = Column(String)
    def __repr__(self):
        return "<L20: id=%s, identifier='%s', altlabel='%s')>" % (self.id, self.identifier, self.altlabel)
        
class Z(Base):
    __tablename__ = 'z'
    id            = Column(Integer, Sequence('z_id_seq'),primary_key=True)
    identifier    = Column(String, index=True,unique=True) # P01: ADEPZZ01 or PRESPS01 or COREDIST
    p06_unit      = Column(String)
    preflabel     = Column(String)
    altlabel      = Column(String)
    definition    = Column(String)
    p06_id        = Column(Integer  , ForeignKey('p06.id', ondelete='CASCADE'),nullable=False) # P06 no unique: ULAA     or UPDB     or ULAA
    
    
    def __repr__(self):
        return "<Z: identifier='%s' (p06_id='%s'): '%s')>" % (self.identifier, self.p06_id, self.description)
    
## data

class Cdi(Base): # each CDI can be spread over multiple files, whose name is not always identical to local_cdi_id (prefix and/or suffix)
    __tablename__ = 'cdi'
    id            = Column(Integer, Sequence('cdi_id_seq'),primary_key=True) # internal DB only
    geom          = Column(Geometry('POINT', srid=4326)) # SDN requires WGS84
    istimeseries  = Column(Boolean)
    cdi           = Column(String   , index=True,unique=True)                  # currently we define: cdi=edmo_code:local_cdi_id
    local_cdi_id  = Column(String   , index=True) 			       # only unique per edmo_code, how to handle that?
    edmo_code_id  = Column(Integer  , ForeignKey('edmo.id'   , ondelete='CASCADE'),nullable=False)
    odvfile_id    = Column(Integer  , ForeignKey('odvfile.id', ondelete='CASCADE'),nullable=False)
    
    def __repr__(self):
        return "<Cdi: id=%s, cdi=%s, local_cdi_id='%s', edmo_code='%s'>" % (self.id, self.cdi, self.local_cdi_id, self.edmo_code)
    
   
class Observation(Base):
    __tablename__ = 'observation'
    id            = Column(Integer, Sequence('observation_id_seq'),primary_key=True) # set manually to unique P01 code
    value         = Column(Float)
    datetime      = Column(DateTime(timezone=False))     # SDN requires UTC
    parameter_id  = Column(Integer, ForeignKey('parameter.id', ondelete='CASCADE'),nullable=False)
    p06_id        = Column(Integer, ForeignKey('p06.id'      , ondelete='CASCADE'),nullable=False)
    flag_id       = Column(Integer, ForeignKey('l20.id'      , ondelete='CASCADE'),nullable=False)
    cdi_id        = Column(Integer, ForeignKey('cdi.id'      , ondelete='CASCADE'),nullable=False)
    odvfile_id    = Column(Integer, ForeignKey('odvfile.id'  , ondelete='CASCADE'),nullable=False)
    z             = Column(Float)     # z-position in meters or pressure
    z_id          = Column(Integer, ForeignKey('parameter.id', ondelete='CASCADE'),nullable=False)
    
    def __repr__(self):
        return "<Observation: '%s = %d [%s] ')>" % (self.p01_id, self.value, self.p06_id)
