function [X, Y, Z, Ztime] = rws_getDataInPolygon(varargin)
error('This function is deprecated in favour of grid_orth_getDataInPolygon')
%RWS_GETDATAINPOLYGON   load grid data inside a polygon from an OPeNDAP server
%
%       [X, Y, Z, Ztime] = rws_getDataInPolygon(<keyword,value>);
%
%   Input:
%   where the following <keyword,value> pairs have been implemented (values indicated are the current default settings):
%   	'datatype'    , 'vaklodingen'         = type indicator for fixed map dataset to use as defined in UCIT_getDatatypes
%   	'starttime'   , datenum([1997 01 01]) = indicates starttime (datenum) from which to look back or forward (depending on searchwindow setting)
%   	'searchwindow', -2*365                = indicates search window in number of days ([-] backward in time, [+] forward in time)
%   	'polygon'     , []                    = polygon to use gathering the data (should preferably be closed) [-]
%   	'cellsize'    , 20                    = cellsize of fixed grid (same cellsize assumed in both directions) [-]
%   	'datathinning', 1                     = factor used to stride through the data [-]
%       'plotresult'  , 1                     = indicates whether the output should be plotted
%
%   Output:
%       function has no output
%
%   Example:
%
% Works for Rijkswaterstaat Vaklodingen (default) and JarKus grids.
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

OPT.datatype     = '';          % dataset name from UCIT_getDatatypes
OPT.starttime    = floor(now);  % this is a datenum of the starting time to search
OPT.searchwindow = -2*365;      % this indicates the search window (nr of days, '-': backward in time, '+': forward in time)
OPT.polygon      = [];          % search polygon (default: [] use entire grid)
OPT.cellsize     = 20;
OPT.datathinning = 1;           % subsetting of datatype grid
OPT.ldbs         = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland.nc';
OPT.ldbs         = 'http://dtvirt5.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland.nc';
OPT.plotresult   = 1;

OPT = setproperty(OPT, varargin{:});

%% Step 0: create a figure with tagged patches

axes = findobj('type','axes');
if isempty(axes) || ~any(ismember(get(axes, 'tag'), {OPT.datatype})) % if an overview figure is already present don't run this function again

    datatypes = UCIT_getDatatypes;
    
   [ind, ok] = listdlg('ListString', datatypes.grid.names, .....
                       'SelectionMode', 'single', ...
                        'PromptString', 'Select the grid dataset to use', ....
                                'Name', 'Selection of grid dataset',...
                            'ListSize', [500, 300]);
                               
    % Step 0.1: get fixed map urls from OPeNDAP server
    urls = opendap_catalog(datatypes.grid.catalog{ind});
    
    OPT.ldbs  = datatypes.grid.ldbs{ind};

    % Step 0.2: create a figure with tagged patches
    figure(10);clf;axis equal;box on;hold on

    % Step 0.3: plot landboundary
    OPT.x = nc_varget(OPT.ldbs, nc_varfind(OPT.ldbs, 'attributename', 'standard_name', 'attributevalue', 'projection_x_coordinate'));
    OPT.y = nc_varget(OPT.ldbs, nc_varfind(OPT.ldbs, 'attributename', 'standard_name', 'attributevalue', 'projection_y_coordinate'));
    plot(OPT.x, OPT.y, 'k', 'linewidth', 2);

    % Step 0.4: plot fixed map patches on axes and return the axes handle
    ah = rws_createFixedMapsOnAxes(gca, urls, 'tag', OPT.datatype);

end

%% Step 1: go to the axes with tagged patches and select fixed maps using a polygon

ah = findobj('type','axes','tag',OPT.datatype);
try delete(findobj(ah,'tag','selectionpoly'));  end %> delete any remaining poly
% try close(2);                                   end % close the bathy plot figure
% try close(3);                                   end % close the times plot figure

% if no polygon is available yet draw one

if isempty(OPT.polygon)
    % make sure the proper axes is current
    try axes(ah); end
    
    jjj = menu({'Choose after zooming to corect place first.',...
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
       [x,y]=landboundary('read',fullfile(filePath,fileName));
       x = x';
       y = y';
    end

    % save polygon
    if jjj==2
       [fileName, filePath] = uiputfile({'*.ldb','Delt3D landboundary file (*.ldb)'},'Specifiy a landboundary file',...
       ['polygon_',datestr(now)]);
       landboundary('write',fullfile(filePath,fileName),x,y);
    end

    % combine x and y in the variable polygon and close it
       OPT.polygon = [x' y'];
       OPT.polygon = [OPT.polygon; OPT.polygon(1,:)];
    
end

% delete the pre existing polygon and replace it with the just generated closed one

   delete(findobj(ah,'tag','selectionpoly')); try axes(ah); end; hold on
   plot(ah,OPT.polygon(:,1),OPT.polygon(:,2),'g','linewidth',2,'tag','selectionpoly'); drawnow
   axis([min(x) min(y) max(x) max(y)]) % does not work

%% Step 2: identify which maps are in polygon

   [mapurls, minx, maxx, miny, maxy] = rws_identifyWhichMapsAreInPolygon(ah, OPT.polygon);
   
   if isempty(mapurls)
   
      X     = [];
      Y     = [];
      Z     = [];
      Ztime = [];
   
   else

%% Step 3: retrieve data and place it on one overall grid

   [X, Y, Z, Ztime] = rws_data2grid(mapurls, minx, maxx, miny, maxy, OPT);

%% Step 4: plot the end result (Z and Ztime)

if OPT.plotresult

    % plot X, Y, Z and X, Y, Ztime
    rws_plotDataInPolygon(X, Y, Z, Ztime,'polygon',OPT.polygon,'datathinning',OPT.datathinning,'ldburl',OPT.ldbs)
    
end

end