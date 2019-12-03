"""
Declaration via ORM mapping of Subsurface datamodel, including FEWS time series
compatibla datamodel, requires:
Pyhton packages
 - sqlalchemy
 - geoalchemy2
PostgreSQL/PostGIS
 - schema fews
 - schema borehole
"""

#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares for Projects with a FEWS datamodel in 
#                 PostgreSQL/PostGIS database used in Water Information Systems
#   Gerrit Hendriksen@deltares.nl
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

# $Id: orm_subsurface.py 13354 2017-05-16 12:45:29Z hendrik_gt $
# $Date: 2017-05-16 05:45:29 -0700 (Tue, 16 May 2017) $
# $Author: hendrik_gt $
# $Revision: 13354 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/datamodel/subsurface/orm_subsurface.py $
# $Keywords: $

from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy  import Sequence, ForeignKey, Column, UniqueConstraint
from sqlalchemy  import Binary, Boolean, Integer, Float, DateTime, String, Text
from geoalchemy2 import Geometry

Base = declarative_base()

"""
FEWS data model
"""
class AggregationPeriods(Base):
    __tablename__  = 'aggregationperiods'
    __table_args__ = {'schema': 'fews'}
    aggregationperiodkey = Column(Integer,Sequence('fews.aggregationperiods_aggregationperiodkey_seq'),primary_key=True)    
    id                   = Column(String, unique = True, nullable=False)
    description          = Column(String)

    def __repr__(self):
        return "<AggregationPeriods: aggregationperiodkey=%s)>" % (self.aggregationperiodkey)

class Filters(Base):
    __tablename__  = 'filters'
    __table_args__ = {'schema': 'fews'}
    filterkey              = Column(Integer,Sequence('fews.filters_filterkey_seq'),primary_key=True)
    id                     = Column(String,unique = True, nullable=False)
    name                   = Column(String)
    description            = Column(String)
    parentfilterid         = Column(String)
    validationiconsvisible = Column(Integer)
    mapextentid            = Column(String)
    viewpermission         = Column(String)
    editpermission         = Column(String)

    def __repr__(self):
        return "<Filters: filterkey=%s)>" % (self.filterkey)


class Location(Base):
    __tablename__  = 'location'
    __table_args__ = {'schema': 'fews'}
    locationkey    = Column(Integer,Sequence('fews.location_locationkey_seq1'),primary_key=True)    
    id             = Column(String, unique=True)
    name           = Column(String)
    shortname      = Column(String)
    description    = Column(String)
    x              = Column(Float)
    y              = Column(Float)
    z              = Column(Float)
    icon           = Column(String)
    tooltip        = Column(String)
    wgs_geom       = Column(Geometry('POINT', srid=4326),nullable=False)
    local_geom     = Column(Geometry('POINT'))
    local_srid     = Column(Integer)
    utm_geom       = Column(Geometry('POINT', srid=4326))
    altitude_msl   = Column(Float)
    

    def __repr__(self):
        return "<Location: locationkey=%s)>" % (self.locationkey)

class Moduleinstances(Base):
    __tablename__  = 'moduleinstances'
    __table_args__ = {'schema': 'fews'}
    moduleinstancekey = Column(Integer,Sequence('fews.moduleinstances_moduleinstancekey_seq'),primary_key=True)
    id                = Column(String, unique=True,nullable=False)
    name              = Column(String)
    description       = Column(String)

    def __repr__(self):
        return "<Moduleinstances: moduleinstancekey=%s)>" % (self.moduleinstancekey)

class ParameterGroups(Base):
    __tablename__  = 'parametergroups'
    __table_args__ = {'schema': 'fews'}
    groupkey       = Column(Integer,Sequence('fews.parameterGroups_groupkey_seq'),primary_key=True)
    id             = Column(String, unique=True,nullable=False)    
    name           = Column(String)
    description    = Column(String)
    parametertype  = Column(String, nullable=False)
    unit           = Column(String, nullable=False)
    displayunit    = Column(String, nullable=False)

