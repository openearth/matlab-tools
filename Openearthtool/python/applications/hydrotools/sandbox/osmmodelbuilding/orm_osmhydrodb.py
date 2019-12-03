"""
Declare ORM mapping of Hydrodatbase to a RDBMS for projects that use FM modelling via OSM
"""

#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares for OSM Hydrological modelling Projects
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

# $Id: orm_hydrodb.py 945 2016-09-08 14:35:49Z hendrik_gt $
# $Date: 2016-09-08 16:35:49 +0200 (Thu, 08 Sep 2016) $
# $Author: hendrik_gt $
# $Revision: 945 $
# $HeadURL: https://repos.deltares.nl/repos/NHI/trunk/engines/HMDB/orm_hydrodb.py $
# $Keywords: $

from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy  import Sequence, ForeignKey, Column
from sqlalchemy  import Binary, Boolean, Integer, Float, DateTime, String, Text
from geoalchemy2 import Geometry
from geoalchemy2.functions import ST_X, ST_Y

Base = declarative_base()

## table classes for the controlled vocabularies
class Boundary_type(Base):
    __tablename__ = 'boundary_type'
    boundary_type_id     = Column(Integer,primary_key=True)
    boundary_type        = Column(String)
#    hyperlink               = Column(String)

    def __repr__(self):
        return "<Boundary_type: boundary_type=%s, boundary_type_id=%s)>" % (self.boundary_type,self.boundary_type_id)
        
class Boundary_node(Base):
    __tablename__ = 'boundary_node'
    boundary_node_id    = Column(Integer,primary_key=True)
    boundary_node       = Column(String)
#    hyperlink           = Column(String)

    def __repr__(self):
        return "<Boundary_node: boundary_node=%s, boundary_node_id=%s)>" % (self.boundary_node,self.boundary_node_id)

class Channel_type(Base):
    __tablename__ = 'channel_type'
    channel_type_id    = Column(Integer,primary_key=True)    
    channel_type       = Column(String)
#    hyperlink           = Column(String)

    def __repr__(self):
        return "<Channel_type: channel_type=%s, channel_type_id=%s)>" % (self.channel_type,self.channel_type_id)

class Category(Base):
    __tablename__ = 'category'
    category_id    = Column(Integer,primary_key=True)    
    category       = Column(String)
#    hyperlink           = Column(String)

    def __repr__(self):
        return "<Category: category=%s, category_id=%s)>" % (self.category,self.category_id)
        
class Definition_type(Base):
    __tablename__ = 'definition_type'
    definition_type_id    = Column(Integer,primary_key=True)    
    definition_type       = Column(String)
#    hyperlink           = Column(String)

    def __repr__(self):
        return "<Definition_type: definition_type=%s, definition_type_id=%s)>" % (self.definition_type,self.definition_type_id)

class Friction_type(Base):
    __tablename__ = 'friction_type'
    friction_type_id    = Column(Integer,primary_key=True)    
    friction_type       = Column(String)
#    hyperlink           = Column(String)

    def __repr__(self):
        return "<Friction_type: friction_type=%s, friction_type_id=%s)>" % (self.friction_type,self.friction_type_id)




# following classes are the main objects in the database
class Channel(Base):
    __tablename__ = 'channel'
    channelid               = Column(Integer,Sequence('channel_id_seq'),primary_key=True)    
    geomline                = Column(Geometry('MULTILINESTRING', srid=4326),nullable=False)
    naam                    = Column(String)
    channel_type_id         = Column(Integer, ForeignKey('channel_type.channel_type_id', ondelete='CASCADE'))
    boundary_type_id        = Column(Integer, ForeignKey('boundary_type.boundary_type_id', ondelete='CASCADE'))
    category_id             = Column(Integer, ForeignKey('category.category_id', ondelete='CASCADE'))
    dist_calc_points        = Column(Integer)
    bank_level              = Column(Float)
    code                    = Column(String)
    inp_id                  = Column(Integer)
    
    def __repr__(self):
        return "<Channel: channelid=%s, naam=%d)>" % (self.channelid, self.naam)

class Crosssection(Base):
    __tablename__ = 'crosssection'
    crosssection_id         = Column(Integer,Sequence('crosssection_id_seq'),primary_key=True)    
    geompoint               = Column(Geometry('POINT', srid=4326),nullable=False)
    channel_id              = Column(Integer, ForeignKey('channel_type.channel_type_id', ondelete='CASCADE'))
    definition_id           = Column(Integer, ForeignKey('definition_type.definition_type_id', ondelete='CASCADE'))
    bottomlevel             = Column(Float,nullable=False)
    friction_type_id        = Column(Integer, ForeignKey('friction_type.friction_type_id', ondelete='CASCADE'))
    friction_value          = Column(Float)
    inp_id                  = Column(Integer)

