function [OPT, Set, Default] = KMLpatch3(lat,lon,z,varargin)
%KMLPATCH3 Just like patch
%
%    KMLpatch(lat,lon,<keyword,value>)
% 
% only works for a singe patch (filled polygon)
% see the keyword/value pair defaults for additional options. 
% For the <keyword,value> pairs call. 
%
% Lat and lon and z must be vectors. Each column of lat, lon and z after
% the first is interpreted as an ineer boundary (hole) of the first
% polygon.
%
%    OPT = KMLpatch()
%
% See also: googlePlot, patch

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

%% process varargin

   OPT.fileName           = '';
   OPT.kmlName            = '';
   OPT.lineWidth          = 1;
   OPT.lineColor          = [0 0 0];
   OPT.lineAlpha          = 1;
   OPT.fillColor          = [1 1 1];
   OPT.fillAlpha          = 0.3;
   OPT.fileName           = '';
   OPT.lineOutline        = true; % draws a separate line element around the polygon. Outlines the polygon, excluding extruded edge
   OPT.polyOutline        = false; % outlines the polygon, including extruded edges
   OPT.polyFill           = 1;
   OPT.openInGE           = false;
   OPT.reversePoly        = [];
   OPT.tessellate         = false;
   OPT.extrude            = true;
   OPT.text               = '';
   OPT.latText            = [];
   OPT.lonText            = [];
   OPT.precision          = 8;
   OPT.zScaleFun          = @(z) (z+20).*5;
   OPT.timeIn             = [];
   OPT.timeOut            = [];
   OPT.dateStrStyle       = 'yyyy-mm-ddTHH:MM:SS';
   
   if nargin==0
       return
   else
       OPT.latText     = lat(1);
       OPT.lonText     = lon(1);
   end

[OPT, Set, Default] = setproperty(OPT, varargin{:});
%% limited error check
    if ~isequal(size(lat),size(lon))
        error('lat and lon must be same size')
    end
    if ischar(z)
        if ~strcmp(z,'clampToGround')
            error('z and lon must be same size, or z must be a single level, or z must be clampToGround')
        end
        OPT.zScaleFun = @(z) z;
    else
        if ~isequal(size(z),size(lat));
            if numel(z) == 1
                z = zeros(size(lat))+z;
            else
                error('z and lon must be same size, or z must be a single level, or z must be clampToGround')
            end
        end
    end

%% get filename, gui for filename, if not set yet

   if isempty(OPT.fileName)
      [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as',[mfilename,'.kml']);
      OPT.fileName = fullfile(filePath,fileName);
   end

%% set kmlName if it is not set yet

   if isempty(OPT.kmlName)
      [ignore OPT.kmlName] = fileparts(OPT.fileName);
   end

%% start KML

OPT.fid=fopen(OPT.fileName,'w');

%% HEADER

OPT_header = struct(...
    'name'     ,OPT.kmlName,...
    'open'     ,0);
output = KML_header(OPT_header);

%% STYLE
OPT_stylePoly = struct(...
    'name'       ,'style',...
    'fillColor'  ,OPT.fillColor,...
    'lineColor'  ,OPT.lineColor ,...
    'lineAlpha'  ,OPT.lineAlpha,...
    'lineWidth'  ,OPT.lineWidth,...
    'fillAlpha'  ,OPT.fillAlpha,...
    'polyFill'   ,OPT.polyFill,...
    'polyOutline',OPT.polyOutline);
output = [output KML_stylePoly(OPT_stylePoly)];

%% POLYGON

OPT_poly = struct(...
   'name'      ,'',...
   'styleName' ,'style',...
   'timeIn'    ,datestr(OPT.timeIn ,OPT.dateStrStyle),...
   'timeOut'   ,datestr(OPT.timeOut,OPT.dateStrStyle),...
   'visibility',1,...
   'extrude'   ,OPT.extrude,...
   'tessellate',OPT.tessellate,...
   'precision' ,OPT.precision);

output = [output KML_poly(lat,lon,OPT.zScaleFun(z),OPT_poly)]; % make sure that lat(:),lon(:) have correct dimension nx1

if OPT.lineOutline
    OPT_line = struct(...
   'name'      ,'',...
   'styleName' ,'style',...
   'timeIn'    ,datestr(OPT.timeIn ,OPT.dateStrStyle),...
   'timeOut'   ,datestr(OPT.timeOut,OPT.dateStrStyle),...
   'visibility',1,...
   'tessellate',OPT.tessellate,...   
   'precision' ,OPT.precision);
    
    lat(end+1,:) = nan;
    lon(end+1,:) = nan;
    if ~ischar(z)
        z  (end+1,:) = nan;
    end
    output = [output KML_line(lat,lon,OPT.zScaleFun(z),OPT_line)];
end


%% text

if ~isempty(OPT.text)
    output = [output KML_text(OPT.latText,OPT.lonText,OPT.text)];
end

%% FOOTER

output = [output KML_footer];
fprintf(OPT.fid,output);

%% close KML

fclose(OPT.fid);


%% compress to kmz?

if strcmpi  ( OPT.fileName(end),'z')
    movefile( OPT.fileName,[OPT.fileName(1:end-3) 'kml'])
    zip     ( OPT.fileName,[OPT.fileName(1:end-3) 'kml']);
    movefile([OPT.fileName '.zip'],OPT.fileName)
    delete  ([OPT.fileName(1:end-3) 'kml'])
end

%% openInGoogle?

if OPT.openInGE
    system(OPT.fileName);
end

%% EOF
