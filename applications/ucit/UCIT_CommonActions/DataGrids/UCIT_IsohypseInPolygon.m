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
   
   curdir=pwd;
   colors={'b',[0.2 0.6 0],'k','c','m','r', [0.6 0.4 0],[0.2 0.4 0 ], [0.5 0.5 0.5], [1 0.5 0.5],'y',  [0.25 0.5 0.5],[0.5 0 0.5] ,[1 0.5 0.25],[0.5 1 0.5],[0.2 0 1],[1 0.5 1],[0.5 0.5 0.75] };

%% Specify polygon

   try delete(findobj(fh,'tag','isohypse_polygon'));  end

   if nargin == 0
       figure(fh);
       [xv,yv] = polydraw;polygon=[xv' yv'];
   else
       load(polygonname)
   end

   lh   = line(xv,yv);
   set(lh,'color','g','linewidth',2,'tag','isohypse_polygon');

%% Get user input

   year1 = str2double(datestr(datenum(UCIT_getInfoFromPopup('GridsName')) ...
     - 30*(str2double(                UCIT_getInfoFromPopup('GridsInterval'))),10));
   year2 = str2double(datestr(datenum(UCIT_getInfoFromPopup('GridsName')),10));
   years = [year1 : year2];

%% Set up figure

   fn=findobj('tag', 'crosssectionView');
   if isempty(fn)
       nameInfo = ['UCIT - Isohypse'];
       fn=figure('tag','crosssectionView','visible','off'); clf; ah=axes;
       set(fn,'Name', nameInfo,'NumberTitle','Off','Units','normalized');
       UCIT_prepareFigureN(0, fn, 'UR', ah);
   end

% Find data around selected crosssection for selected years

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
    'polygon'       , polygon,... % this functionality is also inside grid_orth_getDataInPolygon
    'warning'       , 0);         % prevent zillions of warnings for each one year in this loop is empty

    try delete(findobj('tag','selectionpoly'));  end %#ok<*TRYNC> delete any remaining poly
    
    %% compute area under certain depth
    dh = 1; teller3 = 0;
    for n = -50 : dh : 50
        teller3 = teller3 +1;
        height(teller3) = n;
        area  (teller3) = 20*20*sum(sum(Z < n));
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

%% add figure properties

if exist('legendtext')
    figure(fn);
    legend(legendtext);grid;
    title ('Cumulative area')
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
