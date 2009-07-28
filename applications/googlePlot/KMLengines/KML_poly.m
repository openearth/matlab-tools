function [output] = KML_poly(lat,lon,z,varargin)
%KML_POLY  low-level routine for creating KML string of polygon
%
% <documentation not yet finished>
%
% See also: KML_footer, KML_header, KML_line, KML_style, KML_stylePoly,
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
OPT.extrude    = 0;
OPT.timeIn     = [];
OPT.timeOut    = [];
OPT.name       = '';

OPT = setProperty(OPT,varargin{:});

if isempty(OPT.styleName)
   warning('property ''stylename'' required')
end

%%

if all(isnan(z(:)))
    output = '';
    return
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
%% preproces coordinates
coords=[lon(:)'; lat(:)'; z(:)'];
coordinates  = sprintf(...
    '%3.8f,%3.8f,%3.3f ',...coords);
    coords);
%% generate output
output = sprintf([...
    '<Placemark>\n'...
    '%s'...visibility
    '%s'...timeSpan
    '<name>%s</name>\n'...,OPT.name);
    '<styleUrl>#%s</styleUrl>\n'...,OPT.styleName);
    '<Polygon>\n'...
    '%s'...altitudeMode
    '<outerBoundaryIs>\n'...
    '<LinearRing>\n'...
    '<coordinates>\n'...
    '%s'...coordinates
    '</coordinates>\n',...
    '</LinearRing>\n'...
    '</outerBoundaryIs>\n'...
    '</Polygon>\n'...
    '</Placemark>\n'],...
    visibility,timeSpan,OPT.name,OPT.styleName,altitudeMode,coordinates);

%% EOF