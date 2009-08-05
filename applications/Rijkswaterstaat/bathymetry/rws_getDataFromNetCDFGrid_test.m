%RWS_GETDATAFROMNETCDFGRID_TEST   test for rws_getDataFromNetCDFGrid
%
%See also: rws_getDataFromNetCDFGrid

%% Test 1: work on Delflandsekust grid

% plot landboundary
figure(10);clf;axis equal;box on;hold on
ldburl = 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/deltares/landboundaries/holland.nc';
x      = nc_varget(ldburl, nc_varfind(ldburl, 'attributename', 'standard_name', 'attributevalue', 'projection_x_coordinate'));
y      = nc_varget(ldburl, nc_varfind(ldburl, 'attributename', 'standard_name', 'attributevalue', 'projection_y_coordinate'));
plot(x, y, 'k', 'linewidth', 2);
axis equal

% identify arbitrary polygon
poly = [68321.2 445431
    67495 446061
    68754 447753
    69698.3 447438];

% get data within that polygon from NetCDF file
url = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/vanoordboskalis/delflandsekust/delflandsekust.nc';
[X, Y, Z, T] = getDataFromNetCDFGrid('ncfile', url, 'starttime', datenum([2009 03 10]), 'searchwindow', -10, 'polygon', poly);

% add the data to the previous plot
surf(X,Y,Z); shading interp;view(2);

% add polygon used as well
plot(poly(:,1), poly(:,2), 'r')

xlabel('x-coordinate [m]')
ylabel('y-coordinate [m]')
title('Testing getDataFromNetCDFGrid.m on Delflandsekust')