function varargin = KMLcontourf(lat,lon,z,varargin)
% KMLCONTOURF Just like contourf (BETA!!!, still sawtooh edges )
%
%    KMLcontourf(lat,lon,z,<keyword,value>)
% 
% KMLcontourf triangulates a curvi-linear grid (mesh) and then
% calls KMLtricontourf on all active cells.
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLcontourf()
%
% See also: googlePlot, KMLtricontourf, contourf

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@Deltares.nl
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
% see if height is defined 

   OPT.levels         = 10;
   OPT.fileName       = [];
   OPT.kmlName        = [];
   OPT.lineWidth      = 3;
   OPT.lineColor      = [0 0 0];
   OPT.lineAlpha      = 1;
   OPT.fillAlpha      = 1;
   OPT.polyOutline    = false;
   OPT.polyFill       = true;
   OPT.openInGE       = false;
   OPT.colorMap       = @(m) jet(m);
   OPT.colorSteps     = [];   
   OPT.timeIn         = [];
   OPT.timeOut        = [];
   OPT.is3D           = false;
   OPT.cLim           = [];
   OPT.writeLabels    = true;
   OPT.labelDecimals  = 1;
   OPT.labelInterval  = 5;
   OPT.zScaleFun      = @(z) z;
   OPT.colorbar       = 1;
   OPT.colorbartitle  = '';
   OPT.extrude        = false;
   OPT.staggered      = true;
   OPT.debug          = false;
   OPT.verySmall      = eps(30*max([lat(:);lon(:)]));
   OPT.triangularGrid = false;
   
   if nargin==0
      varargout = {OPT};
      return
   end

%% set properties

OPT = setProperty(OPT, varargin{:});

%% input check

% vectorize input


% check for nan values
if any(isnan(lat+lon))
    error('KMLtricontourf does not accept nan values (yet) in the lat and lon data')
end

% correct lat and lon
if any((abs(lat)/90)>1)
    error('latitude out of range, must be within -90..90')
end
lon = mod(lon+180, 360)-180;

% color limits
if isempty(OPT.cLim)
    OPT.cLim = ([min(z(~isnan(z(:)))) max(z(~isnan(z(:))))]);
end

%% get filename, gui for filename, if not set yet

if isempty(OPT.fileName)
    [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as',[mfilename,'.kml']);
    OPT.fileName = fullfile(filePath,fileName);
end

%% set kmlName if it is not set yet

if isempty(OPT.kmlName)
    [dummy, OPT.kmlName] = fileparts(OPT.fileName); %#ok<ASGLU>
end

%% find contours and edges
if numel(OPT.levels)==1&&OPT.levels==fix(OPT.levels)&&OPT.levels>=0
    OPT.levels = linspace(min(z(:)),max(z(:)),OPT.levels+2);
    OPT.levels = OPT.levels(1:end-1);
end

if isempty(OPT.colorSteps), OPT.colorSteps = length(OPT.levels)+1; end


if OPT.triangularGrid
    C = tricontourc(lat(1,:),lon(:,1),z,OPT.levels);
    E = edges_tri_grid(lat,lon,z);
else
    C = contours(lat,lon,z,OPT.levels);
    E = edges_structured_grid(lat,lon,z);
end

[latC,lonC,zC,contour] = KML_filledContoursProcess(OPT,E,C);




