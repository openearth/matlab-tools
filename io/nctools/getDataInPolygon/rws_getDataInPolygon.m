function [X, Y, Z, Ztime] = getDataInPolygon(varargin)
%rws_GETDATAINPOLYGON  Script to load fixed maps from OPeNDAP, identify which maps are located inside a polygon and retrieve the data 
%
%   rws_GETDATAINPOLYGON(<keyword,value>)
%
%   Input:
%   where the following <keyword,value> pairs have been implemented (values indicated are the current default settings):
%   	'datatype'    , 'vaklodingen'         = type indicator for fixed map dataset to use ('jarkus', 'vaklodingen')
%   	'starttime'   , datenum([1997 01 01]) = indicates starttime (datenum) from which to look back or forward (depending on searchwindow setting)
%   	'searchwindow', -2*365                = indicates search window in number of days ([-] backward in time, [+] forward in time)
%   	'polygon'     , []                    = polygon to use gathering the data (should preferably be closed) [-]
%   	'cellsize'    , 20                    = cellsize of fixed grid (same cellsize assumed in both directions) [-]
%   	'datathinning', 1                     = factor used to stride through the data [-]
%
%   Output:
%       function has no output
%
%   Example:
%
% Works for Rijkswaterstaat JarKus and Vaklodingen.(default)
%
% See also: rws_getFixedMapOutlines, rws_createFixedMapsOnAxes, rws_identifyWhichMapsAreInPolygon, rws_getDataFromNetCDFGrid

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

OPT.datatype     = 'vaklodingen';
OPT.starttime    = datenum([1997 01 01]);
OPT.searchwindow = -2*365;
OPT.polygon      = [];
OPT.cellsize     = 20;
OPT.datathinning = 1;
OPT.ldburl       = 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/deltares/landboundaries/holland.nc';

OPT = setProperty(OPT, varargin{:});

%% Step 0: create a figure with tagged patches
axes = findobj('type','axes');
if isempty(axes) || ~any(ismember(get(axes, 'tag'), {OPT.datatype})) % if an overview figure is already present don't run this function again

    % Step 0.1: get fixed map urls from OPeNDAP server
    urls = rws_getFixedMapOutlines(OPT.datatype); %#ok<*UNRCH,*USENS>
    
    % Step 0.2: create a figure with tagged patches
    figure(10);clf;axis equal;box on;hold on
    
    % Step 0.3: plot landboundary
    OPT.x = nc_varget(OPT.ldburl, lookupVarnameInNetCDF('ncfile', OPT.ldburl, 'attributename', 'standard_name', 'attributevalue', 'projection_x_coordinate'));
    OPT.y = nc_varget(OPT.ldburl, lookupVarnameInNetCDF('ncfile', OPT.ldburl, 'attributename', 'standard_name', 'attributevalue', 'projection_y_coordinate'));
    plot(OPT.x, OPT.y, 'k', 'linewidth', 2);
    
    % Step 0.4: plot fixed map patches on axes and return the axes handle
    ah = rws_createFixedMapsOnAxes(gca, urls, 'tag', OPT.datatype); %#ok<*NODEF,*NASGU>
    
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
    disp('Please click a polygon from which to select data ...')
    [x,y] = drawpolygon('g','linewidth',2,'tag','selectionpoly');
    
    % combine x and y in the variable polygon and close it
    OPT.polygon = [x' y'];
    OPT.polygon = [OPT.polygon; OPT.polygon(1,:)];
end

% delete the pre existing polygon and replace it with the just generated closed one
delete(findobj(ah,'tag','selectionpoly')); try axes(ah); end; hold on
plot(OPT.polygon(:,1),OPT.polygon(:,2),'g','linewidth',2,'tag','selectionpoly'); drawnow

%% Step 2: identify which maps are in polygon
[mapurls, minx, maxx, miny, maxy] = rws_identifyWhichMapsAreInPolygon(ah, OPT.polygon);

%% Step 3: retrieve data and place it on one overall grid
[X, Y, Z, Ztime] = rws_data2grid(mapurls, minx, maxx, miny, maxy, OPT);

%% Step 4: plot the end result (Z and Ztime)
% reduce the number of point to plot
OPT.datathinning = OPT.datathinning * 2;

% plot X, Y, Z and X, Y, Ztime
rws_plotDataInPolygon(X, Y, Z, Ztime,'polygon',OPT.polygon,'datathinning',OPT.datathinning,'ldburl',OPT.ldburl)
