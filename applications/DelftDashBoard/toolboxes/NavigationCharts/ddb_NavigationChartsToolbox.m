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
    % setUIElements(handles.Model(md).GUI.elements.tabs(1).elements);
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
    end
end

%%
function selectDatabase
handles=getHandles;
h=findobj(gca,'Tag','NavigationChartLayer');
if ~isempty(h)
    delete(h);
end
handles.Toolbox(tb).Input.activeChart=1;
handles.Toolbox(tb).Input.activeChartName='';
handles=plotChartOutlines(handles);
setHandles(handles);
% setUIElement('textchartname');

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
ddb_exportChartShoreline(handles);

%%
function exportSoundings
handles=getHandles;
ddb_exportChartSoundings(handles);

%%
function exportContours
handles=getHandles;
ddb_exportChartContours(handles);

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

if posx>xlim(1) && posx<xlim(2) && posy>ylim(1) && posy<ylim(2)
    
    i=findBox(handles,posx,posy);
    
    kar=findobj(gca,'Tag','BBoxENC');
    set(kar,'Color','Blue');
    set(kar,'LineWidth',1);
    
    handles.Toolbox(tb).Input.activeChartName='';
    
    if ~isempty(i)
        kar=findobj(gca,'Tag','BBoxENC','UserData',i);
        set(kar,'Color','Red');
        handles.Toolbox(tb).Input.activeChartName=handles.Toolbox(tb).Input.charts(iac).box(i).Description;
    end
    
    setHandles(handles);
    
    % setUIElement('textchartname');
    
end

%%
function selectArea(hObject,eventdata)

handles=getHandles;

pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);
xlim=get(gca,'xlim');
ylim=get(gca,'ylim');

iab=handles.Toolbox(tb).Input.activeDatabase;
iac=handles.Toolbox(tb).Input.activeChart;

handles.Toolbox(tb).Input.activeChartName=handles.Toolbox(tb).Input.charts(iab).box(iac).Description;

switch get(gcf,'SelectionType')
    case{'normal'}
        
        if posx>xlim(1) && posx<xlim(2) && posy>ylim(1) && posy<ylim(2)
            i=findBox(handles,posx,posy);
            if ~isempty(i)
                handles=selectNavigationChart(handles,i);
                handles.Toolbox(tb).Input.activeChartName=handles.Toolbox(tb).Input.charts(iab).box(i).Description;
            else
                % Make chart outlines blue again
                kar=findobj(gca,'Tag','BBoxENC');
                set(kar,'Color','Blue');
                set(kar,'LineWidth',1);
                % Make active chart outline red
                kar=findobj(gca,'Tag','BBoxENC','UserData',iac);
                set(kar,'Color','Red');
                set(kar,'LineWidth',2);
            end
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

% setUIElement('textchartname');

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
fname=[handles.toolBoxDir 'NavigationCharts' filesep handles.Toolbox(tb).Input.databases{iac} filesep name filesep name '.mat'];
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

close(wb);

ddb_plotChartLayers(handles);

setHandles(handles);

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

