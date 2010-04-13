function testresult = grid_orth_getDataFromNetCDFGrid_test()
%GRID_ORTH_GETDATAFROMNETCDFGRID_TEST  test for grid_orth_getdatafromnetcdfgrid
%  
% See also: grid_orth_getDataFromNetCDFGrid

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 11 Sep 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% $Description (Name = getDataFromNetCDFGrid)
% Publishable code that describes the test.

% plot landboundary
figure(10);clf;axis equal;box on;hold on
ldburl = 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/deltares/landboundaries/holland.nc';

nc_index.x = nc_varfind(ldburl, 'attributename', 'standard_name', 'attributevalue', 'projection_x_coordinate')
nc_index.y = nc_varfind(ldburl, 'attributename', 'standard_name', 'attributevalue', 'projection_y_coordinate')

x      = nc_varget(ldburl, nc_index.x);
y      = nc_varget(ldburl, nc_index.y);
plot(x, y, 'k', 'linewidth', 2);
axis equal

% identify arbitrary polygon
poly = [68321.2 445431
        67495 446061
        68754 447753
        69698.3 447438];

% add polygon used as well
plot(poly(:,1), poly(:,2), 'r')

xlabel('x-coordinate [m]')
ylabel('y-coordinate [m]')
title('Testing getDataFromNetCDFGrid.m on Delflandsekust')

%% $RunCode
% get data within that polygon from NetCDF file
url = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/vanoordboskalis/delflandsekust/delflandsekust.nc';
[X, Y, Z, T] = grid_orth_getDataFromNetCDFGrid('ncfile', url, 'starttime', datenum([2009 03 10]), 'searchwindow', -10, 'polygon', poly);

testresult = nan;

%% $PublishResult
% Publishable code that describes the test.
% add the data to the previous plot
surf(X,Y,Z); shading interp;view(2);