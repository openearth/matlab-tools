function [X, Y, Z, Ztime] = grid_orth_getDataFromNetCDFGrids(mapurls, minx, maxx, miny, maxy, varargin)
%GRID_ORTH_GETDATAFROMNETCDFGRIDS Get data in fixed otrhogonal grid from bundle of netCDF files.
%
%   [X, Y, Z, Ztime] = grid_orth_getDataFromNetCDFGrids(mapurls, minx, maxx, miny, maxy, <keyword,value>)
%
% extracts data from a series of netCDF files to fill a defined orthogonal grid.
% Only data at grid intersection lines is read, no min/max/mean is performed.
%
% Example: start at @ http://opendap.deltares.nl
%
%    url     = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml'
%    mapurls = opendap_catalog(url);
%
%    [X, Y, Z, Ztime] = grid_orth_getDataFromNetCDFGrids(mapurls, 90e3, 100e3, 300e3, 400e3,'dx',200,'dy',200);
%
% For additional keywords see: grid_orth_getDataFromNetCDFGrid
%
% See also: grid_2D_orthogonal, grid_orth_getDataFromNetCDFGrid

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Mark van Koningsveld
%
%       m.vankoningsveld@tudelft.nl
%
%       Hydraulic Engineering Section
%       Faculty of Civil Engineering and Geosciences
%       Stevinweg 1
%       2628CN Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

OPT.dataset         = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml';
OPT.catalognc       = [];                               % is the catalog nc file if it exists
OPT.tag             = [];
OPT.ldburl          = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland.nc';
OPT.workdir         = pwd;
OPT.polygondir      = [];
OPT.polygon         = [];
OPT.cellsize        = [];                               % cellsize is assumed to be regular in x and y direction and is determined automatically
OPT.datathinning    = 1;                                % stride with which to skip through the data
OPT.inputtimes      = [];                               % starting points (in Matlab epoch time)
OPT.starttime       = [];
OPT.searchinterval  = -730;                             % acceptable interval to include data from (in days)
OPT.min_coverage    = .25;                               % coverage percentage (can be several, e.g. [50 75 90]
OPT.plotresult      = 1;                                % 0 = off; 1 = on;
OPT.warning         = 1;                                % 0 = off; 1 = on;
OPT.postProcessing	= 1;                                % 0 = off; 1 = on;
OPT.whattodo(1)     = 1;                                % volume plots
OPT.type            = 1;
OPT.counter         = 0;
OPT.urls            = [];
OPT.x_ranges        = [];
OPT.y_ranges        = [];
OPT.x               = [];
OPT.y               = [];

OPT.dx             = [];
OPT.dy             = [];

OPT = setproperty(OPT,varargin{:});

% get cell size
%urls      = grid_orth_getFixedMapOutlines(OPT.dataset);
x         = nc_varget(mapurls{1}, nc_varfind(mapurls{1}, 'attributename', 'standard_name', 'attributevalue', 'projection_x_coordinate')); 
OPT.cellsize = mean(diff(x));

if isempty(OPT.dx)
    OPT.dx = OPT.cellsize*OPT.datathinning;
end

if isempty(OPT.dy)
    OPT.dy = OPT.cellsize*OPT.datathinning;
end

% generate x and y vectors spanning the fixed map extents
x         = minx : OPT.dx  : maxx;
x         = roundoff(x,2); maxx =  roundoff(maxx,2);
if x(end)~= maxx; x = [x maxx];end % make sure maxx is included as a point

y         = maxy : -OPT.dy : miny; % thinning runs from the lower left corner upward and right
y         = roundoff(y,2); miny =  roundoff(miny,2);
if y(end)~=miny; y = [y miny];end % make sure miny is included as a point

nrcols    = max(size(x));
nrofrows  = max(size(y));

% create the dummy X, Y, Z and Ztemps grids
X      = ones(nrofrows,1); X=X*x;      %X = roundoff(X, 6); - no longer needed if roundoff is already called above
Y      = ones(1,nrcols);   Y=y'*Y;     %Y = roundoff(Y, 6); - no longer needed if roundoff is already called above 
Z      = ones(size(X));    Z(:,:)=nan;
Ztime  = Z;

% clear unused variables to save memory
clear x y minx maxx miny maxy

% no one by one 
for i = 1:length(mapurls)
    % report on progress
    disp(' ')
    [pathstr, name, ext] = fileparts(mapurls{i,1}); %#ok<*NASGU>
    disp(['Processing (' num2str(i) '/' num2str(length(mapurls)) ') : ' name ext])
    
    % get data and plot
    [x, y, z, zt] = grid_orth_getDataFromNetCDFGrid('ncfile', mapurls{i},...
                                                 'starttime',OPT.starttime,...
                                            'searchinterval',OPT.searchinterval,...
                                                   'polygon',OPT.polygon,...
                                                    'stride',[1 1 1]);

% TO DO: do not read full array from netCDF but only data depending on thinning
% TO DO: use spatial mean, min, max in addition to nearest

    % convert vectors to grids
    x = repmat(x',size(z,1),1);
    y = repmat(y, 1, size(z,2));

    idsLargeGrid = ismember(X,x) & ismember(Y,y);
    idsSmallGrid = ismember(x,X) & ismember(y,Y);
    
    % clear unused variables to save memory
    clear x y
    
    % add values to Z matrix
    Z(idsLargeGrid) = z(idsSmallGrid);
    
    % add values to Ztemps matrix
    Ztime(idsLargeGrid) = zt(idsSmallGrid); 
    
    % clear unused variables to save memory
    clear z zt
end
