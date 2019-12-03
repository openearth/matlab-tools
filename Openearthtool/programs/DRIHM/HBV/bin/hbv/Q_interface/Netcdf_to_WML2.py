'''
Netcdf_to_WML2.py
DRIHM Adaptor for extracting OpenStreams WFLOW-HBV data at selecteed points
from NetCDF file and store in standardized WaterML2 files (DRIHM Q-interface).
$Id: Netcdf_to_WML2.py 12060 2015-07-03 07:59:33Z jagers $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/programs/DRIHM/HBV/bin/hbv/Q_interface/Netcdf_to_WML2.py $
'''
import xml.etree.cElementTree as ET
import netCDF4
from datetime import datetime, timedelta
import time
import os

modelengine = os.getenv('MODELENGINE')
casename = os.getenv('CASENAME')
jobid = os.getenv('JOBID')
runtime = datetime.now().replace(microsecond=0).isoformat()

JOBDIR = os.getcwd()
os.chdir(JOBDIR+'/river_case/river_hbv/meteo_prepare')

#read file with hydraulic points
a=open('points_discharge.txt','r')
lines = a.readlines()
numofPoints=len(lines) 

os.chdir(JOBDIR+'/river_case/river_hbv/work0/outmaps')

# read variables from output .nc file
fncfile = netCDF4.Dataset('model_output.nc','r')
timenc=fncfile.variables['time']
lon=fncfile.variables['x']
lat=fncfile.variables['y']
dlon=abs(lon[1]-lon[0])
half_dlon=dlon/2.0
dlat=abs(lat[1]-lat[0])
half_dlat=dlat/2.0

SurfaceRunoff=fncfile.variables['SurfaceRunoff']

# Reference date/time of the times written by OpenDA/FEWS/OpenStreams WFLOW-HBV
# configuration will always be 1970-01-01 0:00:00 UTC. This reference date/time
# is stored in the local time zone of the computer on which the simulation was
# run, e.g. 1969-31-12 16:00:00 -8:00 for a computer in Los Angelos. Rather
# than interpreting and recomputing 1970-01-01 0:00:00 UTC, we just rely on
# this convention. We don't convert to CET! Explicitly add Z to indicate UTC.

date_b=time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime(timenc[0]*60))
print "start of simulation output: ",date_b
date_e=time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime(timenc[-1]*60))
print "end of simulation output  : ",date_e

