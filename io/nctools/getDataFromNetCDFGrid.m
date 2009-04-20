function [X, Y, Z, T] = getDataFromNetCDFGrid(varargin)
%GETDATAFROMNETCDFGRID  This routine gets data from a NetCDF grid file.
%
%   This routine gets data from a NetCDF grid file
%
%   Syntax:
%   varargout = getDataFromNetCDFGrid(varargin)
%
%   Output:
%       X                           = X values
%       Y                           = Y values
%       Z                           = Z values
%       T                           = temporal signature of the data
%
%   Example
% 
%   poly = [68920.9 447892
%           69222.7 447863
%           69377.2 447909
%           69730.6 448307
%           69679.1 448608
%           69215.3 448682
%           68928.2 448631
%           68812.9 448211
%           68839.9 447961];
%
%   ncfile = 'Delflandsekust.nc'
%   
%   [X, Y, Z, T] = getDataFromNetCDFGrid('ncfile', ncfile, 'starttime', now, 'polygon', poly)
% 
%   See also: nc_dump, getDataFromNetCDFGrid_test, lookupVarnameInNetCDF

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

% Created: 24 Mar 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords:

%% settings
% defaults
OPT = struct(...
    'ncfile', [], ...                               % filename of nc file to use
    'starttime', [], ...                            % this is a datenum of the starting time to search
    'searchwindow', -30, ...                        % this indicates the search window (nr of days, '-': backward in time, '+': forward in time)
    'polygon', [], ...                              % search polygon (default: [] use entire grid) 
    'stride', [1 1 1] ...                           % stride vector indicating thinning factor
    );

% overrule default settings by property pairs, given in varargin
OPT = setProperty(OPT, varargin{:});

%% find data area of interest
X        = nc_varget(OPT.ncfile, lookupVarnameInNetCDF('ncfile', OPT.ncfile, 'attributename', 'standard_name', 'attributevalue', 'projection_x_coordinate'));
Y        = nc_varget(OPT.ncfile, lookupVarnameInNetCDF('ncfile', OPT.ncfile, 'attributename', 'standard_name', 'attributevalue', 'projection_y_coordinate'));
if ~isempty(OPT.polygon)
    % determine the extent of the polygon
    minx = min(OPT.polygon(:,1));
    maxx = max(OPT.polygon(:,1));
    miny = min(OPT.polygon(:,2));
    maxy = max(OPT.polygon(:,2));
    
    % find out which part of X and Y data lies within the extent of the polygon
    xstart   = find(X>minx, 1, 'first');
    xstop    = find(X<maxx, 1, 'last');
    ystart   = find(Y>miny, 1, 'first');
    ystop    = find(Y<maxy, 1, 'last');
else
    xstart   = 0;
    xstop    = size(X,1);
    ystart   = 0;
    ystop    = size(Y,1);
end

%% get relevant data (possibly using stride)
X        = nc_varget(OPT.ncfile, lookupVarnameInNetCDF('ncfile', OPT.ncfile, 'attributename', 'standard_name', 'attributevalue', 'projection_x_coordinate'), xstart, floor((xstop-xstart)/OPT.stride(3)), OPT.stride(3)); 
Y        = nc_varget(OPT.ncfile, lookupVarnameInNetCDF('ncfile', OPT.ncfile, 'attributename', 'standard_name', 'attributevalue', 'projection_y_coordinate'), ystart, floor((ystop-ystart)/OPT.stride(2)), OPT.stride(2)); 
Z        = zeros(size(Y,1), size(X,1))*nan;
T        = zeros(size(Y,1), size(X,1))*nan;

%% find the data files that lie within the temporal search window
t        = nc_varget(OPT.ncfile, lookupVarnameInNetCDF('ncfile', OPT.ncfile, 'attributename', 'standard_name', 'attributevalue', 'time'));
[t,idt]  = sort(t,'descend');
idt_in   = find(t<=OPT.starttime & t >= OPT.starttime + OPT.searchwindow);

%% one by one place separate grids on overall grid
for id_t = [idt(idt_in)-1]' %#ok<NBRAK,FNDSB>
    Z_next    = nc_varget(OPT.ncfile, lookupVarnameInNetCDF('ncfile', OPT.ncfile, 'attributename', 'standard_name', 'attributevalue', 'surface_altitude'), [id_t ystart xstart], [1 floor((ystop-ystart)/OPT.stride(2)) floor((xstop-xstart)/OPT.stride(3))], OPT.stride);
    if sum(sum(~isnan(Z_next))) ~=0
        disp(['Adding data from: ' datestr(t(idt(id_t+1)))])
        ids2add = ~isnan(Z_next) & isnan(Z);    % helpul to be in a variable as the nature of Z changes in the next two lines
        Z(ids2add) = Z_next(ids2add);           % add Z values from Z_next grid to Z grid at places where there is data in Z_next and no data in Z yet
        T(ids2add) = t(idt(id_t+1));            % add time information to T at those places where Z data was added
    end
end

%% set values outside polygon to nan if a polygon is available
if ~isempty(OPT.polygon)
    disp('Setting values not in polygon to nan ...')
    idout = ~inpolygon(repmat(X',size(Y,1),1), repmat(Y, 1, size(X',2)), OPT.polygon(:,1), OPT.polygon(:,2));
    Z(idout) = nan;
    T(idout) = nan;
end