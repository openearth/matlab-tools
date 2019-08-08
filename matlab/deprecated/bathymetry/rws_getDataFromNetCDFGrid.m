function [X, Y, Z, T] = rws_getDataFromNetCDFGrid(varargin)
error('This function is deprecated in favour of grid_orth_getDataFromNetCDFGrid')
%rws_GETDATAFROMNETCDFGRID  This routine gets data from a netCDF grid file.
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
%   [X, Y, Z, T] = rws_getDataFromNetCDFGrid('ncfile', ncfile, 'starttime', now, 'polygon', poly)
%
%   See also: nc_dump, rws_getDataFromNetCDFGrid_test, nc_varfind

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

%% settings defaults

   OPT.ncfile       = [];      % filename of nc file to use
   OPT.starttime    = [];      % this is a datenum of the starting time to search
   OPT.searchwindow = -30;     % this indicates the search window (nr of days, '-': backward in time, '+': forward in time)
   OPT.polygon      = [];      % search polygon (default: [] use entire grid)
   OPT.stride       = [1 1 1]; % stride vector indicating thinning factor

% overrule default settings by property pairs, given in varargin

   OPT = setproperty(OPT, varargin{:});

%% find nc variables of coordinates

   nc_index.x = nc_varfind(OPT.ncfile, 'attributename','standard_name','attributevalue','projection_x_coordinate');
   nc_index.y = nc_varfind(OPT.ncfile, 'attributename','standard_name','attributevalue','projection_y_coordinate');
   nc_index.t = nc_varfind(OPT.ncfile, 'attributename','standard_name','attributevalue','time');
   nc_index.z = nc_varfind(OPT.ncfile, 'attributename','standard_name','attributevalue','altitude'); % JarKus
   if isempty(nc_index.z)
   nc_index.z = nc_varfind(OPT.ncfile, 'attributename','standard_name','attributevalue','height_above_reference_ellipsoid'); % AHN
   end

%% find data area of interest

   X0        = nc_varget(OPT.ncfile, nc_index.x);
   Y0        = nc_varget(OPT.ncfile, nc_index.y);

% sort X and Y

   X1 = sort(X0,'ascend');
   Y1 = sort(Y0,'ascend');
   
   if ~isempty(OPT.polygon)
       % determine the extent of the polygon
       minx = min(OPT.polygon(:,1));
       maxx = max(OPT.polygon(:,1));
       miny = min(OPT.polygon(:,2));
       maxy = max(OPT.polygon(:,2));
   
       % Find out which part of X and Y data lies within the extent of the polygon
       % NB: these are indexes, should be reduced with one for netCDF call as nc files start counting at 0
       
       xstart   = find(X1>minx, 1, 'first');
       xlength  = find(X1<maxx, 1, 'last');
       ystart   = find(Y1>miny, 1, 'first');
       ylength  = find(Y1<maxy, 1, 'last');
   else
       xstart   = 1;
       xlength  = size(X,1);
       ystart   = 1;
       ylength  = size(Y,1);
   end

%% get relevant data (possibly using stride)
   
   X = nc_varget(OPT.ncfile, nc_index.x, xstart - 1, floor((xlength-(xstart-1))/OPT.stride(3)), OPT.stride(3));
   Y = nc_varget(OPT.ncfile, nc_index.y, ystart - 1, floor((ylength-(ystart-1))/OPT.stride(2)), OPT.stride(2));
   Z = zeros(size(Y,1), size(X,1))*nan;
   T = zeros(size(Y,1), size(X,1))*nan;

%% find the data files that lie within the temporal search window

if ~isempty(nc_index.t)

    t        = nc_varget(OPT.ncfile, nc_index.t);
    [t,idt]  = sort(t,'descend');

    [start_idx, end_idx, extents, matches, tokens, names, splits]  = regexp(nc_attget(OPT.ncfile,nc_index.t,'units'), '\d+');
    t        = t + datenum([matches{1:6}], 'yyyymmddHHMMSS');

    idt_in   = find(t <= OPT.starttime & ...
                    t >= OPT.starttime + OPT.searchwindow);
                    
% TO DO: add nearest in time 
% TO DO: add linear interpolation in time

    %% one by one place separate grids on overall grid
    
    for id_t = [idt(idt_in)-1]' 
        % So long as not all Z values inpolygon are nan try to add data
        if sum(isnan(Z(inpolygon(repmat(X',size(Y,1),1), repmat(Y, 1, size(X',2)), OPT.polygon(:,1), OPT.polygon(:,2)))))~=0
            Z_next    = nc_varget(OPT.ncfile, nc_index.z, [id_t ystart-1 xstart-1], [1 floor((ylength-(ystart-1))/OPT.stride(2)) floor((xlength-(xstart-1))/OPT.stride(3))], OPT.stride);
            if sum(sum(~isnan(Z_next))) ~=0
                disp(['... adding data from: ' datestr(t(idt(id_t+1)))])
                ids2add = ~isnan(Z_next) & isnan(Z);    % helpul to be in a variable as the nature of Z changes in the next two lines
                Z(ids2add) = Z_next(ids2add);           % add Z values from Z_next grid to Z grid at places where there is data in Z_next and no data in Z yet
                T(ids2add) = t(idt(id_t+1));            % add time information to T at those places where Z data was added
            end
        end
    end
    
else % do this if there is no time variable in the nc file (e.g. AHN)

    OPT.stride  = OPT.stride(2:3);

    % find right indices
    xstart_inv  = find(X0 == X1(xstart));
    xlength     = length(xstart:xlength);
    ystart_inv  = find(Y0 == Y1(ystart));
    ylength     = length(ystart:ylength);

    % get data without time variable
    X        = nc_varget(OPT.ncfile, nc_index.x, xstart_inv - 1      , xlength/OPT.stride(2), OPT.stride(2));
    Y        = nc_varget(OPT.ncfile, nc_index.y, ystart_inv - ylength, ylength/OPT.stride(1), OPT.stride(1));
    Z_next   = nc_varget(OPT.ncfile, nc_index.z,[xstart_inv - 1      , ystart_inv - ylength], [xlength/OPT.stride(1) ylength/OPT.stride(2)], OPT.stride);
    Z        = Z_next';
    
    mean(Z)
    whos

end

%% set values outside polygon to nan if a polygon is available

if ~isempty(OPT.polygon)
    disp('Setting values not in polygon to nan ...')
    idout = ~inpolygon(repmat(X',size(Y,1),1), repmat(Y, 1, size(X',2)), OPT.polygon(:,1), OPT.polygon(:,2));
    Z(idout) = nan;
    T(idout) = nan;
end