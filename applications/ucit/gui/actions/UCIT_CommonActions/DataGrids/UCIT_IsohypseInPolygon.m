function UCIT_isohypseInPolygon(polygonname)
%ISOHYPSEINPOLYGON   computes  isohypse for a given polygon and settings
%
%   syntax:
%       UCIT_isoHypseInPolygon(<polygonname>)
%
%   input:
%       when polygonname is not specified, a polygon can be clicked.
%
%   output:
%       function has no output
%
%   See also UCIT_plotDataInPolygon, grid_2D_orthogonal

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

warningstate = warning;
warning off

datatype = UCIT_getInfoFromPopup('GridsDatatype');

%% Specify polygon

OPT.polygon         = [];

%% Select in either grid plot or grid overview plot
mapW = findobj('tag','gridPlot');
if isempty(mapW)
    if isempty(findobj('tag','gridOverview')) || ~any(ismember(get(axes, 'tag'), {datatype}))
        fh = UCIT_plotGridOverview(datatype,'refreshonly',1);
    else
        fh = figure(findobj('tag','gridOverview'));figure(fh);
    end
else
    fh = figure(findobj('tag','gridPlot')); figure(fh);
end

%% select or load polygon
try delete(findobj(ah,'tag','selectionpoly'));  end %#ok<*TRYNC> delete any remaining poly
try delete(findobj(fh,'tag','isohypse_polygon'));  end

% if no polygon is available yet draw one
if isempty(OPT.polygon)
    % make sure the proper axes is current
    try axes(ah); end
    
    jjj = menu({'Zoom to your place of interest first.',...
        'Next select one of the following options.',...
        'Finish clicking of a polygon with the <right mouse> button.'},...
        '1. click a polygon',...
        '2. click a polygon and save to file',...
        '3. load a polygon from file');
    
    if jjj<3
        % draw a polygon using polydraw making sure it is tagged properly
        disp('Please click a polygon from which to select data ...')
        [x,y] = polydraw('g','linewidth',2,'tag','selectionpoly');
        
    elseif jjj==3
        % load and plot a polygon
        [fileName, filePath] = uigetfile({'*.ldb','Delft3D landboundary file (*.ldb)'},'Pick a landboundary file');
        [x,y]=landboundary_da('read',fullfile(filePath,fileName));
        x = x';
        y = y';
    end
    
    % save polygon
    if jjj==2
        [fileName, filePath] = uiputfile({'*.ldb','Delft3D landboundary file (*.ldb)'},'Specifiy a landboundary file',...
            ['polygon_',datestr(now)]);
        landboundary_da('write',fullfile(filePath,fileName),x,y);
    end
    
    % combine x and y in the variable polygon and close it
    OPT.polygon = [x' y'];
    OPT.polygon = [OPT.polygon; OPT.polygon(1,:)];
    
else
    
    x = OPT.polygon(:,1);
    y = OPT.polygon(:,2);
    
end


curdir=pwd;
colors={'b',[0.2 0.6 0],'k','c','m','r', [0.6 0.4 0],[0.2 0.4 0 ], [0.5 0.5 0.5], [1 0.5 0.5],'y',  [0.25 0.5 0.5],[0.5 0 0.5] ,[1 0.5 0.25],[0.5 1 0.5],[0.2 0 1],[1 0.5 1],[0.5 0.5 0.75] };

%% Get user input from UCIT console
year1 = str2double(datestr(datenum(UCIT_getInfoFromPopup('GridsName')) ...
    - 30*(str2double(                UCIT_getInfoFromPopup('GridsInterval'))),10));
year2 = str2double(datestr(datenum(UCIT_getInfoFromPopup('GridsName')),10));
years = [year1 : year2];

%% Set up first figure
fn=findobj('tag', 'crosssectionView');
if isempty(fn)
    nameInfo = ['UCIT - Isohypse (Method 1)'];
    fn=figure('tag','crosssectionView','visible','off'); clf; ah=axes;
    set(fn,'Name', nameInfo,'NumberTitle','Off','Units','normalized');
    UCIT_prepareFigureN(0, fn, 'UL', ah);
end

%% Get data for selected years
d    = UCIT_getMetaData(2);
OPT2 = grid_orth_getMapInfoFromDataset(d.catalog);

teller = 0; teller2 = 0;emptyyears = [];

