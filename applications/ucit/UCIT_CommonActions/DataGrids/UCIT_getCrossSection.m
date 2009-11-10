function UCIT_getCrossSection
%UCIT_GETCROSSSECTION   allows use to draw a line over a plotted grid to which the data from that grid is interpolated for multiple years
%
%   syntax:
%       getCrossSectionMultipleYears
%
%   input:
%       function has no input
%
%   output:
%       function has no output
%
%   See also getCrossSection
%
%   See also UCIT_plotDataInPolygon
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%
%       Ben de Sonneville
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

%% Select in either grid plot or grid overview plot
mapW = findobj('tag','gridPlot');
if isempty(mapW)
    if isempty(findobj('tag','gridOverview'))
        UCIT_plotGridOverview;
    else
        fh = figure(findobj('tag','gridOverview'));figure(fh);
    end
else
    fh = figure(findobj('tag','gridPlot')); figure(fh);
end

colors={'b',[0.2 0.6 0],'k','c','m','r', [0.6 0.4 0],[0.2 0.4 0 ], [0.5 0.5 0.5], [1 0.5 0.5],'y',  [0.25 0.5 0.5],[0.5 0 0.5] ,[1 0.5 0.25],[0.5 1 0.5],[0.2 0 1],[1 0.5 1],[0.5 0.5 0.75] };

try delete(findobj(fh,'tag','crs_line'));  end %#ok<*TRYNC> delete any remaining poly

%% Click line
disp('Please click a line from which to select data ...')
input=ginput(2);
lh=line(input(:,1),input(:,2));
set(lh,'color','g','linewidth',2,'tag','crs_line');
xi=input(:,1);
yi=input(:,2);
xi=linspace(xi(1),xi(2),1000);
yi=linspace(yi(1),yi(2),1000);
polygon = ([min(xi)-1000 min(yi)-1000;max(xi)+1000 min(yi)-1000;max(xi)+1000 max(yi)+1000; min(xi)-1000 max(yi)+1000;min(xi)-1000 min(yi)-1000]);

if strcmp(UCIT_getInfoFromPopup('GridsDatatype'),'Jarkus'),datatype = 'jarkus';,end
if strcmp(UCIT_getInfoFromPopup('GridsDatatype'),'Vaklodingen'),datatype = 'vaklodingen';,end

%% Get user input
year1 = str2double(datestr(datenum(UCIT_getInfoFromPopup('GridsName')) - 30*(str2double(UCIT_getInfoFromPopup('GridsInterval'))),10));
year2 = str2double(datestr(datenum(UCIT_getInfoFromPopup('GridsName')),10));
years = [year1 : year2];

teller=0;teller2=0;

%% Set up figure
fn=findobj('tag', 'crosssectionView');
if isempty(fn)
    nameInfo = ['UCIT - Crosssection view'];
    fn=figure('tag','crosssectionView','visible','off'); clf; ah=axes;
    set(fn,'Name', nameInfo,'NumberTitle','Off','Units','normalized');
    UCIT_prepareFigureN(0, fn, 'UR', ah);
    title('Bed level of requested crossection')
    xlabel('Local x direction');
    ylabel('Bed level (m)');
    set(gca,'fontsize',8);
end

%% Retrieve data for all years
for xx = 1:length(years)

    figure(fh);
    [X, Y, Z] = rws_getDataInPolygon(...
        'datatype', datatype, ...
        'starttime', datenum(years(xx),12,31), ...
        'searchwindow', -365, ...
        'datathinning', 1,...
        'polygon', polygon,...
        'plotresult',0);

    try delete(findobj('tag','selectionpoly'));  end %#ok<*TRYNC> delete any remaining poly

    dx=xi(end)-xi(1);
    dy=yi(end)-yi(1);
    lengthc=sqrt(dx^2+dy^2);
    stepsize=lengthc/size(xi,2);
    xl=[0:stepsize:(size(xi,2)-1)*stepsize];
    zl=interp2(X,Y,Z,xi,yi);
    if sum(~isnan(zl))>0
        teller=teller+1;
        figure(fn);set(fn,'visible','on');
        try
            plot(xl,zl,'color',colors{teller},'linewidth',2);hold on;
            legendtext{teller}=([num2str(years(xx))]);
        catch
            error(['Too many years!']);
        end
    else
        teller2=teller2+1;
        emptyyears{teller2}=num2str(years(xx));
        warning(['Year ', num2str(years(xx)),' has no data for the crosssection']);
    end
end

%% Add legend
if exist('legendtext')
    figure(fn);
    legend(legendtext);grid;
    disp([]);
    disp(['Years without data are: '])
if exist('emptyyears')
    for yy=1:length(emptyyears)
        disp([emptyyears{yy}]);
    end
end

else
    close(fh)
    warning(['No data was found']);
end





