function nc_cf_harvest2xml(xmlname,D,varargin)
%NC_CF_HARVEST2XML  write nested nc_cf_harvest object to THREDDS catalog.xml
%
% L = opendap_catalog  (opendap_url) % crswl
% C = nc_cf_harvest    (L)
%     nc_cf_harvest2xml(xmlname,C)
%
% writes nested (non-flat) nc_cf_harvest object D to THREDDS catalog.xml file.
%
%See also: NC_CF_HARVEST, nc_cf_harvest2nc, nc_cf_harvest2xls,
%          thredds_dump, thredds_info

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011-2013 Deltares for Nationaal Modellen en Data centrum (NMDC),
%                           Building with Nature and internal Eureka competition.
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

% https://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.3/InvCatalogSpec.server.html

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

OPT = setproperty(OPT,varargin);

fid = fopen(xmlname,'w');

output = fprintf(fid,'%s\n',['<?xml version="1.0" encoding="UTF-8"?>']);
output = fprintf(fid,'%s\n',['<catalog xmlns="http://www.unidata.ucar.edu/namespaces/thredds/InvCatalog/v1.0" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.0.1">']);
output = fprintf(fid,'%s\n',['  <service name="allServices"   serviceType="Compound" base="">']);
output = fprintf(fid,'%s\n',['    <service name="dapService"  serviceType="OPENDAP"  base="/thredds/dodsC/"/>']);
output = fprintf(fid,'%s\n',['    <service name="httpService" serviceType="Download" base="/thredds/fileServer/"/>']);
output = fprintf(fid,'%s\n',['  </service>']);

output = fprintf(fid,'%s\n',['  <dataset name="',path2os(OPT.name,'http'),'" ID="varopendap/',path2os(OPT.ID,'http'),'">']);

output = fprintf(fid,'%s\n',['    <metadata inherited="true">']);
output = fprintf(fid,'%s\n',['      <serviceName>allServices</serviceName>']);
output = fprintf(fid,'%s\n',['      <dataType>',OPT.dataType,'</dataType>']);
output = fprintf(fid,'%s\n',['      <documentation xlink:href ="',  OPT.documentation.url,'"']); 
output = fprintf(fid,'%s\n',['                     xlink:title="',  OPT.documentation.title,'"/>']);
output = fprintf(fid,'%s\n',['      <documentation type="Summary">',OPT.documentation.summary,'</documentation>']);
if 0
output = fprintf(fid,'%s\n',['      <creator>']);
output = fprintf(fid,'%s\n',['        <name vocabulary="DIF">',OPT.creator.name,'</name>']);
output = fprintf(fid,'%s\n',['        <contact url="',         OPT.creator.contact.url,'" email="',OPT.creator.contact.email,'"/>']);
output = fprintf(fid,'%s\n',['      </creator>']);
output = fprintf(fid,'%s\n',['      <publisher>']);
output = fprintf(fid,'%s\n',['        <name vocabulary="DIF">',OPT.publisher.name,'</name>']);
output = fprintf(fid,'%s\n',['        <contact url="',         OPT.publisher.contact.url,'" email="',OPT.publisher.contact.email,'"/>']);
output = fprintf(fid,'%s\n',['      </publisher>']);

% <variables vocabulary="CF-1.0">
%   <variable name="wv" vocabulary_name="Wind Speed" units="m/s">Wind Speed @ surface</variable>
%   <variable name="wdir" vocabulary_name="Wind Direction" units= "degrees">Wind Direction @ surface</variable>
%   <variable name="o3c" vocabulary_name="Ozone Concentration" units="g/g">Ozone Concentration @ surface</variable>
% </variables>

end 
output = fprintf(fid,'%s\n',['    </metadata>']);

if length(D) ==1
   D0 = D;
   n  = length(D.urlPath);
else
   n  = length(D);