class ParametersTable(Base):
    __tablename__  = 'parameterstable'
    __table_args__ = {'schema': 'fews'}
    parameterkey   = Column(Integer,Sequence('fews.parameterstable_parameterkey_seq'),primary_key=True)
    id             = Column(String, unique=True,nullable=False)    
    groupkey       = Column(Integer,ForeignKey('fews.parametergroups.groupkey', ondelete='CASCADE'))
    name           = Column(String)
    shortname      = Column(String)
    description    = Column(String)
    valueresolution = Column(Float)
    
class Qualifiers(Base):
    __tablename__  = 'qualifiers'
    __table_args__ = {'schema': 'fews'}
    qualifierkey   = Column(Integer,Sequence('fews.qualifiers_qualifierkey_seq'),primary_key=True)
    id             = Column(String, unique=True,nullable=False)    
    name           = Column(String)
    shortname      = Column(String)
    description    = Column(String)

class QualifierSets(Base):
    __tablename__  = 'qualifiersets'
    __table_args__ = {'schema': 'fews'}
    qualifiersetkey = Column(Integer,Sequence('fews.qualifiersets_qualifiersetkey_seq'),primary_key=True)
    id              = Column(String, unique=True,nullable=False)    
    qualifierkey1   = Column(Integer, ForeignKey('fews.qualifiers.qualifierkey', ondelete='CASCADE'))
    qualifierkey2   = Column(Integer, ForeignKey('fews.qualifiers.qualifierkey', ondelete='CASCADE'))
    qualifierkey3   = Column(Integer, ForeignKey('fews.qualifiers.qualifierkey', ondelete='CASCADE'))
    qualifierkey4   = Column(Integer, ForeignKey('fews.qualifiers.qualifierkey', ondelete='CASCADE'))
    
class Samples(Base):
    __tablename__  = 'samples'
    __table_args__ = {'schema': 'fews'}
    samplekey      = Column(Integer, Sequence('fews.samplekey_seq'),primary_key=True)
    locationkey    = Column(Integer, ForeignKey('fews.location.locationkey', ondelete='CASCADE'))
    datetime       = Column(DateTime, primary_key = True)
    id             = Column(String, unique=True,nullable=False)    
    description    = Column(String)    

class TimeStep(Base):
    __tablename__  = 'timesteps'
    __table_args__ = {'schema': 'fews'}
    timestepkey    = Column(Integer,Sequence('fews.timesteps_timestepkey_seq'),primary_key=True)
    id             = Column(String, unique=True,nullable=False)
    label          = Column(String)

class TimeSeriesKey(Base):
    __tablename__  = 'timeseries'
    __table_args__ = {'schema': 'fews'}
    serieskey              = Column(Integer, Sequence('fews.timeserieskeys_serieskey_seq'),primary_key=True)
    locationkey            = Column(Integer, ForeignKey('fews.location.locationkey', ondelete='CASCADE'))
    parameterkey           = Column(Integer, ForeignKey('fews.parameterstable.parameterkey', ondelete='CASCADE'))
    qualifiersetkey        = Column(Integer, ForeignKey('fews.qualifiersets.qualifiersetkey', ondelete='CASCADE'))
    moduleinstancekey      = Column(Integer, ForeignKey('fews.moduleinstances.moduleinstancekey', ondelete='CASCADE'))
    timestepkey            = Column(Integer, ForeignKey('fews.timesteps.timestepkey', ondelete='CASCADE'))
    aggregationperiodkey   = Column(Integer, ForeignKey('fews.aggregationperiods.aggregationperiodkey', ondelete='CASCADE'))
    valuetype              = Column(Integer, nullable=False,default=0)
    modificationtime       = Column(DateTime, nullable=False)
    # check how to CONSTRAINT uniq_timeserieskey_compound UNIQUE (locationkey, parameterkey, qualifiersetkey, moduleinstancekey, timestepkey, aggregationperiodkey)
    
class TimeSeriesComments(Base):
    __tablename__  = 'timeseriescomments'
    __table_args__ = {'schema': 'fews'}
    serieskey      = Column(Integer,ForeignKey('fews.timeseries.serieskey', ondelete='CASCADE'),primary_key=True)
    datetime       = Column(DateTime, primary_key = True)
    commenttext    = Column(String)

