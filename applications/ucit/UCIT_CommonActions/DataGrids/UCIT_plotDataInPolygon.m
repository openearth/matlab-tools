function [X,Y,Z,Ztemps,in]=UCIT_plotDataInPolygon
%UCIT_PLOTDATAINPOLYGON  Script to load fixed maps from OPeNDAP, identify which maps are located inside a polygon and retrieve the data
%
%       [X, Y, Z, Ztime] = UCIT_plotdatainpolygon;
%
%   Input in UCIT GUI
%
%   	'datatype'
%   	'starttime'
%   	'searchwindow'
%   	'datathinning'
%
%   Output:
%       plot with data of selected period for selected polygon
%
%   Example:
%
%
%
% See also: grid_orth_getDataInPolygon, grid_orth_getFixedMapOutlines, grid_orth_createFixedMapsOnAxes, grid_orth_identifyWhichMapsAreInPolygon, grid_orth_getDataFromNetCDFGrid

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

warningstate = warning;
warning off

datatype = UCIT_getInfoFromPopup('GridsDatatype');

%% Select in grid overview plot

if isempty(findobj('tag','gridOverview')) || ~any(ismember(get(axes, 'tag'), {datatype}))
    fh = UCIT_plotGridOverview;
else
    fh = figure(findobj('tag','gridOverview'));figure(fh);
end

[d] = UCIT_getMetaData(2);

%% get data from right netcdf files

[X, Y, Z, Ztime] = grid_orth_getDataInPolygon(...
    'dataset'     , d.urls, ...
    'tag'         , datatype, ...
    'starttime'   ,        datenum(UCIT_getInfoFromPopup('GridsName'), 'yyyy-mm-dd'), ...
    'searchwindow', -30*str2double(UCIT_getInfoFromPopup('GridsInterval')), ...
    'datathinning',     str2double(UCIT_getInfoFromPopup('GridsSoundingID')),...
    'plotresult'  , 0,...
    'cellsize'    , d.cellsize);

if ~isempty(findobj('tag','gridPlot'))
      close(findobj('tag','gridPlot'))
end

%% workaround
Ztime(Z>1e10) = nan;
Z    (Z>1e10) = nan;

%% plot results
if ~all(all(isnan(Z)))

    UCIT_plotGrid(X,Y,Z,1,d);
    tempTag=get(gcf,'tag');
    set(gcf,'tag','tempTag');

    % attach data to figure - userdata
    d.X = X; d.Y = Y; d.Z = Z; d.Ztime = Ztime; d.datatypeinfo = UCIT_getInfoFromPopup('GridsDatatype');
    set(gcf,'userdata',d);

    set(gca,'Xlim',[d.X(1,1) d.X(1,end)]);
    set(gca,'Ylim',[d.Y(end,1) d.Y(1,1)]);

    if ~isempty(findobj('tag','tempsWindow'))
          close(findobj('tag','tempsWindow'));
    end

    if ~all(isnan(Ztime(:)))
        UCIT_plotGrid(X,Y,Ztime,7,d,unique(Ztime(find(~isnan(Ztime)))));
        set(gcf,'tag'     ,'tempsWindow');
        set(gcf,'position',UCIT_getPlotPosition('UR'));

        % reset the tag of the original figure (needed for get cross section)
        set(findobj('tag','tempTag'),'tag',tempTag);

        set(gca,'Xlim',[d.X(1,1) d.X(1,end)]);
        set(gca,'Ylim',[d.Y(end,1) d.Y(1,1)]);
        tickmap('xy')
    end

else
    % warndlg('No data found for these search criteria');
    % grid_orth_getDataInPolygon already throws wanring
end

warning(warningstate)

%% EOF