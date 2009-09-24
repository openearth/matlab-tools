function plotMultipleYears(d,years)
%plotMultipleYears   routine plots multiple years of structure d
%
% input:
%   d = basic McDatabase datastructure for transects
%   years = array of selected years (max 10)
%
% output:
%   plot of crosssections for selected years
%
% syntax:
%           plotMultipleYears(d,[2001:2005]);
%
%   See also getPlot
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

datatypes = UCIT_getDatatypes;
url = datatypes.transect.urls{find(strcmp(UCIT_DC_getInfoFromPopup('TransectsDatatype'),datatypes.transect.names))};
[d] = UCIT_getMetaData;

if nargin<2
    [check]=UCIT_checkPopups(1, 4);
    if check == 0
        return
    end

    if strcmp(UCIT_DC_getInfoFromPopup('TransectsTransectID'),'Transect ID (load first)')
        error('Select datatype, area and transect first');
    end

    %     d       =   readTransectData(UCIT_DC_getInfoFromPopup('TransectsDatatype'),UCIT_DC_getInfoFromPopup('TransectsArea'),UCIT_DC_getInfoFromPopup('TransectsTransectID'));
    
    years   =   SelectYears(d);

end

colors={'b',[0.2 0.6 0],'k',[0.5 1 1],'m','r', [0.6 0.4 0],[0.2 0.4 0 ], [0.5 0.5 0.5], [1 0.5 0.5]};

% Create empty base figure

fh=figure('tag','plotWindow');
RaaiInformatie=['UCIT - Transect view -  Area: ' UCIT_DC_getInfoFromPopup('TransectsArea') '  Transect: ' UCIT_DC_getInfoFromPopup('TransectsTransectID') ];
set(fh,'Name', RaaiInformatie,'NumberTitle','Off','Units','normalized');
ah=axes;
[fh,ah] = UCIT_prepareFigureN(0, fh, 'UL', ah);clf
title(RaaiInformatie);
hold on;

% Add cross-sections of selected years

if length(years)>10
    warning('Maximum number of selected years is 10')
    years=years(1:10);
end

counter = 1;

for i=1:length(years)

    
    try
        transect = jarkus_readTransectDataNetcdf(url, UCIT_DC_getInfoFromPopup('TransectsArea'),UCIT_DC_getInfoFromPopup('TransectsTransectID'),years(i));
    end

    if exist('transect')
        if ~isempty(transect)
            plotLine(transect);hold on;
            a=findobj('tag',['ph' num2str(transect.year)]);
            b=findobj('tag',['ph' num2str(transect.year)]);
            set(a,'color',colors{counter});
            set(b,'color',colors{counter}); clear a b;
            legendtext{counter} = num2str(transect.year);
            counter = counter + 1;
            clear transect
        end
    else
        warning(['Year ', num2str(years(i)), ' was not found in the database']);
    end
end
legend(legendtext);
grid;


function plotLine(d)

if isempty(d)
    error('A selected year was not found in the database')
end

% Prepare figure window
try
    guiH=findobj('tag','UCIT_mainWin');
end

% Plot profile

if ~isempty(d.ze)

    try
        ph=plot(d.xi(~isnan(d.ze)),d.zi(~isnan(d.ze)),'k','linewidth',1.5);
    catch
        ph=plot(d(1).xi(~isnan(d(1).ze)),d(1).zi(~isnan(d(1).ze)),'k','linewidth',1.5);
    end
    set(ph,'tag',['ph' num2str(d.year)]);

end

% Figure properties

xlabel('Cross shore distance [m]');
ylabel('Elevation [m to datum]');
try
axis([min(d(1).xi(~isnan(d(1).ze))) max(d(1).xi(~isnan(d(1).ze))) -35 35]);
end
set(gca,'XDir','reverse');
box on
minmax = axis;
handles.XMaxRange = [minmax(1) minmax(2)];
handles.YMaxRange = [minmax(3) minmax(4)];


function years  =   SelectYears(d)

% Get available years from metadata
AvailableYears   =   num2str(round(d.year/365+1970));

 
% tmp=DBGetTableEntryRaw('transect','datatypeinfo',UCIT_DC_getInfoFromPopup('TransectsDatatype'),'area',UCIT_DC_getInfoFromPopup('TransectsArea'),'transectID',UCIT_DC_getInfoFromPopup('TransectsTransectID'));

v = listdlg('PromptString','Select years:',...
    'SelectionMode','multiple',...
    'ListString',AvailableYears);

AvailableYears   = round(d.year/365+1970);

years   =   AvailableYears(v);