class Users(Base):
    __tablename__  = 'users'
    __table_args__ = {'schema': 'fews'}
    userkey        = Column(Integer,Sequence('fews.users_userkey_seq'),primary_key=True)
    id             = Column(String, unique=True,nullable=False)
    name           = Column(String)

class TimeSeriesManualEditsHistory(Base):
    __tablename__  = 'timeseriesmanualeditshistory'
    __table_args__ = {'schema': 'fews'}
    serieskey      = Column(Integer,ForeignKey('fews.timeseries.serieskey', ondelete='CASCADE'),primary_key=True)
    editdatetime   = Column(DateTime, primary_key = True)
    datetime       = Column(DateTime, primary_key = True)
    userkey        = Column(Integer,ForeignKey('fews.users.userkey', ondelete='CASCADE'))
    scalarvalue    = Column(Float)
    flags          = Column(Integer,nullable=False)
    commenttext    = Column(String)
    
class TimeSeriesValuesAndFlags(Base):
    __tablename__  = 'timeseriesvaluesandflags'
    __table_args__ = {'schema': 'fews'}
    serieskey      = Column(Integer,ForeignKey('fews.timeseries.serieskey', ondelete='CASCADE'),primary_key=True)
    datetime       = Column(DateTime, nullable=False, primary_key = True)
    scalarvalue    = Column(Float,nullable=False)
    flags          = Column(Integer,nullable=False)
    
class FilterTimeSeriesKeys(Base):
    __tablename__  = 'filtertimeserieskeys'
    __table_args__ = {'schema': 'fews'}
    serieskey      = Column(Integer,ForeignKey('fews.timeseries.serieskey', ondelete='CASCADE'),primary_key=True)
    filterkey      = Column(Integer,Sequence('fews.aggregationperiod.aggregationperiodkey'),primary_key=True)    
                   #Column(Integer, ForeignKey('definition_type.definition_type_id', ondelete='CASCADE'))


"""
-------------------------------------------------------------------------------------------------------------------------
Section with Borehole information, additional to FEWS datamodel.
-------------------------------------------------------------------------------------------------------------------------
"""

class Color(Base):
    __tablename__='color'
    __table_args__ = {'schema': 'subsurface'}    
    idcolor        = Column(Integer,Sequence('subsurface.colorkey_seq"'),primary_key=True)
    color          = Column(String,nullable=False)
    colorstandard  = Column(String)     # from Soil science I know that there are standards in color description (i.e. Munsell)

class Lithifaction(Base):
    __tablename__='lithifaction'
    __table_args__ = {'schema': 'subsurface'}    
    idlithifaction = Column(Integer,Sequence('subsurface.lithifaction_seq"'),primary_key=True)
    name           = Column(String,nullable=False)
    description    = Column(String)
    
class Grainsize(Base):
    __tablename__='grainsize'
    __table_args__ = {'schema': 'subsurface'}    
    idgrainsize    = Column(Integer,Sequence('subsurface.grainsize_seq"'),primary_key=True)
    name           = Column(String,nullable=False)
    description    = Column(String)

class Subtype(Base):
    __tablename__='subtype'
    __table_args__ = {'schema': 'subsurface'}
    idsubtype      = Column(Integer,Sequence('subsurface.subtype_seq"'),primary_key=True)
    name           = Column(String,nullable=False)
    description    = Column(String)

class Maintype(Base):
    __tablename__='maintype'
    __table_args__ = {'schema': 'subsurface'}
    idmaintype     = Column(Integer,Sequence('subsurface.maintype_seq'),primary_key=True)
    name           = Column(String,nullable=False)
    description    = Column(String)

class GeologicalPeriod(Base):
    __tablename__='geologicalperiod'
    __table_args__ = {'schema': 'subsurface'}
    idgeologicalperiod = Column(Integer,Sequence('subsurface.geologicalperiod_seq'),primary_key=True)
    period         = Column(String,nullable=False)
    description    = Column(String)

