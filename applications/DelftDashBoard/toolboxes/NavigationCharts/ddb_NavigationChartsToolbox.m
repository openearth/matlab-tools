function ddb_NavigationChartsToolbox(varargin)
%DDB_NAVIGATIONCHARTSTOOLBOX  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_NavigationChartsToolbox(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_NavigationChartsToolbox
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
if isempty(varargin)
    % New tab selected
    handles=getHandles;
    ddb_zoomOff;
    ddb_refreshScreen;
    selectDatabase;
    h=findobj(gca,'Tag','BBoxENC');
    if isempty(h)
        handles=plotChartOutlines(handles);
        setHandles(handles);
    else
        ddb_plotNavigationCharts('activate');
    end
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'selectdatabase'}
            selectDatabase;
        case{'selectchart'}
            pushSelectChart;
        case{'toggleshoreline'}
            toggleShoreline;
        case{'togglesoundings'}
            toggleSoundings;
        case{'togglecontours'}
            toggleContours;
        case{'exportshoreline'}
            exportShoreline;
        case{'exportsoundings'}
            exportSoundings;
        case{'exportcontours'}
            exportContours;
        case{'drawpolygon'}
            drawPolygon;
        case{'exportalldatainpolygon'}
            exportAllDataInPolygon;
    end
end

%%
function selectDatabase
handles=getHandles;
h=findobj(gca,'Tag','NavigationChartLayer');
if ~isempty(h)
    delete(h);
end
handles.Toolbox(tb).Input.activeChart=0;
handles.Toolbox(tb).Input.activeChartName='';
handles=plotChartOutlines(handles);
setHandles(handles);

%%
function pushSelectChart
ddb_zoomOff;
set(gcf,'WindowButtonMotionFcn',@moveMouse);
set(gcf,'WindowButtonDownFcn',@selectArea);

%%
function PushPlotOptions_Callback(hObject,eventdata)
ddb_navigationChartPlotOptions;

%%
function PushDeleteChart_Callback(hObject,eventdata)
h=findall(gca,'Tag','NavigationChartLayer');
if ~isempty(h)
    delete(h);
end

%%
function toggleShoreline
handles=getHandles;
iplt=handles.Toolbox(tb).Input.showShoreline;
h=findobj(gca,'Tag','NavigationChartLayer','UserData','LNDARE');
if ~isempty(h)
    if iplt
        set(h,'Visible','on');
    else
        set(h,'Visible','off');
    end
end

%%
function toggleSoundings
handles=getHandles;
iplt=handles.Toolbox(tb).Input.showSoundings;
h=findobj(gca,'Tag','NavigationChartLayer','UserData','SOUNDG');
if ~isempty(h)
    if iplt
        set(h,'Visible','on');
    else
        set(h,'Visible','off');
    end
end

%%
function toggleContours
handles=getHandles;
iplt=handles.Toolbox(tb).Input.showContours;
h=findobj(gca,'Tag','NavigationChartLayer','UserData','DEPCNT');
if ~isempty(h)
    if iplt
        set(h,'Visible','on');
    else
        set(h,'Visible','off');
    end
end

%%
function exportShoreline
handles=getHandles;

iac=handles.Toolbox(tb).Input.activeDatabase;
ii=handles.Toolbox(tb).Input.activeChart;
fname=handles.Toolbox(tb).Input.charts(iac).box(ii).Name;

[filename, pathname, filterindex] = uiputfile('*.ldb', 'Select land boundary file',[fname '_shoreline.ldb']);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    
    wb=waitbox('Exporting Ldb File ...');
        
    newsys=handles.screenParameters.coordinateSystem;
    
    s=handles.Toolbox(tb).Input.layers;

    ddb_exportChartShoreline(s,filename,newsys);
    
    close(wb);

end


%%
function exportSoundings
handles=getHandles;

iac=handles.Toolbox(tb).Input.activeDatabase;
ii=handles.Toolbox(tb).Input.activeChart;
fname=handles.Toolbox(tb).Input.charts(iac).box(ii).Name;

[filename, pathname, filterindex] = uiputfile('*.xyz', 'Select XYZ File',[fname '_soundings.xyz']);

if pathname~=0
    
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    
    wb=waitbox('Exporting XYZ file ...');
        
    newsys=handles.screenParameters.coordinateSystem;
    
    s=handles.Toolbox(tb).Input.layers;
    
    ddb_exportChartSoundings(s,filename,newsys);
    
    close(wb);
    
end

%%
function exportContours
handles=getHandles;

