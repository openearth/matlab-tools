function varargout = KMLpatch3(lat,lon,z,varargin)
%KMLPATCH3 Just like patch
%
%    KMLpatch3(lat,lon,z,<c>,<keyword,value>)
% 
% only works for a single patch (filled polygon)
% see the keyword/value pair defaults for additional options. 
% For the <keyword,value> pairs call:
%
%    OPT = KMLpatch()
%
% Lat and lon and z must be vectors. Each column of lat, lon and z after
% the first is interpreted as an ineer boundary (hole) of the first
% polygon.
%
% See also: googlePlot, patch

% TO DO
% KMLpatch3 works for 
% * one patch: lat, lon and z must be vectors, c a scalar. Each column of 
%   lat, lon and z after the first is interpreted as an inner boundary (hole) 
%   of the first polygon.
% * a set of patches: lat, lon and z must be cell arrays, c must be an array.


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

   % deal with colorbar options first
   OPT.fileName           = '';
   OPT.kmlName            = '';
   OPT.lineWidth          = 1;
   OPT.lineColor          = [0 0 0];
   OPT.lineAlpha          = 1;
OPT.colorMap           = [];
OPT.colorSteps         = 1;
   OPT.fillAlpha          = 0.3;
   OPT.polyOutline        = false; % outlines the polygon, including extruded edges
   OPT.polyFill           = true;
   OPT.openInGE           = false;
   OPT.reversePoly        = [];
   OPT.extrude            = true;

OPT.cLim               = [];
   OPT.zScaleFun          = @(z) (z+20).*5;
   OPT.timeIn             = [];
   OPT.timeOut            = [];
   OPT.dateStrStyle       = 'yyyy-mm-ddTHH:MM:SS';
OPT.colorbar           = 1;
      OPT.fillColor          = [];

   OPT.text               = '';
   OPT.latText            = [];
   OPT.lonText            = [];
   OPT.precision          = 8;
   OPT.tessellate         = false;
   OPT.lineOutline        = true; % draws a separate line element around the polygon. Outlines the polygon, excluding extruded edge
   
   if nargin==0
      varargout = {OPT};
      return
   else
       OPT.latText     = lat(1);
       OPT.lonText     = lon(1);
   end

   if ~odd(nargin) % x,y,z,c
      if isstruct(varargin{1})
      [OPT, Set, Default] = setproperty(OPT, varargin{:});
      else
      c = varargin{1};
      [OPT, Set, Default] = setproperty(OPT, varargin{2:end});
      end
   else % x,y,z
       if isstruct(varargin{2})
       c = varargin{1};
      [OPT, Set, Default] = setproperty(OPT, varargin{2});
       else
      [OPT, Set, Default] = setproperty(OPT, varargin{:});
       end
   end
   
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


%% pre-process color data

   if   ~isempty(OPT.fillColor) &  isempty(OPT.colorMap) & OPT.colorSteps==1
       colorRGB = OPT.fillColor;
       c = 1;
   elseif  isempty(OPT.fillColor) & ~isempty(OPT.colorMap)
   
       if isempty(OPT.cLim)
          OPT.cLim         = [min(c(:)) max(c(:))];
       end
      
       colorRGB = OPT.colorMap(OPT.colorSteps);
      
       % clip c to min and max 
      
       c(c<OPT.cLim(1)) = OPT.cLim(1);
       c(c>OPT.cLim(2)) = OPT.cLim(2);
      
       %  convert color values into colorRGB index values
      
       c = round(((c-OPT.cLim(1))/(OPT.cLim(2)-OPT.cLim(1))*(OPT.colorSteps-1))+1);
    else
       
       error('fillColor and colorMap cannot be used simultaneously')
      
   end

%% start KML

   OPT.fid=fopen(OPT.fileName,'w');

   OPT_header = struct(...
       'name'     ,OPT.kmlName,...
       'open'     ,0);
   output = KML_header(OPT_header);

%% STYLE
   OPT_stylePoly = struct(...
       'name'       ,['style' num2str(1)],...
       'fillColor'  ,colorRGB(1,:),...
       'lineColor'  ,OPT.lineColor,...
       'lineAlpha'  ,OPT.lineAlpha,...
       'lineWidth'  ,OPT.lineWidth,...
       'fillAlpha'  ,OPT.fillAlpha,...
       'polyFill'   ,OPT.polyFill,...
       'polyOutline',OPT.polyOutline); 
   for ii = 1:OPT.colorSteps
       OPT_stylePoly.name = ['style' num2str(ii)];
       OPT_stylePoly.fillColor = colorRGB(ii,:);
       output = [output KML_stylePoly(OPT_stylePoly)];
   end

   % print and clear output
   
   output = [output '<!--############################-->' fprinteol];
   fprintf(OPT.fid,output);output = '';

%% POLYGON

   OPT_poly = struct(...
            'name','',...
       'styleName',['style' num2str(1)],...
          'timeIn',datestr(OPT.timeIn ,OPT.dateStrStyle),...
         'timeOut',datestr(OPT.timeOut,OPT.dateStrStyle),...
      'visibility',1,...
         'extrude',OPT.extrude,...
      'tessellate',OPT.tessellate,...
      'precision' ,OPT.precision);
   
       OPT_poly.styleName = sprintf('style%d',c);
       output = [output KML_poly(lat,lon,OPT.zScaleFun(z),OPT_poly)]; % make sure that lat(:),lon(:) have correct dimension nx1
   
   if OPT.lineOutline
       OPT_line = struct(...
            'name','',...
       'styleName','style',...
          'timeIn',datestr(OPT.timeIn ,OPT.dateStrStyle),...
         'timeOut',datestr(OPT.timeOut,OPT.dateStrStyle),...
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

   fprintf(OPT.fid,output); % print output

%% close KML

   output = KML_footer;
   fprintf(OPT.fid,output);
   fclose(OPT.fid);

%% compress to kmz?

   if strcmpi  ( OPT.fileName(end-2:end),'kmz')
       movefile( OPT.fileName,[OPT.fileName(1:end-3) 'kml'])
       zip     ( OPT.fileName,[OPT.fileName(1:end-3) 'kml']);
       movefile([OPT.fileName '.zip'],OPT.fileName)
       delete  ([OPT.fileName(1:end-3) 'kml'])
   end

%% openInGoogle?

   if OPT.openInGE
       system(OPT.fileName);
   end
   
   varargout = {};

%% EOF
