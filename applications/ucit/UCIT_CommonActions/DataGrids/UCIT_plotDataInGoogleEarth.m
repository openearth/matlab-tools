function UCIT_plotDataInGoogleEarth
%UCIT_PLOTDATAINGOOGLEEARTH  plots data of selected polygon in Google Earth
%
%       UCIT_plotDataInGoogleEarth
%
%   Input in UCIT GUI
%
%
%   Output:
%       temporary KML-file
%
%   Example:
%
%
%
% See also: rws_getDataInPolygon, rws_getFixedMapOutlines, rws_createFixedMapsOnAxes, rws_identifyWhichMapsAreInPolygon, rws_getDataFromNetCDFGrid

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Ben de Sonneville
%
%       Ben.deSonneville@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

if isempty(findobj('tag','gridOverview'))
    UCIT_plotGridOverview;
else
    figure(findobj('tag','gridOverview'));
end

if strcmp(UCIT_getInfoFromPopup('GridsDatatype'),'Jarkus'),datatype = 'jarkus';,end
if strcmp(UCIT_getInfoFromPopup('GridsDatatype'),'Vaklodingen'),datatype = 'vaklodingen';,end


%% get data from right netcdf files
[X, Y, Z, Ztime] = rws_getDataInPolygon(...
    'datatype'    , datatype, ...
    'starttime'   ,        datenum(UCIT_getInfoFromPopup('GridsName')), ...
    'searchwindow', -30*str2double(UCIT_getInfoFromPopup('GridsInterval')), ...
    'datathinning',     str2double(UCIT_getInfoFromPopup('GridsSoundingID')),...
    'plotresult'  ,0);

if ~isempty(findobj('tag','gridPlot'))
    close(findobj('tag','gridPlot'))
end

%% Make kml file
filename = gettmpfilename(getenv('TEMP'),'grid','.kml');% plot results

%% Thin out if needed
matrix_size = round(size(X,1)*size(X,2));
 if matrix_size > 20000
    thinning = min(1,round(matrix_size / 600000));
 else 
    thinning = 1;
 end
 
%% Convert coordinates

if ~all(isnan(Z(:)))
    [lat,lon] = convertCoordinates(X(1:thinning:end,1:thinning:end),Y(1:thinning:end,1:thinning:end),'CS1.name','Amersfoort / RD New','CS2.code',4326);
    KMLsurf(lon,lat,-Z(1:thinning:end,1:thinning:end),'fileName',[filename '.kml'],'zScaleFun',@(z)(z+20)*4,'colorMap',@(m)colormap_cpt('bathymetry_vaklodingen',m),'colorSteps',200,'cLim',[-50 25]);
else
    warndlg('No data found for these search criteria');
end

%% Run kml file in Google Earth
eval(['!', filename '.kml']);

disp(['Saved Google Earth file as ',filename])