iac=handles.Toolbox(tb).Input.activeDatabase;
ii=handles.Toolbox(tb).Input.activeChart;
fname=handles.Toolbox(tb).Input.charts(iac).box(ii).Name;

[filename, pathname, filterindex] = uiputfile('*.xyz', 'Select XYZ File',[fname '_contours.xyz']);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    
    wb=waitbox('Exporting XYZ File ...');
        
    newsys=handles.screenParameters.coordinateSystem;
    
    s=handles.Toolbox(tb).Input.layers;

    ddb_exportChartContours(s,filename,newsys);

    close(wb);
    
end

%%
function exportAllDataInPolygon

handles=getHandles;
iac=handles.Toolbox(tb).Input.activeDatabase;

wb = awaitbar(0,'Downloading chart data ...');
[hh,abort2]=awaitbar(0.001,wb,'Downloading chart data ...');

% First determine which charts need to be exported
ncharts=0;
for ic=1:length(handles.Toolbox(tb).Input.charts(iac).box)    
    x1=handles.Toolbox(tb).Input.charts(iac).xl(ic,1);
    x2=handles.Toolbox(tb).Input.charts(iac).xl(ic,2);
    y1=handles.Toolbox(tb).Input.charts(iac).yl(ic,1);
    y2=handles.Toolbox(tb).Input.charts(iac).yl(ic,2);    
    if inpolygon(x1,y1,handles.Toolbox(tb).Input.polygonX,handles.Toolbox(tb).Input.polygonY) || ...
            inpolygon(x1,y2,handles.Toolbox(tb).Input.polygonX,handles.Toolbox(tb).Input.polygonY) || ...
            inpolygon(x2,y2,handles.Toolbox(tb).Input.polygonX,handles.Toolbox(tb).Input.polygonY) || ...
            inpolygon(x2,y1,handles.Toolbox(tb).Input.polygonX,handles.Toolbox(tb).Input.polygonY)        
        ncharts=ncharts+1;
        ichart(ncharts)=ic;
    end
end

% And download the data
for ich=1:ncharts

    ic=ichart(ich);
    
    str=['Exporting ' handles.Toolbox(tb).Input.charts(iac).box(ic).Name ' - ' num2str(ich) ' of ' num2str(ncharts)];
    [hh,abort2]=awaitbar(ich/ncharts,wb,str);
    
    if abort2 % Abort the process by clicking abort button
        break;
    end;
    if isempty(hh); % Break the process when closing the figure
        break;
    end;
            
    name=handles.Toolbox(tb).Input.charts(iac).box(ic).Name;
    dr=[handles.toolBoxDir 'NavigationCharts' filesep handles.Toolbox(tb).Input.charts(iac).name filesep];
    fname=[dr name filesep name '.mat'];
    
    if ~exist(fname,'file')
        % File does not yet exist in cache, try to download it
        if ~exist(dr,'dir')
            mkdir(dr);
        end
        if ~exist([dr name],'dir')
            mkdir([dr name]);
        end
        try
            ddb_urlwrite([handles.Toolbox(tb).Input.charts(iac).url '/' name '/' name '.mat'],fname);
        catch
            break
        end
    end
    
    s=load(fname);
    if isfield(s,'s')
        s=s.s;
    end
    
    newsys=handles.screenParameters.coordinateSystem;
    
    filename=[handles.Toolbox(tb).Input.charts(iac).box(ic).Name '_contours.xyz'];
    ddb_exportChartContours(s.Layers,filename,newsys);
    filename=[handles.Toolbox(tb).Input.charts(iac).box(ic).Name '_soundings.xyz'];
    ddb_exportChartSoundings(s.Layers,filename,newsys);
    filename=[handles.Toolbox(tb).Input.charts(iac).box(ic).Name '_shoreline.ldb'];
    ddb_exportChartShoreline(s.Layers,filename,newsys);
    
end

% close waitbar
if ~isempty(hh)
    close(wb);
end


%%
function handles=ChangeNavigationChartsDatabase(handles)

%%
function moveMouse(hObject,eventdata)

handles=getHandles;

iac=handles.Toolbox(tb).Input.activeDatabase;

pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);
xlim=get(gca,'xlim');
ylim=get(gca,'ylim');

iupdate=0;

