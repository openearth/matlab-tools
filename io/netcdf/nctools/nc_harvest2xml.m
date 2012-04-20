function nc_harvest2xml(xmlname,D,varargin)
%NC_HARVEST2XML  write nc_harvest object to THREDDS catalog.xml
%
% nc_harvest2xml(xmlname,D)
%
% writes non-flat nc_harvest object D to THREDDS
% catalog.xml file. This is a test!
%
%See also: nc_harvest2xml

OPT.ID                      = 'rijkswaterstaat/vaklodingen_remapped';
OPT.name                    = 'vaklodingen_remapped';

OPT.creator.name            = 'OpenEarth';
OPT.creator.contact.url     = 'http://www.openearth.eu';
OPT.creator.contact.email   = 'gerben.deboer@deltares.nl';

OPT.publisher.name          = '';
OPT.publisher.contact.url   = '';
OPT.publisher.contact.email = '';

OPT.dataType                = ''; % 'GRID'

OPT.documentation.summary   = '';
OPT.documentation.title     = '';
OPT.documentation.url       = '';

OPT = setproperty(OPT,varargin)

fid = fopen(xmlname,'w');

output = fprintf(fid,'%s\n',['<?xml version="1.0" encoding="UTF-8"?>']);
output = fprintf(fid,'%s\n',['<catalog xmlns="http://www.unidata.ucar.edu/namespaces/thredds/InvCatalog/v1.0" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.0.1">']);
output = fprintf(fid,'%s\n',['  <service name="allServices"   serviceType="Compound" base="">']);
output = fprintf(fid,'%s\n',['    <service name="dapService"  serviceType="OPENDAP"  base="/thredds/dodsC/"/>']);
output = fprintf(fid,'%s\n',['    <service name="httpService" serviceType="Download" base="/thredds/fileServer/"/>']);
output = fprintf(fid,'%s\n',['  </service>']);

output = fprintf(fid,'%s\n',['  <dataset name="',OPT.name,'" ID="varopendap/',OPT.ID,'">']);

output = fprintf(fid,'%s\n',['    <metadata inherited="true">']);
output = fprintf(fid,'%s\n',['      <serviceName>allServices</serviceName>']);
output = fprintf(fid,'%s\n',['      <dataType>',OPT.dataType,'</dataType>']);
output = fprintf(fid,'%s\n',['      <documentation xlink:href ="',OPT.documentation.url,'"']); 
output = fprintf(fid,'%s\n',['                     xlink:title="',OPT.documentation.title,'"/>']);
output = fprintf(fid,'%s\n',['      <documentation type="Summary">',OPT.documentation.summary,'</documentation>']);
if 0
output = fprintf(fid,'%s\n',['      <creator>']);
output = fprintf(fid,'%s\n',['        <name vocabulary="DIF">',OPT.creator.name,'</name>']);
output = fprintf(fid,'%s\n',['        <contact url="',OPT.creator.contact.url,'" email="',OPT.creator.contact.email,'"/>']);
output = fprintf(fid,'%s\n',['      </creator>']);
output = fprintf(fid,'%s\n',['      <publisher>']);
output = fprintf(fid,'%s\n',['        <name vocabulary="DIF">',OPT.publisher.name,'</name>']);
output = fprintf(fid,'%s\n',['        <contact url="',OPT.publisher.contact.url,'" email="',OPT.publisher.contact.email,'"/>']);
output = fprintf(fid,'%s\n',['      </publisher>']);
end 
output = fprintf(fid,'%s\n',['    </metadata>']);

      for i=1:length(D)
      
        output = fprintf(fid,'%s\n',['']);
        output = fprintf(fid,'%s\n',['    <dataset name   ="',filenameext(D(i).urlPath) '"']);
        output = fprintf(fid,'%s\n',['             ID     ="varopendap/',OPT.ID,'/',filenameext(D(i).urlPath),'"']);
        output = fprintf(fid,'%s\n',['             urlPath=   "opendap/',OPT.ID,'/',filenameext(D(i).urlPath),'">']);

        output = sprintf(['      <geospatialCoverage>\n'...
                          '       <northsouth>\n%s'...
                          '       </northsouth>\n'...
                          '       <eastwest>\n%s'...
                          '       </eastwest>\n'...
                          '       <updown>\n%s'...
                          '       </updown>\n'...
                          '      </geospatialCoverage>\n'],...
            opendap_spatialRange_write('start',D(i).geospatialCoverage.northsouth.start,'stop',D(i).geospatialCoverage.northsouth.end,'indent','        '),...
            opendap_spatialRange_write('start',D(i).geospatialCoverage.eastwest.start  ,'stop',D(i).geospatialCoverage.eastwest.end  ,'indent','        '),...
            opendap_spatialRange_write('start',D(i).geospatialCoverage.updown.start    ,'stop',D(i).geospatialCoverage.updown.end    ,'indent','        '));
        fprintf(fid,output);
        output = sprintf(['      <timeCoverage>\n'...
                          '        <start>%s</start>'...
                          '        <end>%s</end>'...
                          '      </timeCoverage>\n'],...
            datestr(D(i).timeCoverage.start,'yyyy-mm-ddTHH:MM:SS'),...
            datestr(D(i).timeCoverage.end  ,'yyyy-mm-ddTHH:MM:SS'));
        fprintf(fid,output);
        output = fprintf(fid,'%s\n',['    </dataset>']);
      
      end
      
