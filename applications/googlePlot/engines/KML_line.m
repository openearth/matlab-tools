function [output] = KML_line(lat,lon,z,OPT)
% KML_LINE write a kml line
%
% See also: KML_footer, KML_header, KML_poly, KML_style, KML_stylePoly,
% KML_text, KML_upload

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Thijs Damsma
%
%       Thijs.Damsma@deltares.nl	
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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% preprocess visibility
if  ~OPT.visibility
    visibility = '<visibility>0</visibility>\n';
else
    visibility = '';
end
%% preprocess extrude
if  OPT.extrude
    extrude = '<extrude>1</extrude>\n';
else
    extrude = '';
end
%% preproces timespan
if  ~isempty(OPT.timeIn)
    if ~isempty(OPT.timeOut)
        timeSpan = sprintf([...
            '<TimeSpan>\n'...
            '<begin>%s</begin>\n'...OPT.timeIn
            '<end>%s</end>\n'...OPT.timeOut
            '</TimeSpan>\n'],...
            OPT.timeIn,OPT.timeOut);
    else
        timeSpan = sprintf([...
            '<TimeStamp>\n'...
            '<when>%s</when>\n'...OPT.timeIn
            '</TimeStamp>\n'],...
            OPT.timeIn);
    end
else
    timeSpan ='';
end
%% preproces altitude mode
if strcmpi(z,'clampToGround')
    altitudeMode = sprintf([...
        '<altitudeMode>clampToGround</altitudeMode>\n']); %#ok<NBRAK>
    z = zeros(size(lon));
else
    altitudeMode = sprintf([...
        '%s'...extrude
        '<altitudeMode>absolute</altitudeMode>\n'],...
        extrude);
end
%% put all coordinates in one vector and split vector at nan's

coordinates=[lon(:)'; lat(:)'; z(:)'];
nanindex=find(any(isnan(coordinates),1));
nanindex(end+1)=length(coordinates(1,:))+1;

coords{1}=coordinates(:,1:nanindex(1)-1);
if length(nanindex)>1
    for ii=2:length(nanindex);
        coords{ii}=coordinates(:,nanindex(ii-1)+1:nanindex(ii)-1); %#ok<AGROW>
    end
end

output = [];
for ii = 1:length(coords)
if ~isempty(coords(ii))
%% get coordinaets
    coordinates  = sprintf(...
        '%3.8f,%3.8f,%3.3f ',...coords);
        coords{ii});
%% generate output
    output = [output sprintf([...
        '<Placemark>\n'...
        '%s'...visibility
        '%s'...timeSpan
        '<name>%s</name>\n'...,OPT.name);
        '<styleUrl>#%s</styleUrl>\n'...,OPT.styleName);
        '<LineString>\n'...
        '%s'...extrude
        '%s'...altitudeMode
        '<coordinates>\n'...
        '%s'...coordinates
        '</coordinates>\n',...
        '</LineString>\n'...
        '</Placemark>\n'],...
        visibility,timeSpan,OPT.name,OPT.styleName,extrude,altitudeMode,coordinates)];
end
end