if posx>xlim(1) && posx<xlim(2) && posy>ylim(1) && posy<ylim(2)
    
    % Mouse within axis
    
    i=findBox(handles,posx,posy);
    
    if ~isempty(i)
        if ~strcmpi(handles.Toolbox(tb).Input.charts(iac).box(i).Description,handles.Toolbox(tb).Input.oldChartName)
            % We've moved into a new chart
            % Make old box blue again
            kar=findobj(gca,'Tag','BBoxENC','UserData',handles.Toolbox(tb).Input.selectedChart);
            if ~isempty(kar)
                set(kar,'Color','Blue');
                set(kar,'LineWidth',1);
            end            
            kar=findobj(gca,'Tag','BBoxENC','UserData',i);
            set(kar,'Color',[1 0.5 0]);
            set(kar,'LineWidth',2);
            handles.Toolbox(tb).Input.activeChartName=handles.Toolbox(tb).Input.charts(iac).box(i).Description;
            handles.Toolbox(tb).Input.oldChartName=handles.Toolbox(tb).Input.activeChartName;
            iupdate=1;
        end
        handles.Toolbox(tb).Input.selectedChart=i;
    else
        % Outside of charts
        if handles.Toolbox(tb).Input.activeChart>0
            % Show chart selected originally
            handles.Toolbox(tb).Input.activeChartName=handles.Toolbox(tb).Input.charts(iac).box(handles.Toolbox(tb).Input.activeChart).Description;
        end
        if ~strcmpi(handles.Toolbox(tb).Input.activeChartName,handles.Toolbox(tb).Input.oldChartName)
            handles.Toolbox(tb).Input.oldChartName=handles.Toolbox(tb).Input.activeChartName;
            kar=findobj(gca,'Tag','BBoxENC','UserData',handles.Toolbox(tb).Input.selectedChart);
            if ~isempty(kar)
                set(kar,'Color','Blue');
                set(kar,'LineWidth',1);
            end
            iupdate=1;
        end
        handles.Toolbox(tb).Input.selectedChart=0;
    end
    
    setHandles(handles);
    if iupdate
        gui_updateActiveTab;
    end
end

%%
function selectArea(hObject,eventdata)

handles=getHandles;

iab=handles.Toolbox(tb).Input.activeDatabase;
iac=handles.Toolbox(tb).Input.activeChart;

switch get(gcf,'SelectionType')
    case{'normal'}        
        i=handles.Toolbox(tb).Input.selectedChart;
        if i>0
            handles=selectNavigationChart(handles,i);
            handles.Toolbox(tb).Input.activeChartName=handles.Toolbox(tb).Input.charts(iab).box(i).Description;
        end
    otherwise
        % Make chart outlines blue again
        kar=findobj(gca,'Tag','BBoxENC');
        set(kar,'Color','Blue');
        set(kar,'LineWidth',1);
        % Make active chart outline red
        kar=findobj(gca,'Tag','BBoxENC','UserData',iac);
        set(kar,'Color','Red');
        set(kar,'LineWidth',2);
end

setHandles(handles);

gui_updateActiveTab;

ddb_setWindowButtonUpDownFcn;
ddb_setWindowButtonMotionFcn;

%%
function handles=selectNavigationChart(handles,i)

iac=handles.Toolbox(tb).Input.activeDatabase;

kar=findobj(gca,'Tag','BBoxENC');
set(kar,'Color','Blue','LineWidth',1);
set(kar,'LineWidth',1);

kar=findobj(gca,'Tag','BBoxENC','UserData',i);
set(kar,'Color','Red');
set(kar,'LineWidth',2);
handles.Toolbox(tb).Input.activeChart=i;

wb=waitbox('Loading chart ...');
name=handles.Toolbox(tb).Input.charts(iac).box(i).Name;
dr=[handles.toolBoxDir 'NavigationCharts' filesep handles.Toolbox(tb).Input.charts(iac).name filesep];
fname=[dr name filesep name '.mat'];

if ~exist(fname,'file')
    % File does not yet exist in cache, try to download it
    if ~exist(dr,'dir')
        mkdir(dr);        
    end
    if ~exist([dr name],'dir')
        mkdir([dr name]);
    end
    try
        ddb_urlwrite([handles.Toolbox(tb).Input.charts(iac).url '/' name '/' name '.mat'],fname);
    catch
        close(wb);
        ddb_giveWarning('text','Sorry, an error occured while downloading the chart data ...');
        return
    end
end

s=load(fname);

if isfield(s,'s')
    s=s.s;
end

handles.Toolbox(tb).Input.layers=s.Layers;