end

   for i=1:n
   
      if exist('D0')
         D = nc_cf_harvest_subs(D0,i);
         j=1;
      else
         j=i;
      end

      output = fprintf(fid,'%s\n',['']);

      output = fprintf(fid,'%s\n',['<dataset name   ="',             filenameext(D(j).urlPath) '"']);
      output = fprintf(fid,'%s\n',['ID     ="varopendap/',OPT.ID,'/',filenameext(D(j).urlPath),'"']);
      output = fprintf(fid,'%s\n',['urlPath=   "opendap/',OPT.ID,'/',filenameext(D(j).urlPath),'">']);

      %% files (thredds auto metadata)
      if isfield(D(j),'dataSize') && ~isnan(D(j).dataSize)
      output = fprintf(fid,'%s\n',['<dataSize units="Mbytes">',num2str(D(j).dataSize./1e6)                ,'</dataSize>']);
      end
      if isfield(D(j),'date') && ~isnan(D(j).date)
      output = fprintf(fid,'%s\n',['<date type="modified">'   ,datestr(D(j).date,'yyyy-mm-dd:HH:MM'),'</date>']);
      end

      %% space
      output = sprintf(['<geospatialCoverage>'...
                        '\n<northsouth>%s'...
                        '</northsouth>'...
                        '\n<eastwest>%s'...
                        '</eastwest>'...
                        '\n<updown>%s'...
                        '</updown>'...
                        '</geospatialCoverage>\n'],...
          opendap_spatialRange_write('start',D(j).geospatialCoverage.northsouth.start,'stop',D(j).geospatialCoverage.northsouth.end,'units','degrees_north'),...
          opendap_spatialRange_write('start',D(j).geospatialCoverage.eastwest.start  ,'stop',D(j).geospatialCoverage.eastwest.end  ,'units','degrees_east'),...
          opendap_spatialRange_write('start',D(j).geospatialCoverage.updown.start    ,'stop',D(j).geospatialCoverage.updown.end    ,'units','m'));
      fprintf(fid,output);

      %% time
      output = sprintf(['<timeCoverage><start>\n'...
                        '%s</start><end>\n'...
                        '%s</end>\n'...
                        '</timeCoverage>\n'],...
          datestr(D(j).timeCoverage.start,'yyyy-mm-ddTHH:MM:SS'),...
          datestr(D(j).timeCoverage.end  ,'yyyy-mm-ddTHH:MM:SS'));
      fprintf(fid,output);

      %% variables
      output = fprintf(fid,'<variables vocabulary="%s">\n',D(j).Conventions);
      for ivar=1:length(D(j).variable_name)
      output = fprintf(fid, '<variable name="%s" ',D(j).variable_name{ivar});
      output = fprintf(fid,'vocabulary_name="%s" ',D(j).standard_name{ivar});
      output = fprintf(fid,          'units="%s" ',D(j).units{ivar}        );
      output = fprintf(fid,'>%s</variable>\n'     ,D(j).long_name{ivar}    );
      end
      output = fprintf(fid,'%s\n',['</variables>']);        
      
      output = fprintf(fid,'%s\n',['</dataset>']);
      
   end % i
      
output = fprintf(fid,'%s\n',['  </dataset>']);
output = fprintf(fid,'%s\n',['</catalog>']);
fclose(fid);
      
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
%     <xsd:element name="northsouth" type="spatialRange"         minOccurs="0" />
%     <xsd:element name="eastwest"   type="spatialRange"         minOccurs="0" />
%     <xsd:element name="updown"     type="spatialRange"         minOccurs="0" />
%     <xsd:element name="name"       type="controlledVocabulary" minOccurs="0" maxOccurs="unbounded"/>
%   </xsd:sequence>
%     
%   <xsd:attribute name="zpositive" type="upOrDown" default="up"/>
%  </xsd:complexType>
% </xsd:element>
% 
% <xsd:complexType name="spatialRange">
%  <xsd:sequence>
%    <xsd:element name="start"      type="xsd:double" />
%    <xsd:element name="size"       type="xsd:double" />
%    <xsd:element name="resolution" type="xsd:double" minOccurs="0" />
%    <xsd:element name="units"      type="xsd:string" minOccurs="0" />
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
'%s<start>\n%f</start>',...
'%s<size>\n%f</size>',...
'%s<resolution>\n%s</resolution>',...
'%s<units>%s</units>'],...
	OPT.indent,OPT.start,OPT.indent,OPT.size,OPT.indent,OPT.resolution,OPT.indent,OPT.units);
else
    output = sprintf([...
'%s<start>\n%f</start>',...
'%s<size>\n%f</size>',...
'%s<units>%s</units>'],...
	OPT.indent,OPT.start,OPT.indent,OPT.size,OPT.indent,OPT.units);
end

function D1 = nc_cf_harvest_subs(D,j)

D1.geospatialCoverage.northsouth.start = D.geospatialCoverage_northsouth_start(j);
D1.geospatialCoverage.eastwest.start   = D.geospatialCoverage_eastwest_start  (j);
D1.geospatialCoverage.updown.start     = D.geospatialCoverage_updown_start    (j);
D1.geospatialCoverage.northsouth.end   = D.geospatialCoverage_northsouth_end  (j);
D1.geospatialCoverage.eastwest.end     = D.geospatialCoverage_eastwest_end    (j);
D1.geospatialCoverage.updown.end       = D.geospatialCoverage_updown_end      (j); 
D1.urlPath                             = D.urlPath           (j);
D1.timeCoverage.start                  = D.timeCoverage_start(j);
D1.timeCoverage.end                    = D.timeCoverage_end  (j);
D1.dataSize                            = D.dataSize          (j);
D1.date                                = D.date              (j);
D1.Conventions                         = D.Conventions       {j};
D1.variable_name                       = strtokens2cell(D.variable_name{j});
D1.standard_name                       = strtokens2cell(D.standard_name{j});
D1.units                               = strtokens2cell(D.units        {j});
D1.long_name                           = strtokens2cell(D.long_name    {j});

