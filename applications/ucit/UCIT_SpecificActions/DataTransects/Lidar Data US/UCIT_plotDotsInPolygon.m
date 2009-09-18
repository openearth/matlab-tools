function UCIT_plotDotsInPolygon
%PLOTDOTSINPOLYGON   this routine displays LIDAR dot plots on an overview figure
%
% This routine displays LIDAR dot plots on an overview figure.
%
% input:
%    function has no input
%
% output:
%    function has no output
%
% see also ucit, displayTransectOutlines

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

%% select transects to plot
fh = figure(findobj('tag','mapWindow'));set(fh,'visible','off');
[xv,yv] = UCIT_WS_drawPolygon;
polygon=[xv yv];

%% get metadata (either from the console or the database)

d = UCIT_getLidarMetaData;

%% filter transects using inpolygon
test = d.contour;
id1 = inpolygon(test(:,1),test(:,3),polygon(:,1),polygon(:,2));
id2 = inpolygon(test(:,2),test(:,4),polygon(:,1),polygon(:,2));
id = (id1|id2);


%% Find all transects and colour them blue
figure(fh);
rayH=findobj(gca,'type','line','LineStyle','-');
dpTs=get(rayH,'tag');

for i = 1:length(dpTs)-1
    tagtext = dpTs{i};
    underscores = strfind(tagtext,'_');
    id_text(i) = str2double(tagtext([underscores(2)+1:underscores(3)-1]));
end

[C,IA,IB] = intersect(str2double(d.transectID(id)),id_text');

selection=get(rayH(IB),'tag');

for jj=1:length(selection)
    tt=findobj('tag',selection{jj});
    set(tt,'color','b');
end

%% prepare figure
% create figure and axis
close(findobj('tag','Dotfig'));
fh=figure('tag','Dotfig');clf;
set(fh,'visible','off')
RaaiInformatie='UCIT - C Dots Amy';
set(fh,'Name',RaaiInformatie,'NumberTitle','Off','Units','normalized');
ah=axes;hold on;box on;

% use prepare UCIT_prepareFigure to give it the UCIT look and feel
figure(findobj('tag','Dotfig')) % make the figure current is apparently needed to actually make the repositioning statement work
[fh]=UCIT_prepareFigureN(2, fh, 'UR', ah);set(fh,'visible','off')

figure(findobj('tag','Dotfig')) % make the figure current is apparently needed to actually make the repositioning statement work
set(findobj('tag','Dotfig'),'position',UCIT_getPlotPosition('UR'));

% plot landboundary
UCIT_plotLandboundary(d.datatypeinfo{1},1);

% prepare colormap info for cdots_amy function
load colormapMHWjump20

if 1 % 1: use a 'for'-loop to get and plot the data (then you can use the waitbar) ...

    datatypes = UCIT_getDatatypes;
    url = datatypes.transect.urls{find(strcmp(UCIT_DC_getInfoFromPopup('TransectsDatatype'),datatypes.transect.names))};

    % get data
    crossShoreCoordinate = nc_varget(url, 'cross_shore');
    ids = find(id>0);

    x = nc_varget(url, 'x',         [0,ids(1),0], [1,ids(end)-ids(1),length(crossShoreCoordinate)]);
    y = nc_varget(url, 'y',         [0,ids(1),0], [1,ids(end)-ids(1),length(crossShoreCoordinate)]);
    z = nc_varget(url, 'altitude',  [0,ids(1),0], [1,ids(end)-ids(1),length(crossShoreCoordinate)]);

    % prepare info for coloring
    MHW    = 1;% d(i).Z_mhw;
    dz     = .5/8;
    zmin_a = MHW - (19 * dz);
    zmax_a = MHW + (44 * dz);

    % plot data (NB: coloring depends on the Mean High Water info)
    UCIT_cdots_amy(x,y,z,zmin_a,zmax_a,cmapMHWjump20)
end

if 1
    %% get info to plot shoreposition

    scatter(d.shore_east, d.shore_north, repmat(35,size(d.shore_east)),'marker','o','markerfacecolor','w','markeredgecolor','k')

end

%% Set figure properties

view(2);
xlabel('Easting (m, UTM)','fontsize',9);
ylabel('Northing (m, UTM)','fontsize',9);
% axis equal
dx=100;
maxx=max(max(x(x~=-9999)));
minx=min(min(x(x~=-9999)));
maxy=max(max(y(y~=-9999)));
miny=min(min(y(y~=-9999)));
axis([(minx) - dx (maxx)+ dx (miny)- dx (maxy)+ dx] );

%% set colorbar
colormap(cmapMHWjump20);
cb = colorbar('ytick',4:8:60,'yticklabel',...
    {'HMW-0.5';'MHW';'MHW+0.5';'MHW+1.0';'MHW+1.5';'MHW+2.0';'>=MHW+2.5'});
set(cb,'yticklabel',{'HMW-0.5';'MHW';'MHW+0.5';'MHW+1.0';'MHW+1.5';'MHW+2.0';'>=MHW+2.5'})
title(cb,'Height (m)');

%% make figure visible only after all is plotted
set(fh,'visible','on')
figure(findobj('tag','Dotfig')) % make the figure current is apparently needed to actually make the repositioning statement work
set(findobj('tag','Dotfig'),'position',UCIT_getPlotPosition('UR'));
