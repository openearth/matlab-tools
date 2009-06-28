function getDataInPolygon(varargin)
%GETDATAINPOLYGON  Script to load fixed maps from OPeNDAP, identify which maps are located inside a polygon and retrieve the data 
%
%   Syntax:
%   getDataInPolygon(varargin)
%
%   Input:
%   For the following keywords, values are accepted (values indicated are the current default settings):
%   	'datatype', 'jarkus'                = type indicator for fixed map dataset to use ('jarkus', 'vaklodingen')
%   	'starttime', datenum([1997 01 01])  = indicates starttime (datenum) from which to look back or forward (depending on searchwindow setting)
%   	'searchwindow', -2*365              = indicates search window in number of days ([-] backward in time, [+] forward in time)
%   	'polygon', []                       = polygon to use gathering the data (should preferably be closed) [-]
%   	'cellsize', 20                      = cellsize of fixed grid (same cellsize assumed in both directions) [-]
%   	'datathinning', 1                   = factor used to stride through the data [-]
%
%   Output:
%       function has no output
%
%   Example:
%
% See also: getDataInPolygon_test, getFixedMapOutlines, createFixedMapsOnAxes, identifyWhichMapsAreInPolygon, getDataFromNetCDFGrid

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

%% TODO: the script does not work yet for all thinning factors. Some counter problems remain.

OPT = struct(...
    'datatype', 'jarkus', ...
    'starttime', datenum([1997 01 01]), ...
    'searchwindow', -2*365, ...
    'polygon', [], ...
    'cellsize', 20, ...
    'datathinning', 1);

OPT = setProperty(OPT, varargin{:});

%% Step 0: create a figure with tagged patches
axes = findobj('type','axes');
if isempty(axes) || ~any(ismember(get(axes, 'tag'), {OPT.datatype})) % if an overview figure is already present don't run this function again
    % Step 0.1: get fixed map urls from OPeNDAP server
    urls = getFixedMapOutlines(OPT.datatype); %#ok<*UNRCH,*USENS>
    
    % Step 0.2: create a figure with tagged patches
    figure(1);clf;axis equal;box on;hold on
    
    % Step 0.3: plot landboundary
    ldburl = 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/deltares/landboundaries/holland.nc';
    x      = nc_varget(ldburl, lookupVarnameInNetCDF('ncfile', ldburl, 'attributename', 'standard_name', 'attributevalue', 'projection_x_coordinate'));
    y      = nc_varget(ldburl, lookupVarnameInNetCDF('ncfile', ldburl, 'attributename', 'standard_name', 'attributevalue', 'projection_y_coordinate'));
    plot(x, y, 'k', 'linewidth', 2);
    
    % Step 0.4: plot fixed map patches on axes and return the axes handle
    ah = createFixedMapsOnAxes(gca, urls, 'tag', OPT.datatype); %#ok<*NODEF,*NASGU>
end

%% Step 1: go to the axes with tagged patches and select fixed maps using a polygon
ah = findobj('type','axes','tag',OPT.datatype);
try delete(findobj(ah,'tag','selectionpoly'));  end %#ok<*TRYNC> delete any remaining poly
try close(2);                                   end % close the bathy plot figure
try close(3);                                   end % close the times plot figure

% if no polygon is available yet draw one
if isempty(OPT.polygon)
    % make sure the proper axes is current
    try axes(ah); end
    
    % draw a polygon using Gerben's drawpolygon routine making sure its tagged properly
    [x,y] = drawpolygon('g','linewidth',2,'tag','selectionpoly');
    
    % combine x and y in the variable polygon and close it
    OPT.polygon = [x' y'];
    OPT.polygon = [OPT.polygon; OPT.polygon(1,:)];
end

% delete the pre existing polygon and replace it with the just generated closed one
delete(findobj(ah,'tag','selectionpoly')); try axes(ah); end; hold on
plot(OPT.polygon(:,1),OPT.polygon(:,2),'g','linewidth',2,'tag','selectionpoly'); drawnow

%% Step 2: identify which maps are in polygon
[mapurls, minx, maxx, miny, maxy] = identifyWhichMapsAreInPolygon(ah, OPT.polygon);

%% Step 3: retrieve data and place it on one overall grid
[X, Y, Z, Ztime] = data2grid(mapurls, minx, maxx, miny, maxy, OPT);

%% Step 4: plot the end result (Z and Ztime)
% reduce the number of point to plot
OPT.datathinning = OPT.datathinning * 2;

% plot X, Y, Z and X, Y, Ztime
plotDataInPolygon(X, Y, Z, Ztime, OPT)