fn=fieldnames(s.Layers);
for i=1:length(fn)
    layer=deblank(fn{i});
    switch lower(layer)
        case{'lndare'}
            handles.Toolbox(tb).Input.plotLayer.(layer)=handles.Toolbox(tb).Input.showShoreline;
        case{'depcnt'}
            handles.Toolbox(tb).Input.plotLayer.(layer)=handles.Toolbox(tb).Input.showContours;
        case{'soundg'}
            handles.Toolbox(tb).Input.plotLayer.(layer)=handles.Toolbox(tb).Input.showSoundings;
        otherwise
            handles.Toolbox(tb).Input.plotLayer.(layer)=-1;
    end
end

ddb_plotChartLayers(handles);

close(wb);

%%
function i=findBox(handles,x,y)

iac=handles.Toolbox(tb).Input.activeDatabase;

area=handles.Toolbox(tb).Input.charts(iac).area;
x1=handles.Toolbox(tb).Input.charts(iac).xl(:,1);
x2=handles.Toolbox(tb).Input.charts(iac).xl(:,2);
y1=handles.Toolbox(tb).Input.charts(iac).yl(:,1);
y2=handles.Toolbox(tb).Input.charts(iac).yl(:,2);

ii=find(x>x1 & x<x2 & y>y1 & y<y2);

n=length(ii);

i=[];

if n>0
    area2=[];
    for j=1:n
        area2(j)=area(ii(j));
    end
    [rdum,ij] = min(area2);
    i=ii(ij);
end

%%
function handles=plotChartOutlines(handles)

h=findobj(gca,'Tag','BBoxENC');
delete(h);

cs.name='WGS 84';
cs.type='Geographic';

iac=handles.Toolbox(tb).Input.activeDatabase;

n=length(handles.Toolbox(tb).Input.charts(iac).box);

for i=1:n
    x1(i)=handles.Toolbox(tb).Input.charts(iac).box(i).X(1);
    y1(i)=handles.Toolbox(tb).Input.charts(iac).box(i).Y(1);
    x2(i)=handles.Toolbox(tb).Input.charts(iac).box(i).X(2);
    y2(i)=handles.Toolbox(tb).Input.charts(iac).box(i).Y(2);
end

[x1,y1]=ddb_coordConvert(x1,y1,cs,handles.screenParameters.coordinateSystem);
[x2,y2]=ddb_coordConvert(x2,y2,cs,handles.screenParameters.coordinateSystem);

for i=1:n
    xx=[x1(i) x2(i) x2(i) x1(i) x1(i)];
    yy=[y1(i) y1(i) y2(i) y2(i) y1(i)];
    plt=plot(xx,yy);hold on;
    set(plt,'Tag','BBoxENC','UserData',i);
    xl(i,1)=min(x1(i),x2(i));
    xl(i,2)=max(x1(i),x2(i));
    yl(i,1)=min(y1(i),y2(i));
    yl(i,2)=max(y1(i),y2(i));
    area(i)=(xl(i,2)-xl(i,1))*(yl(i,2)-yl(i,1));
end

handles.Toolbox(tb).Input.charts(iac).xl=xl;
handles.Toolbox(tb).Input.charts(iac).yl=yl;
handles.Toolbox(tb).Input.charts(iac).area=area;

i=handles.Toolbox(tb).Input.activeChart;
kar=findobj(gca,'Tag','BBoxENC','UserData',i);
set(kar,'Color','Red');
set(kar,'LineWidth',2);


%%
function drawPolygon

handles=getHandles;
ddb_zoomOff;
h=findobj(gcf,'Tag','navigationchartspolygon');
if ~isempty(h)
    delete(h);
end

handles.Toolbox(tb).Input.polygonX=[];
handles.Toolbox(tb).Input.polygonY=[];
handles.Toolbox(tb).Input.polyLength=0;

handles.Toolbox(tb).Input.polygonhandle=gui_polyline('draw','tag','navigationchartspolygon','marker','o', ...
    'createcallback',@createPolygon,'changecallback',@changePolygon, ...
    'closed',1);

setHandles(handles);

%%
function createPolygon(h,x,y)
handles=getHandles;
handles.Toolbox(tb).Input.polygonhandle=h;
handles.Toolbox(tb).Input.polygonX=x;
handles.Toolbox(tb).Input.polygonY=y;
handles.Toolbox(tb).Input.polyLength=length(x);
setHandles(handles);
gui_updateActiveTab;

%%
function changePolygon(h,x,y,varargin)
handles=getHandles;
handles.Toolbox(tb).Input.polygonX=x;
handles.Toolbox(tb).Input.polygonY=y;
handles.Toolbox(tb).Input.polyLength=length(x);
setHandles(handles);
