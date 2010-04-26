function UCIT_plotDifferenceMap(datatype1,year1,targetmonth1,datatype2,year2,targetmonth2,monthsmargin,thinning,polygon)
% UCIT_PLOTDIFFERENCEMAP  This script makes a difference plot for a polygon and two selected years
%
%
%   Syntax:     UCIT_makeDifferencePlot
%
%   Input:      in UCIT GUI
%
%
%
%   Output:
%
%
%
%
%   See also grid_orth_getDataInPolygon

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

if isempty(findobj('tag','gridOverview')) || ~any(ismember(get(axes, 'tag'), {datatype}))
    fh = UCIT_plotGridOverview(datatype,'refreshonly',1);
else
    fh = figure(findobj('tag','gridOverview'));figure(fh);
end

tic
[d] = UCIT_getMetaData(2);
toc

%% draw polygon
[xv,yv] = polydraw;polygon=[xv' yv'];

%% select years
years = [1926:str2double(datestr(now,10))];
years = sort(years,'descend');
for i = 1:length(years)
    str{i} = num2str(years(i));
end
v = listdlg('PromptString','Select two years:',...
           'SelectionMode','multiple',...
              'ListString',str);
if length(v) > 2
    errordlg('Please select only two years');
end
year1 = years(v(1));
year2 = years(v(2));

%% get data of first year
[d.X, d.Y, d1.Z, d1.Ztime] = grid_orth_getDataInPolygon(...
    'dataset'     , d.urls, ...
    'tag'         , datatype, ...
    'starttime'   , datenum([year1 01 01]), ...
    'searchwindow', -365, ...
    'datathinning', 1,...
    'plotresult'  , 0,...
    'polygon'     , polygon);  % this functionality is also inside grid_orth_getDataInPolygon

%% get data of second year
[d.X, d.Y, d2.Z, d1.Ztime] = grid_orth_getDataInPolygon(...
    'dataset'     , d.urls, ...
    'tag'         , datatype, ...
    'starttime'   , datenum([year2 01 01]), ...
    'searchwindow', -365, ...
    'datathinning', 1,...
    'plotresult'  , 0,...
    'polygon'     , polygon);  % this functionality is also inside grid_orth_getDataInPolygon

%% Subtract years
dd.Z = -(d1.Z - d2.Z);

%% Plot results
fh = figure('tag','diffplot');clf;
ah = axes;
[fh,ah] = UCIT_prepareFigureN(0, fh, 'UR', ah);
UCIT_plotlandBoundary(d.ldb,'none'); % plot land boundary
surf   (d.X,d.Y,dd.Z);shading interp;view(2);hold on;
cm = colormap(['erosed']); 
caxis([-3 3]);
c  = colorbar('vert');
axis   equal;
axis   tight;
box    on
set   (fh,'Units','normalized');
set   (fh,'Position',UCIT_getPlotPosition('UR',1))
set   (fh,'Name','UCIT - Difference Map','NumberTitle','Off','Units','characters','visible','on');
title([num2str(year1) '-' num2str(year2)]);
set   (gca,'Xlim',[d.X(1,1) d.X(1,end)]);
set   (gca,'Ylim',[d.Y(end,1) d.Y(1,1)]);
 
warning(warningstate)

%% EOF   