for hydro_point in range(numofPoints):
  line=lines[hydro_point].split()
  print line
  pnt_lonstr = line[0]
  pnt_lon    = float(pnt_lonstr)
  pnt_latstr = line[1]
  pnt_lat    = float(pnt_latstr)
  line=lines[hydro_point].split("'")
  if len(line)==3 and len(line[1])>0:
    pnt_name = line[1]
  else:
    pnt_name = '(lat,lon) = ('+pnt_latstr+','+pnt_lonstr+')'
  
  Root = ET.Element("wml2:Collection")
  Root.set('xmlns:gml'            ,   'http://www.opengis.net/gml/3.2')
  Root.set('xmlns:om'             ,   'http://www.opengis.net/om/2.0')
  Root.set('xmlns:sa'             ,   'http://www.opengis.net/sampling/2.0')
  Root.set('xmlns:swe'            ,   'http://www.opengis.net/swe/2.0')
  Root.set('xmlns:xlink'          ,   'http://www.w3.org/1999/xlink')
  Root.set('xmlns:xsi'            ,   'http://www.w3.org/2001/XMLSchema-instance') 
  Root.set('xmlns:wml2'           ,   'http://www.opengis.net/waterml/2.0') 
  Root.set('xmlns:x-wml2'         ,   'http://www.opengis.net/waterml/2.0') 
  Root.set('xmlns:gmd'            ,   'http://www.isotc211.org/2005/gmd')  
  Root.set('xmlns:gco'            ,   'http://www.isotc211.org/2005/gco')
  Root.set('xmlns:sf'             ,   'http://www.opengis.net/sampling/2.0')
  Root.set('xmlns:sams'           ,   'http://www.opengis.net/samplingSpatial/2.0')
  Root.set('xmlns:gts'            ,   'http://www.isotc211.org/2005/gts')
  Root.set('xmlns:gss'            ,   'http://www.isotc211.org/2005/gss')
  Root.set('xmlns:gsr'            ,   'http://www.isotc211.org/2005/gsr')
  Root.set('xsi:schemaLocation'   ,   'http://www.opengis.net/waterml/2.0 http://nwisvaws02.er.usgs.gov/ogc-swie/schemas/waterml2.xsd')
  Root.set('gml:id', 'numofPoints')

  TempExt = ET.SubElement(Root, 'wml2:temporalExtent')
  TempExtTimeP = ET.SubElement(TempExt, 'gml:TimePeriod')
  TempExtTimeP.set('gml:id','TempExt.1')
  TempExtTimePBegin = ET.SubElement(TempExtTimeP, 'gml:beginPosition')
  TempExtTimePBegin.text = date_b
  TempExtTimePEnd = ET.SubElement(TempExtTimeP, 'gml:endPosition')
  TempExtTimePEnd.text = date_e

  DRIHMdict = 'http://www.drihm.eu/index.php/terminology'
  LocDict = ET.SubElement(Root, 'wml2:localDictionary')
  Dict = ET.SubElement(LocDict, 'gml:Dictionary')
  Dict.set('gml:id', 'DRIHM_terminology')
  DictIdent = ET.SubElement(Dict, 'gml:identifier')
  DictIdent.set('codeSpace',DRIHMdict)
  DictIdent.text = 'DRIHM_terminology'
  DictEntry = ET.SubElement(Dict, 'gml:dictionaryEntry')
  DictEntryDef = ET.SubElement(DictEntry, 'gml:Definition')
  DictEntryDef.set('gml:id', 'river_discharge')
  DictEntryDefIdent = ET.SubElement(DictEntryDef, 'gml:identifier')
  DictEntryDefIdent.set('codeSpace',DRIHMdict)
  DictEntryDefIdent.text = 'river_discharge'
  DictEntryDefName = ET.SubElement(DictEntryDef, 'gml:name')
  DictEntryDefName.set('codeSpace',DRIHMdict)
  DictEntryDefName.text = 'river_discharge'
  DictEntryDefRem = ET.SubElement(DictEntryDef, 'gml:remarks')
  DictEntryDefRem.text = 'DRIHM Project Local Definition of river discharge'
  
  FeatMember = ET.SubElement(Root, 'wml2:samplingFeatureMember')
  FeatMemberMonPoint = ET.SubElement(FeatMember, 'wml2:MonitoringPoint')
  FeatMemberMonPoint.set('gml:id','MonPoint.1')
  FeatMemberMonPointName = ET.SubElement(FeatMemberMonPoint, 'gml:name')
  FeatMemberMonPointName.text = pnt_name
  FeatMemberMonPointShape = ET.SubElement(FeatMemberMonPoint, 'sams:shape')
  FeatMemberMonPointShapePoint = ET.SubElement(FeatMemberMonPointShape, 'gml:Point')
  FeatMemberMonPointShapePoint.set('gml:id','HydraulicPoint.1')
  FeatMemberMonPointShapePointPos = ET.SubElement(FeatMemberMonPointShapePoint, 'gml:pos')
  FeatMemberMonPointShapePointPos.set('srsName','urn:ogc:def:crs:EPSG:4326') 
  FeatMemberMonPointShapePointPos.text = pnt_latstr+' '+pnt_lonstr
  FeatMemberMonPointTZ = ET.SubElement(FeatMemberMonPoint, 'wml2:timeZone')
  FeatMemberMonPointTZTimeZone = ET.SubElement(FeatMemberMonPointTZ, 'wml2:TimeZone')
  FeatMemberMonPointTZTimeZoneOffset = ET.SubElement(FeatMemberMonPointTZTimeZone, 'wml2:zoneOffset')
  FeatMemberMonPointTZTimeZoneOffset.text = '00:00'
  FeatMemberMonPointTZTimeZoneAbbrev = ET.SubElement(FeatMemberMonPointTZTimeZone, 'wml2:zoneAbbreviation')
  FeatMemberMonPointTZTimeZoneAbbrev.text = 'UTC' 
  
  TypeMember = ET.SubElement(Root, 'wml2:observationMember')
  TypeMemberObs = ET.SubElement(TypeMember, 'om:OM_Observation')
  TypeMemberObs.set('gml:id','Obs.1') 
  TypeMemberObsPhenTime = ET.SubElement(TypeMemberObs, 'om:phenomenonTime')
  TypeMemberObsPhenTime.set('xlink:href','#TempExt.1') 
  TypeMemberObsResTime = ET.SubElement(TypeMemberObs, 'om:resultTime')
  TypeMemberObsResTimeInst = ET.SubElement(TypeMemberObsResTime, 'gml:TimeInstant')
  TypeMemberObsResTimeInstPos = ET.SubElement(TypeMemberObsResTimeInst, 'gml:TimeInstant')
  TypeMemberObsResTimeInstPos.text = runtime
  TypeMemberObsProperty = ET.SubElement(TypeMemberObs, 'om:observedProperty')
  TypeMemberObsProperty.set('xlink:title','river_discharge') 
  TypeMemberObsFeature = ET.SubElement(TypeMemberObs, 'om:featureOfInterest')
  TypeMemberObsFeature.set('xlink:href','#MonPoint.1') 
  TypeMemberObsResult = ET.SubElement(TypeMemberObs, 'om:result')
  TypeMemberObsResultMTS = ET.SubElement(TypeMemberObsResult, 'wml2:MeasurementTimeseries')
  TypeMemberObsResultMTS.set('gml:id','TimeSeries.1') 
  
  TypeMemberObsResultMTSMetadata = ET.SubElement(TypeMemberObsResultMTS, 'wml2:defaultPointMetadata')
  TypeMemberObsResultMTSMetadataTVP = ET.SubElement(TypeMemberObsResultMTSMetadata, 'wml2:DefaultTVPMeasurementMetadata')
  TypeMemberObsResultMTSMetadataTVPUnit = ET.SubElement(TypeMemberObsResultMTSMetadataTVP, 'wml2:uom')
  TypeMemberObsResultMTSMetadataTVPUnit.set('code','m3/s') 
  
  for lat_index in range(len(lat)):
    if abs(pnt_lat-lat[lat_index])<half_dlat:
      lat_in=lat_index
      
  for lon_index in range(len(lon)):
    if abs(pnt_lon-lon[lon_index])<half_dlon:
      lon_in=lon_index
  
  fil=str(modelengine)+'_'+str(casename)+'_'+str(jobid)+'_Point'+str(hydro_point+1)
  dis=open(fil+'.txt','w')
        
  for timestep in range(len(timenc)):
    discharge_time=time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime(timenc[timestep]*60))
    discharge=SurfaceRunoff[timestep,lat_in,lon_in]

    dis.write(str(discharge)+'\n')

    TypeMemberObsResultMTSPoint = ET.SubElement(TypeMemberObsResultMTS, 'wml2:point')
    TypeMemberObsResultMTSTVP = ET.SubElement(TypeMemberObsResultMTSPoint, 'wml2:MeasurementTVP')
    TypeMemberObsResultMTSTVPTime = ET.SubElement(TypeMemberObsResultMTSTVP, 'wml2:time')
    TypeMemberObsResultMTSTVPTime.text = discharge_time
    TypeMemberObsResultMTSTVPValue = ET.SubElement(TypeMemberObsResultMTSTVP, 'wml2:value')
    TypeMemberObsResultMTSTVPValue.text = str(discharge)
      
  Tree = ET.ElementTree(Root)
  Tree.write(fil+'.wml', encoding='utf-8', xml_declaration=True, method='xml')
  dis.close()
fncfile.close()  