class Methoddescription(Base):
    __tablename__='methoddescription'
    __table_args__ = {'schema': 'subsurface'}
    idmethoddesc   = Column(Integer,Sequence('subsurface.methoddesc_seq'),primary_key=True)
    method         = Column(String,nullable=False)
    description    = Column(String)

class Devicedescription(Base):
    __tablename__='devicedescription'
    __table_args__ = {'schema': 'subsurface'}    
    iddevicedesc   = Column(Integer,Sequence('subsurface.devicedesc_seq'),primary_key=True)
    device         = Column(String,nullable=False)
    description    = Column(String)
    
class Unitdescription(Base):
    __tablename__='unitdescription'
    __table_args__ = {'schema': 'subsurface'}    
    idunit         = Column(Integer,Sequence('subsurface.unitdesc_seq'),primary_key=True)
    unit           = Column(String,nullable=False) 
    unitdescription= Column(String) 
    
class Borehole(Base):
    __tablename__='borehole'
    __table_args__ = {'schema': 'subsurface'}
    idborehole        = Column(Integer,Sequence('subsurface.borehole_boreholekey_seq'),primary_key=True)    
    borehole_dbk      = Column(String)
    #idwell            = Column(Integer, ForeignKey('subsurface.well.idwell', ondelete='CASCADE'))
    idlocation        = Column(Integer, ForeignKey('fews.location.locationkey', ondelete='CASCADE'))
    borehole_nm       = Column(String)
    borehole_class_cd = Column(String)    # normalise
    start_date        = Column(DateTime)
    end_date          = Column(DateTime)
    drilling_org_name = Column(String)    # normalise
    legal_owner_nm    = Column(String)    # normalise
    rig_nm            = Column(String)
    purpose_cd        = Column(String)    # normalise
    purpose_dsc       = Column(String)    # remove after normalisation
    drilling_method   = Column(String)    # normalise
    result_cd         = Column(String)
    drilling_depth    = Column(Float)
    rim_height        = Column(Float)
    remark            = Column(String)
    creation_date     = Column(DateTime)
    modification_date = Column(DateTime)
    
class Well(Base):
    __tablename__='well'
    __table_args__ = {'schema': 'subsurface'}
    idwell            = Column(Integer,Sequence('subsurface.well_seq'),primary_key=True)    
    idborehole        = Column(Integer, ForeignKey('subsurface.borehole.idborehole', ondelete='CASCADE'))
    organisation_dbk  = Column(String)
    owner_org_nm      = Column(String)    # normalise
    municipality      = Column(String)    # remove, can be retrieved via spatial query
    location_nm       = Column(String)
    position_desc     = Column(String)
    original_end_depth = Column(Float)
    construction      = Column(String)    # normalise
    construction_date = Column(DateTime)
    removal_date      = Column(DateTime)
    protection        = Column(String)    # normalise
    groundwater_type  = Column(String)    # normalise
    hydrogeological_unit = Column(String) # normalise
    aquifer_type      = Column(String)    # normalise
    well_purpose      = Column(String)    # normalise
    lithology_log_bln = Column(String)
    creation_date     = Column(String)
    modification_date = Column(DateTime)
    remarks           = Column(String)

