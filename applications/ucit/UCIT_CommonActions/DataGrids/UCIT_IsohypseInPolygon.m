function UCIT_isohypseInPolygon(polygonname)
%ISOHYPSEINPOLYGON   computes  isohypse for a given polygon and settings
%
%   syntax:
%       UCIT_isoHypseInPolygon
%
%   input:
%       function has no input
%
%   output:
%       function has no output
%
%   See also getCrossSection, UCIT_plotDataInPolygon
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
warning off
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

curdir=pwd;
colors={'b',[0.2 0.6 0],'k','c','m','r', [0.6 0.4 0],[0.2 0.4 0 ], [0.5 0.5 0.5], [1 0.5 0.5],'y',  [0.25 0.5 0.5],[0.5 0 0.5] ,[1 0.5 0.25],[0.5 1 0.5],[0.2 0 1],[1 0.5 1],[0.5 0.5 0.75] };

% define which polygon to use
if nargin == 0
    figure(fh);
    [xv,yv] = UCIT_WS_polydraw;
    polygon=[xv yv];
else
    load(polygonname)
end

if strcmp(UCIT_getInfoFromPopup('GridsDatatype'),'Jarkus'),datatype = 'jarkus';,end
if strcmp(UCIT_getInfoFromPopup('GridsDatatype'),'Vaklodingen'),datatype = 'vaklodingen';,end

%% Get user input
year1 = str2double(datestr(datenum(UCIT_getInfoFromPopup('GridsName')) - 30*(str2double(UCIT_getInfoFromPopup('GridsInterval'))),10));
year2 = str2double(datestr(datenum(UCIT_getInfoFromPopup('GridsName')),10));
years = [year1 : year2];

%% Set up figure
fn=findobj('tag', 'crosssectionView');
if isempty(fn)
    nameInfo = ['UCIT - Isohypse'];
    fn=figure('tag','crosssectionView'); clf; ah=axes;
    set(fh,'Name', nameInfo,'NumberTitle','Off','Units','normalized');
    UCIT_prepareFigureN(0, fn, 'UR', ah);
end

% Find data around selected crosssection for selected years

teller = 0; teller2 = 0;emptyyears = [];
for xx = 1 : length(years)
    clear d;

    figure(fh);
    [X, Y, Z] = rws_getDataInPolygon(...
        'datatype', datatype, ...
        'starttime', datenum(years(xx),12,31), ...
        'searchwindow', -365, ...
        'datathinning', 1,...
        'polygon', polygon,...
        'plotresult',0);

    try delete(findobj('tag','selectionpoly'));  end %#ok<*TRYNC> delete any remaining poly
    
    %% compute area under certain depth
    dh = 1; teller3 = 0;
    for n = -50 : dh : 50
        teller3 = teller3 +1;
        height(teller3) = n;
        area(teller3) = 20*20*sum(sum(Z < n));
    end

    %% cut off uninteresting ends
    area(find(area == max(area),1,'first')+1:end) = 999;
    area(1:find(area == 0,1,'last')-1) = 999;
    height = height(area ~= 999);
    area = area(area ~= 999);

    %% plot data or warn that no data is available
    figure(fn);
    if sum(sum(~isnan(Z))) > 0
        teller=teller+1;
        try
            plot(area,height,'color',colors{teller},'linewidth',2);hold on;
            legendtext{teller}=([num2str(years(xx))]);
        catch
            error(['Too many years!']);
        end
    else
        teller2=teller2+1;
        emptyyears{teller2}=num2str(years(xx));
        warning(['Year ', num2str(years(xx)),' has no data for the isohypse']);
    end
end



% add figure properties
if exist('legendtext')
    legend(legendtext);grid;
    disp([]);
    disp(['Years without data are: '])
    title('Cumulative area')
    xlabel('Area (m^2)');
    ylabel('Height (m)');

    for yy=1:length(emptyyears)
        disp([emptyyears{yy}]);
    end

else
    close(fh)
    warning(['No data was found']);
end