output = fprintf(fid,'%s\n',['  </dataset>']);
output = fprintf(fid,'%s\n',['</catalog>']);
fclose(fid)
      
function output = opendap_spatialRange_write(varargin);
%OPENDAP_SPATIALRANGE_WRITE
%
%   string = opendap_spatialRange_write(<keyword,value>)
%
% where keywords are 
% * 'start'/'stop'/'size'  2 our of 3 required or 'limits'
% * 'limits'               required if not 'start'/'stop'/'size'
% * 'resolution'           optional
% * 'units'                required if not spherical degrees
%
% Example:
% opendap_spatialRange_write('limits',[50 51])
% opendap_spatialRange_write('start' ,50     ,'stop',51)
% opendap_spatialRange_write('start' ,50     ,'size', 1)
%
%See also: OPENDAP

%% geospatialCoverage Element
% 
% <xsd:element name="geospatialCoverage">
%  <xsd:complexType>
%   <xsd:sequence>
%     <xsd:element name="northsouth" type="spatialRange" minOccurs="0" />
%     <xsd:element name="eastwest" type="spatialRange" minOccurs="0" />
%     <xsd:element name="updown" type="spatialRange" minOccurs="0" />
%     <xsd:element name="name" type="controlledVocabulary" minOccurs="0" maxOccurs="unbounded"/>
%   </xsd:sequence>
%     
%   <xsd:attribute name="zpositive" type="upOrDown" default="up"/>
%  </xsd:complexType>
% </xsd:element>
% 
% <xsd:complexType name="spatialRange">
%  <xsd:sequence>
%    <xsd:element name="start" type="xsd:double"  />
%    <xsd:element name="size" type="xsd:double" />
%    <xsd:element name="resolution" type="xsd:double" minOccurs="0" />
%    <xsd:element name="units" type="xsd:string" minOccurs="0" />
%  </xsd:sequence>
% </xsd:complexType>
% 
% <xsd:simpleType name="upOrDown">
%  <xsd:restriction base="xsd:token">
%    <xsd:enumeration value="up"/>
%    <xsd:enumeration value="down"/>
%  </xsd:restriction>
% </xsd:simpleType>

OPT.start      = [];
OPT.stop       = [];
OPT.size       = [];
OPT.limits     = [];
OPT.resolution = [];
OPT.units      = [];
OPT.indent     = '';

OPT = setproperty(OPT,varargin);

if ~(isempty(OPT.limits) | isnan(OPT.limits))
   OPT.start = OPT.limits(1);
   OPT.size  = OPT.limits(2) - OPT.limits(1);
end

if isempty(OPT.size) & ~isempty(OPT.stop) & ~isempty(OPT.start)
   OPT.size = OPT.stop - OPT.start;
end

if isempty(OPT.start) & ~isempty(OPT.stop) & ~isempty(OPT.size)
   OPT.size = OPT.stop - OPT.size;
end

if ~isempty(OPT.resolution)
    output = sprintf([...
          '%s<start>%f</start>',...
          '%s<size>%f</size>',...
          '%s<resolution>%s</resolution>',...
          '%s<units>%s</units>'],...
        OPT.indent,OPT.start,OPT.indent,OPT.size,OPT.indent,OPT.resolution,OPT.indent,OPT.units);
else        
    output = sprintf([...
          '%s<start>%f</start>',...
          '%s<size>%f</size>',...
          '%s<units>%s</units>'],...
        OPT.indent,OPT.start,OPT.indent,OPT.size,OPT.indent,OPT.units);
end

