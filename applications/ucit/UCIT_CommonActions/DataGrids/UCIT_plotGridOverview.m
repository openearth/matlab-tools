function UCIT_plotGridOverview(datatype)
%PLOTGRIDOVERVIEW   this routine displays all grid outlines
%
% This routine displays all transect outlines.
%
% input:
%    function has no input
%
% output:
%    function has no output
%
% see also ucit_netcdf

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%   Mark van Koningsveld
%   Ben de Sonneville
%
%       M.vankoningsveld@tudelft.nl
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

%% get metadata (either from the console or the database)

tic
[d] = UCIT_getMetaData(2);
toc

if ~isempty(findobj('tag','gridOverview'))
    close(findobj('tag','gridOverview'))
end

%% set up figure

fh=figure('tag','mapWindow');clf;
ah=axes;
[fh,ah] = UCIT_prepareFigureN(2, fh, 'LL', ah);
set(fh,'name','UCIT - Grid overview');
set(gca, 'fontsize',8);

hold on

if nargin == 0
    if strcmp(UCIT_getInfoFromPopup('GridsDatatype'),'Jarkus')     ,datatype = 'jarkus'     ;,end
    if strcmp(UCIT_getInfoFromPopup('GridsDatatype'),'Vaklodingen'),datatype = 'vaklodingen';,end
    if strcmp(UCIT_getInfoFromPopup('GridsDatatype'),'AHN100')     ,datatype = 'AHN100'     ;,end
     if strcmp(UCIT_getInfoFromPopup('GridsDatatype'),'AHN250')     ,datatype = 'AHN250'     ;,end
end

disp('plotting landboundary...');
UCIT_plotLandboundary(d.ldb);

%% plot kaartbladen

for i = 1:size(d.contour,1)
    ph(i)=patch([d.contour(i,1),d.contour(i,2),d.contour(i,2),d.contour(i,1),d.contour(i,1)],...
        [d.contour(i,3),d.contour(i,3),d.contour(i,4),d.contour(i,4),d.contour(i,3)], 'k');
    set(ph(i),'edgecolor','k','facecolor','none');
    set(ph(i),'tag',[d.names{i}]);
    set(gca  ,'tag',[datatype]);
end

set(gcf,'tag','gridOverview');
box on

%% Adjust axis and labels
axis equal;
axis([d.axes])
ylabel('Northing [m]')
xlabel('Easting [m]')

%% Make figure visible
set(fh,'visible','on');

