function [mapurls, minx, maxx, miny, maxy] = rws_identifyWhichMapsAreInPolygon(ah, polygon)
error('This function is deprecated in favour of grid_orth_identifyWhichMapsAreInPolygon')
%RWS_IDENTIFYWHICHMAPSAREINPOLYGON  Script to identify which fixed maps are located inside a polygon partly or as a whole
%
% See also: rws_createFixedMapsOnAxes, rws_createFixedMapsOnFigure,
%   rws_data2grid, rws_getDataFromNetCDFGrid, rws_getDataFromNetCDFGrid_test,
%   rws_getDataInPolygon, rws_getDataInPolygon_test, rws_getFixedMapOutlines,
%   rws_identifyWhichMapsAreInPolygon, rws_plotDataInPolygon, getDataFromNetCDFGrid

% --------------------------------------------------------------------
% Copyright (C) 2004-2009 Delft University of Technology
% Version:      Version 1.0, February 2004
%     Mark van Koningsveld
%
%     m.vankoningsveld@tudelft.nl	
%
%     Hydraulic Engineering Section 
%     Faculty of Civil Engineering and Geosciences
%     Stevinweg 1
%     2628CN Delft
%     The Netherlands
%
% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Lesser General Public
% License as published by the Free Software Foundation; either
% version 2.1 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
% Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public
% License along with this library; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
% USA
% --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$

%% select all data that is inpolygon
% Step 1: find all patch objects from the mapwindow and store their xdata and ydata in the variable maps
objs = findobj(ah, 'type', 'patch', '-regexp','Tag','[''*.nc'']');
maps = [get(objs, 'XData') get(objs, 'YData')];
if ~iscell(maps),maps = {maps(:,1) maps(:,2)};end

% Step 2: identify which of the fixed maps lie whole or partially inpolygon initialise variables
[mapurls, minx, maxx, miny, maxy] = deal([]);
include = 0;
for i = 1:size(maps,1)
    % include if a fixed map and polygon have an intersection

    [xcr, zcr] = findCrossingsOfPolygonAndPolygon(maps{i,1},maps{i,2},polygon(:,1),polygon(:,2)); %#ok<*NASGU>
   %[xcr, zcr] = polyintersect                   (maps{i,1},maps{i,2},polygon(:,1),polygon(:,2)); %#ok<*NASGU>

    if ~isempty(xcr)
        include = 1;
    end
        
    % include if a fixed map lies within the polygon
    if inpolygon(maps{i,1},maps{i,2},polygon(:,1),polygon(:,2));
        include = 2;
    end
    
    % include if a polygon lies within a fixed map
    if inpolygon(polygon(:,1),polygon(:,2),maps{i,1},maps{i,2});
        include = 3;
    end
    
    % see if based on the above there is something to include
    if include > 0 %& (~isempty(strfind(get(objs(i),'tag'),'vaklodingenKB'))|~isempty(strfind(get(objs(i),'tag'),'jarkusKB'))) %#ok<*OR2,*AND2>
        mapurls{end+1,1} = get(objs(i),'tag');
        minx = min([minx; maps{i,1}]);
        maxx = max([maxx; maps{i,1}]);
        miny = min([miny; maps{i,2}]);
        maxy = max([maxy; maps{i,2}]);
        include = 0;
    else 
        include = 0;
    end
    
end