for xx = 1 : length(years)
    
    figure(fh);
    [X, Y, Z] = grid_orth_getDataInPolygon(...
        'dataset'       , d.catalog, ...
        'urls'          , OPT2.urls, ...
        'x_ranges'      , OPT2.x_ranges, ...
        'y_ranges'      , OPT2.y_ranges, ...
        'tag'           , datatype, ...
        'starttime'     , datenum(years(xx),12,31), ...
        'searchinterval', -365.25, ...% this call is inside a year-loop
        'datathinning'  , 1,...       % line data do not need thinning
        'cellsize'      , d.cellsize,...
        'plotresult'    , 0,...
        'polygon'       , OPT.polygon,... % this functionality is also inside grid_orth_getDataInPolygon
        'warning'       , 0);         % prevent zillions of warnings for each one year in this loop is empty
    
    try delete(findobj('tag','selectionpoly'));  end %#ok<*TRYNC> delete any remaining poly
    
    %% compute isohypse based on first method (all data of each year)
    % compute area under certain depth
    dh = 0.25; teller3 = 0;
    for n = -50 : dh : 50
        teller3 = teller3 +1;
        height(teller3) = n;
        area  (teller3) = 20*20*sum(sum(Z < n));
    end
    
    % remember data of this year for method 2
    method2(xx).Z = Z;
    
    % cut off uninteresting ends
    area(find(area == max(area),1,'first')+1:end) = 999;
    area(1:find(area == 0,1,'last')-1) = 999;
    height = height(area ~= 999);
    area = area(area ~= 999);
    
    % add to figure
    figure(fn);
    if sum(sum(~isnan(Z))) > 0
        teller=teller+1;
        try
            figure(fn);set(fn,'visible','on');
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
    figure(fn);
    legend(legendtext);grid;
    title ('Cumulative area (Method 1: based on data points covered by target year)')
    xlabel('Area (m^2)');
    ylabel('Height (m)');
    set   (gca,'fontsize',8);
    
    disp  ([]);
    disp  (['Years without data are: '])
    for yy=1:length(emptyyears)
        disp([emptyyears{yy}]);
    end
    
else
    warning(['No data was found']);
    close(fn)
end

warning(warningstate)

%% compute isohypse based on second method (only data present in all years)
OPT.id = ones(size(method2(1).Z));
for j = 1 : length(years)
    id_of_year  = ~isnan(method2(j).Z);
    if sum(sum(id_of_year)) > 0
        if j == 1,OPT.id = id_of_year;,else,
            
            OPT.id = OPT.id & id_of_year;
        end
    end
end

teller = 0;teller2 = 0;clear legendtext emptyyears

% compute area under certain depth
for j = 1 : length(years)
    Z = method2(j).Z(OPT.id);
    dh = 0.25; teller3 = 0;
    for n = -50 : dh : 50
        teller3 = teller3 +1;
        height(teller3) = n;
        area  (teller3) = 20*20*sum(sum(Z < n));
    end
    
    % cut off uninteresting ends
    area(find(area == max(area),1,'first')+1:end) = 999;
    area(1:find(area == 0,1,'last')-1) = 999;
    height = height(area ~= 999);
    area = area(area ~= 999);
    
    
    % add data in figure
    if ~all(isnan(Z))
        teller=teller+1;
        try
            if ~exist('fn2')
                nameInfo = ['UCIT - Isohypse (method 2)'];
                fn2=figure('tag','crosssectionView','visible','off'); clf; ah=axes;
                set(fn2,'Name', nameInfo,'NumberTitle','Off','Units','normalized');
                UCIT_prepareFigureN(0, fn2, 'UR', ah);
                set(fn2,'visible','on');
            end
            figure(fn2);
            plot(area,height,'color',colors{teller},'linewidth',2);hold on;
            legendtext{teller}=([num2str(years(j))]);
        catch
            error(['Too many years!']);
        end
    else
        teller2=teller2+1;
        emptyyears{teller2}=num2str(years(j));
        warning(['Year ', num2str(years(j)),' has no data for the isohypse']);
    end
end

% add figure properties
if exist('fn2')
    figure(fn2);
    legend(legendtext);grid;
    title ('Cumulative area (Method 2: only based on data points present in all years)')
    xlabel('Area (m^2)');
    ylabel('Height (m)');
    set   (gca,'fontsize',8);
    
    disp  ([]);
    disp  (['Years without data are: '])
    for yy=1:length(emptyyears)
        disp([emptyyears{yy}]);
    end
    
else
    warning(['No data was found']);
    close(fn)
end

warning(warningstate)

%% EOF
