function [output] = KML_line(lat,lon,z,varargin)
%KML_LINE  low-level routine for creating KML string of line
%
%   kmlstring = KML_line(lat,lon,z,<keyword,value>)
%
% where the following <keyword,value> pairs have been implemented:
%
%   * styleName   name of previously define style with KML_style
%                 (required, default 'black' being default of KML_style)
%   * visibility  0 or 1, default 1
%   * extrude     0 or 1, default 1
%   * timeIn      timestring of appearance of line, default []
%   * timeOut     timestring of appearance of line, default [];
%   * name        name of line object in kml temporary places list, default 'ans.kml'
%
% Example: a red line
%
%     fid         = fopen('a_red_line.kml','w');
%     S.name      = 'red';
%     S.lineColor = [1 0 0];  % color of the lines in RGB
%     S.lineAlpha = [1] ;     % transparency of the line, (0..1) with 0 transparent
%     S.lineWidth = 1;        % line width, can be a fraction
%
%     kml         = KML_header('name','curl');
%     kml         = [kml KML_style(S)];
%     kml         = [kml KML_line(-90:90,-180:2:180,0:1:180,'styleName',S.name)];
%     kml         = [kml KML_footer];
%     fprintf(fid,kml);
%     fclose (fid);
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

%% Properties

OPT.styleName  = [];
OPT.visibility = 1;
OPT.extrude    = [];
OPT.timeIn     = [];
OPT.timeOut    = [];
OPT.tessellate  = [];
OPT.name       = 'line';

OPT = setProperty(OPT,varargin{:});

if isempty(OPT.styleName)
    warning('property ''stylename'' required') %#ok<WNTAG>
end

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
%% preprocess tessellate
if  OPT.tessellate
    tessellate = '<tessellate>1</tessellate>\n';
else
    tessellate = '';
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
    altitudeMode =  '<altitudeMode>absolute</altitudeMode>\n';
end

%% put all coordinates in one vector and split vector at nan's
coordinates  = [lon(:)'; lat(:)'; z(:)'];
notnanindex  = find(~any(isnan(coordinates),1));
if isempty(notnanindex)
    coords_index = [1 size(coordinates,2)];
else
    coords_index = [notnanindex([true ~(notnanindex(2:end)-notnanindex(1:end-1)==1)])'...
        notnanindex([~(notnanindex(2:end)-notnanindex(1:end-1)==1) true])'];
end
output = [];
for ii = 1:size(coords_index,1)
    % coordinateString
    coordinateString  = sprintf(...
        '%3.8f,%3.8f,%3.3f ',...coords);
        coordinates(:,coords_index(ii,1):coords_index(ii,2)));
    % generate output
    output = [output sprintf([...
        '<Placemark>\n'...
        '%s'...visibility
        '%s'...timeSpan
        '<name>%s</name>\n'...,OPT.name);
        '<styleUrl>#%s</styleUrl>\n'...,OPT.styleName);
        '<LineString>\n'...
        '%s'...extrude
        '%s'...tessellate
        '%s'...altitudeMode
        '<coordinates>\n'...
        '%s'...coordinates
        '</coordinates>\n',...
        '</LineString>\n'...
        '</Placemark>\n'],...
        visibility,timeSpan,OPT.name,OPT.styleName,extrude,tessellate,altitudeMode,coordinateString)];
end