class BoreholeDescription(Base):
    __tablename__='boreholedescription'
    __table_args__ = {'schema': 'subsurface'}
    idboreholedesc     = Column(Integer,Sequence('subsurface.borehole_seq'),primary_key=True)    
    idborehole         = Column(Integer, ForeignKey('subsurface.borehole.idborehole', ondelete='CASCADE'))
    idgeologicalperiod = Column(Integer, ForeignKey('subsurface.geologicalperiod.idgeologicalperiod', ondelete='CASCADE'))
    idmaintype         = Column(Integer, ForeignKey('subsurface.maintype.idmaintype', ondelete='CASCADE'))
    idsubtype          = Column(Integer, ForeignKey('subsurface.subtype.idsubtype', ondelete='CASCADE'))
    idgrainsize        = Column(Integer, ForeignKey('subsurface.grainsize.idgrainsize', ondelete='CASCADE'))
    idlithifaction     = Column(Integer, ForeignKey('subsurface.lithifaction.idlithifaction', ondelete='CASCADE'))
    idcolor            = Column(Integer, ForeignKey('subsurface.color.idcolor', ondelete='CASCADE'))
    idmethoddesc       = Column(Integer, ForeignKey('subsurface.methoddescription.idmethoddesc', ondelete='CASCADE'))
    coreintegrety      = Column(String)
    lithologydesc      = Column(String)
    lithologythickness = Column(Float,nullable = False)
    topdepth           = Column(Float,nullable = False)
    botdepth           = Column(Float,nullable = False)
    creationdate       = Column(DateTime,nullable = False)
    modificationdate   = Column(DateTime)
    
class BearingPressure(Base):
    __tablename__='bearingpressure'
    __table_args__ = {'schema': 'subsurface'}
    idbearingpressure = Column(Integer,Sequence('subsurface.bearingpressure_seq'),primary_key=True)    
    idborehole        = Column(Integer, ForeignKey('subsurface.borehole.idborehole', ondelete='CASCADE'),nullable = False)
    idmethoddesc      = Column(Integer, ForeignKey('subsurface.methoddescription.idmethoddesc', ondelete='CASCADE'),nullable = False)
    iddevice          = Column(Integer, ForeignKey('subsurface.devicedescription.iddevicedesc', ondelete='CASCADE'),nullable = False)
    depth             = Column(Float, nullable = False)
    nosamples         = Column(Integer, nullable = False)
    idunit            = Column(Integer, ForeignKey('subsurface.unitdescription.idunit', ondelete='CASCADE'),nullable = False)
    pressure_1_5m     = Column(Float, nullable = False)
    pressure_2m       = Column(Float)
    pressure_3m       = Column(Float)
    datetime          = Column(DateTime)
    remarks           = Column(String)

class StandardPenetrationTest(Base):
    __tablename__='standardpenetrationtest'
    __table_args__ = {'schema': 'subsurface'}
    idspt             = Column(Integer,Sequence('subsurface.spt_seq'),primary_key=True)    
    idborehole        = Column(Integer, ForeignKey('subsurface.borehole.idborehole', ondelete='CASCADE'),nullable = False)
    idmethoddesc      = Column(Integer, ForeignKey('subsurface.methoddescription.idmethoddesc', ondelete='CASCADE'),nullable = False)
    iddevice          = Column(Integer, ForeignKey('subsurface.devicedescription.iddevicedesc', ondelete='CASCADE'),nullable = False)
    nosamples         = Column(Integer, nullable = False)
    noblows15_1       = Column(Integer, nullable = False)
    noblows15_2       = Column(Integer)
    noblows15_3       = Column(Integer)
    noblows30         = Column(Integer, nullable = False)
    datetime          = Column(DateTime)
    remarks           = Column(String)

class Laboratory(Base):
    __tablename__='Laboratory'
    __table_args__ = {'schema': 'subsurface'}
    idspt             = Column(Integer,Sequence('subsurface.spt_seq'),primary_key=True)    
    idborehole        = Column(Integer, ForeignKey('subsurface.borehole.idborehole', ondelete='CASCADE'),nullable = False)
    idmethoddesc      = Column(Integer, ForeignKey('subsurface.methoddescription.idmethoddesc', ondelete='CASCADE'),nullable = False)
    iddevice          = Column(Integer, ForeignKey('subsurface.devicedescription.iddevicedesc', ondelete='CASCADE'),nullable = False)
    depth             = Column(Float, nullable = False)
    idparameter       = Column(Integer, ForeignKey('fews.parameterstable.parameterkey', ondelete='CASCADE'),nullable = False)
    idunit            = Column(Integer, ForeignKey('subsurface.unitdescription.idunit', ondelete='CASCADE'),nullable = False)
    value             = Column(Float, nullable = False)
    datetime          = Column(DateTime)
    remarks           = Column(String)    
    