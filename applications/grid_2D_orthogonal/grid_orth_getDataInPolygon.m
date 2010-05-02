function [X, Y, Z, Ztime, OPT] = grid_orth_getDataInPolygon(varargin)
%GRID_ORTH_GETDATAINPOLYGON  Script to load fixed maps from OPeNDAP, identify which maps are located inside a polygon and retrieve the data
%
%   Script to load fixed maps from OPeNDAP (or directory), identify which maps are located
%   inside a polygon and retrieve the data. This script is based on the
%   rws_getDataInPolygon script. This grid_orth_ version is more generic.
%
%       [X, Y, Z, Ztime] = grid_orth_getDataInPolygon(<keyword,value>);
%
%   Input:
%   where the following <keyword,value> pairs have been implemented (values indicated are the current default settings):
%   	'dataset'     , URL                   = URL for fixed map dataset to use ('http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml')
%   	'starttime'   , datenum([1997 01 01]) = indicates starttime (datenum) from which to look back or forward (depending on searchwindow setting)
%   	'searchwindow', -2*365                = indicates search window in number of days ([-] backward in time, [+] forward in time)
%   	'polygon'     , []                    = polygon to use gathering the data (should preferably be closed) [-]
%   	'cellsize'    , []                    = cellsize of fixed grid (same cellsize assumed in both directions) [-]
%   	'datathinning', 1                     = factor used to stride through the data [-]
%       'plotresult'  , 1                     = indicates whether the output should be plotted
%
%   Output:
%       X
%       Y
%       Z
%
%
%   Example:
%
%    polygon = [59090.8 438855
%    	58110.4 439599
%    	59293.6 441289
%    	60409.3 440512
%    	59090.8 438855];
%
%    datasets = {...
%        'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml';
%        'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/jarkus/grids/catalog.xml'};
%
%    for i = 1:length(datasets)
%        close all
%        [X, Y, Z, Ztime] = grid_orth_getDataInPolygon(...
%            'dataset', datasets{i}, ...
%            'starttime', datenum([2010 06 01]), ...
%            'searchwindow', -10*365, ...
%            'datathinning', 1, ...
%            'polygon', polygon);
%        pause
%    end
%
%
% Works for all bathymetry data that is stored in so-called fixed map style
%
% See also: grid_2D_orthogonal

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
OPT.dataset         = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/jarkus/grids/catalog.xml';
OPT.tag             = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/jarkus/grids/catalog.xml';
OPT.ldburl          = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland.nc';
OPT.workdir         = 'D:\checkouts\VO-rawdata\projects\151027_maasvlakte_2\scripts\sedbudget\';
OPT.polygondir      = 'D:\checkouts\VO-rawdata\projects\151027_maasvlakte_2\scripts\sedbudget\polygons\';
OPT.polygon         = [];
OPT.cellsize        = [];                               % left empty will be determined automatically
OPT.datathinning    = 1;                                % stride with which to skip through the data
OPT.inputtimes      = datenum((2000:2008)',12, 31);     % starting points (in Matlab epoch time)
OPT.starttime       = OPT.inputtimes(1);
OPT.searchinterval  = -730;                             % acceptable interval to include data from (in days)
OPT.min_coverage    = 25;                               % coverage percentage (can be several, e.g. [50 75 90]
OPT.plotresult      = 1;
OPT.warning         = 1;
OPT.postProcessing  = 1;
OPT.whattodo        = 1;
OPT.type            = 1;
OPT.counter         = 0;
OPT.OPT             = [];

OPT = setProperty(OPT, varargin{:});

%% Step 0: create a figure with tagged patches
axes = findobj('type','axes');
if isempty(axes) || ~any(ismember(get(axes, 'tag'), {OPT.tag})) % if an overview figure is already present don't run this function again
    
    % Step 0.1: get fixed map urls from OPeNDAP server
    if ~isempty(OPT.OPT)
        urls = OPT.OPT.urls;
    else
        urls = opendap_catalog(OPT.dataset);
    end
    % Step 0.2: create a figure with tagged patches
    figure(10);clf;axis equal;box on;hold on
    
    % Step 0.3: plot landboundary
    try % try loop to prevent crashing when no internet connection is available
        OPT.x = nc_varget(OPT.ldburl, nc_varfind(OPT.ldburl, 'attributename', 'standard_name', 'attributevalue', 'projection_x_coordinate'));
        OPT.y = nc_varget(OPT.ldburl, nc_varfind(OPT.ldburl, 'attributename', 'standard_name', 'attributevalue', 'projection_y_coordinate'));
        plot(OPT.x, OPT.y, 'k', 'linewidth', 2);
    end
    
    % Step 0.4: plot fixed map patches on axes and return the axes handle
    ah = grid_orth_createFixedMapsOnAxes(gca, OPT.OPT, 'tag', OPT.tag); %#ok<*NODEF,*NASGU>
end

%% Step 1: go to the axes with tagged patches and select fixed maps using a polygon
ah = findobj('type','axes','tag',OPT.tag);
try delete(findobj(ah,'tag','selectionpoly'));  end %#ok<*TRYNC> delete any remaining poly

% if no polygon is available yet draw one
if isempty(OPT.polygon)
    % make sure the proper axes is current
    try axes(ah); end
    
    jjj = menu({'Zoom to your place of interest first.',...
        'Next select one of the following options.',...
        'Finish clicking of a polygon with the <right mouse> button.'},...
        '1. click a polygon',...
        '2. click a polygon and save to file',...
        '3. load a polygon from file');
    
    if jjj<3
        % draw a polygon using polydraw making sure it is tagged properly
        disp('Please click a polygon from which to select data ...')
        [x,y] = polydraw('g','linewidth',2,'tag','selectionpoly');
        
    elseif jjj==3
        % load and plot a polygon
        [fileName, filePath] = uigetfile({'*.ldb','Delt3D landboundary file (*.ldb)'},'Pick a landboundary file');
        [x,y]=landboundary_da('read',fullfile(filePath,fileName));
        x = x';
        y = y';
    end
    
    % save polygon
    if jjj==2
        [fileName, filePath] = uiputfile({'*.ldb','Delt3D landboundary file (*.ldb)'},'Specifiy a landboundary file',...
            ['polygon_',datestr(now)]);
        landboundary_da('write',fullfile(filePath,fileName),x,y);
    end
    
    % combine x and y in the variable polygon and close it
    OPT.polygon = [x' y'];
    OPT.polygon = [OPT.polygon; OPT.polygon(1,:)];
    
else
    
    x = OPT.polygon(:,1);
    y = OPT.polygon(:,2);
    
end

% delete the pre existing polygon and replace it with the just generated closed one

try;delete(findobj(ah,'tag','selectionpoly')); end
try axes(ah); end; hold on
if ~all(OPT.polygon(1,:)==OPT.polygon(end,:))
    OPT.polygon = [OPT.polygon;OPT.polygon(1,:)];
end
plot(OPT.polygon(:,1),OPT.polygon(:,2),'g','linewidth',2,'tag','selectionpoly'); drawnow
%axis([min(x) max(x) min(y) max(y)]) % does not work

%% Step 2: identify which maps are in polygon

[mapurls, minx, maxx, miny, maxy] = grid_orth_identifyWhichMapsAreInPolygon(OPT.OPT, OPT.polygon);

if isempty(mapurls) & OPT.warning
    
    X     = [];
    Y     = [];
    Z     = [];
    Ztime = [];
    warndlg('No data found in specified polygon');
    
else
    
    %% Step 3: retrieve data and place it on one overall grid
    [X, Y, Z, Ztime]                  = grid_orth_getDataFromNetCDFGrids(mapurls, minx, maxx, miny, maxy, OPT);
    
    if all(isnan(Ztime)) & OPT.warning
        warndlg('No data found in specified time period (yet grids available in polygon)')
    end
    
    
    %% Step 4: plot the end result (Z and Ztime)
    if OPT.plotresult
        % reduce the number of point to plot
        OPT.datathinning = OPT.datathinning * 2;
        
        % plot X, Y, Z and X, Y, Ztime
        grid_orth_plotDataInPolygon(X, Y, Z, Ztime,'polygon',OPT.polygon,'datathinning',OPT.datathinning,'ldburl',OPT.ldburl)
    end
    
end
