function ddb_NavigationChartsToolbox

handles=getHandles;

h=findall(gca,'Tag','BBoxENC');
if isempty(h)
    handles=PlotChartOutlines(handles);
else
    ddb_plotNavigationCharts(handles,'activate');
end

iac=handles.Toolbox(tb).ActiveDatabase;
ii=handles.Toolbox(tb).ActiveChart;

uipanel('Title','Navigation Charts','Units','pixels','Position',[50 20 960 160],'Tag','UIControl');

handles.PushSelectChart        = uicontrol(gcf,'Style','pushbutton','String','Select Chart','Position',   [60 140 140  20],'Tag','UIControl');
handles.PushPlotOptions        = uicontrol(gcf,'Style','pushbutton','String','Plot Options','Position',   [220 140 140  20],'Tag','UIControl');
set(handles.PushPlotOptions,  'Enable','off');
handles.PushDeleteChart        = uicontrol(gcf,'Style','pushbutton','String','Delete Chart','Position',   [370 140 140  20],'Tag','UIControl');
handles.PushExportShoreline = uicontrol(gcf,'Style','pushbutton','String','Export Land Boundary',      'Position',   [60  115 140  20],'Tag','UIControl');
handles.PushExportSoundings    = uicontrol(gcf,'Style','pushbutton','String','Export Depth Soundings',    'Position',   [60  90 140  20],'Tag','UIControl');
handles.PushExportContours     = uicontrol(gcf,'Style','pushbutton','String','Export Depth Contours',     'Position',   [60  65 140  20],'Tag','UIControl');

handles.ToggleShoreline     = uicontrol(gcf,'Style','checkbox','String','Show Land Boundary','Value',handles.Toolbox(tb).ShowShoreline,'Position',   [220 110 150  20],'Tag','UIControl');
handles.ToggleSoundings        = uicontrol(gcf,'Style','checkbox','String','Show Depth Soundings','Value',handles.Toolbox(tb).ShowSoundings,'Position',   [220 85 150  20],'Tag','UIControl');
handles.ToggleContours         = uicontrol(gcf,'Style','checkbox','String','Show Depth Contours','Value',handles.Toolbox(tb).ShowContours,'Position',   [220 60 150  20],'Tag','UIControl');

str=handles.Toolbox(tb).Charts(iac).Box(ii).Description;
handles.TextChartNr     = uicontrol(gcf,'Style','text','String',str,      'Position',   [60  30 500  20],'HorizontalAlignment','left','Tag','UIControl');

set(handles.PushSelectChart,  'Callback',{@PushSelectChart_Callback});
set(handles.PushPlotOptions,  'Callback',{@PushPlotOptions_Callback});
set(handles.PushDeleteChart,  'Callback',{@PushDeleteChart_Callback});
set(handles.PushExportShoreline,       'Callback',{@PushExportShoreline_Callback});
set(handles.PushExportSoundings,       'Callback',{@PushExportSoundings_Callback});
set(handles.PushExportContours,       'Callback',{@PushExportContours_Callback});

set(handles.ToggleShoreline,  'Callback',{@ToggleShoreline_Callback});
set(handles.ToggleSoundings,     'Callback',{@ToggleSoundings_Callback});
set(handles.ToggleContours,      'Callback',{@ToggleContours_Callback});

SetUIBackgroundColors;

setHandles(handles);
 
% Refresh(handles);

%%
function PushSelectChart_Callback(hObject,eventdata)
ddb_zoomOff;
set(gcf,'WindowButtonMotionFcn',@MoveMouse);
set(gcf,'WindowButtonDownFcn',@SelectArea);

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
function ToggleShoreline_Callback(hObject,eventdata)
handles=getHandles;
iplt=get(hObject,'Value');
handles.Toolbox(tb).ShowShoreline=iplt;
h=findall(gca,'Tag','NavigationChartLayer','UserData','LNDARE');
if ~isempty(h)
    if iplt
        set(h,'Visible','on');
    else
        set(h,'Visible','off');
    end
end
setHandles(handles);

%%
function ToggleSoundings_Callback(hObject,eventdata)
handles=getHandles;
iplt=get(hObject,'Value');
handles.Toolbox(tb).ShowSoundings=iplt;
h=findall(gca,'Tag','NavigationChartLayer','UserData','SOUNDG');
if ~isempty(h)
    if iplt
        set(h,'Visible','on');
    else
        set(h,'Visible','off');
    end
end
setHandles(handles);

%%
function ToggleContours_Callback(hObject,eventdata)
handles=getHandles;
iplt=get(hObject,'Value');
handles.Toolbox(tb).ShowContours=iplt;
h=findall(gca,'Tag','NavigationChartLayer','UserData','DEPCNT');
if ~isempty(h)
    if iplt
        set(h,'Visible','on');
    else
        set(h,'Visible','off');
    end
end
setHandles(handles);

%%
function PushExportShoreline_Callback(hObject,eventdata)
handles=getHandles;
ddb_exportChartShoreline(handles);

%%
function PushExportSoundings_Callback(hObject,eventdata)
handles=getHandles;
ddb_exportChartSoundings(handles);

%%
function PushExportContours_Callback(hObject,eventdata)
handles=getHandles;
ddb_exportChartContours(handles);

%%
function handles=ChangeNavigationChartsDatabase(handles)

%%
function MoveMouse(hObject,eventdata)

handles=getHandles;

iac=handles.Toolbox(tb).ActiveDatabase;

pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);
xlim=get(gca,'xlim');
ylim=get(gca,'ylim');

str=handles.Toolbox(tb).Charts(iac).Box(handles.Toolbox(tb).ActiveChart).Description;

if posx>xlim(1) && posx<xlim(2) && posy>ylim(1) && posy<ylim(2)

    i=FindBox(handles,posx,posy);
    
    kar=findall(gca,'Tag','BBoxENC');
    set(kar,'Color','Blue');
    set(kar,'LineWidth',1);

    if ~isempty(i)
        kar=findobj(gcf,'Tag','BBoxENC','UserData',i);
        set(kar,'Color','Red');
        str=handles.Toolbox(tb).Charts(iac).Box(i).Description;
    end

end
set(handles.TextChartNr,'String',str);

%%
function SelectArea(hObject,eventdata)

handles=getHandles;

pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);
xlim=get(gca,'xlim');
ylim=get(gca,'ylim');

if posx>xlim(1) && posx<xlim(2) && posy>ylim(1) && posy<ylim(2)

    i=FindBox(handles,posx,posy);
    
    if ~isempty(i)
        handles=SelectNavigationChart(handles,i);
        setHandles(handles);
    else
        % Make chart outlines blue again
        kar=findobj(gca,'Tag','BBoxENC');
        set(kar,'Color','Blue');
        set(kar,'LineWidth',1);
        % Make active chart outline red
        kar=findobj(gcf,'Tag','BBoxENC','UserData',handles.Toolbox(tb).ActiveChart);
        set(kar,'Color','Red');
        set(kar,'LineWidth',2);
    end

end

ddb_setWindowButtonUpDownFcn;
ddb_setWindowButtonMotionFcn;

%%
function handles=SelectNavigationChart(handles,i)

iac=handles.Toolbox(tb).ActiveDatabase;

kar=findall(gca,'Tag','BBoxENC');
set(kar,'Color','Blue','LineWidth',1);
set(kar,'LineWidth',1);

kar=findobj(gcf,'Tag','BBoxENC','UserData',i);
set(kar,'Color','Red');
set(kar,'LineWidth',2);
handles.Toolbox(tb).ActiveChart=i;

wb=waitbox('Loading chart ...');
name=handles.Toolbox(tb).Charts(iac).Box(i).Name;
fname=[handles.ToolBoxDir 'NavigationCharts' filesep handles.Toolbox(tb).Databases{iac} filesep name filesep name '.mat'];
load(fname);

handles.Toolbox(tb).Layers=s.Layers;

fn=fieldnames(s.Layers);
for i=1:length(fn)
    layer=deblank(fn{i});
    switch lower(layer)
        case{'lndare'}
            handles.Toolbox(tb).PlotLayer.(layer)=handles.Toolbox(tb).ShowShoreline;
        case{'depcnt'}
            handles.Toolbox(tb).PlotLayer.(layer)=handles.Toolbox(tb).ShowContours;
        case{'soundg'}
            handles.Toolbox(tb).PlotLayer.(layer)=handles.Toolbox(tb).ShowSoundings;
        otherwise
            handles.Toolbox(tb).PlotLayer.(layer)=-1;
    end
end

close(wb);

ddb_plotChartLayers(handles);

setHandles(handles);

set(handles.TextChartNr,'String',handles.Toolbox(tb).Charts(iac).Box(handles.Toolbox(tb).ActiveChart).Description);

%%
function i=FindBox(handles,x,y)

iac=handles.Toolbox(tb).ActiveDatabase;

area=handles.Toolbox(tb).Charts(iac).Area;
x1=handles.Toolbox(tb).Charts(iac).xl(:,1);
x2=handles.Toolbox(tb).Charts(iac).xl(:,2);
y1=handles.Toolbox(tb).Charts(iac).yl(:,1);
y2=handles.Toolbox(tb).Charts(iac).yl(:,2);

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
function handles=PlotChartOutlines(handles)

h=findall(gca,'Tag','BBoxENC');
delete(h);

cs.Name='WGS 84';
cs.Type='Geographic';

iac=handles.Toolbox(tb).ActiveDatabase;

n=length(handles.Toolbox(tb).Charts(iac).Box);

for i=1:n
    x1(i)=handles.Toolbox(tb).Charts(iac).Box(i).X(1);
    y1(i)=handles.Toolbox(tb).Charts(iac).Box(i).Y(1);
    x2(i)=handles.Toolbox(tb).Charts(iac).Box(i).X(2);
    y2(i)=handles.Toolbox(tb).Charts(iac).Box(i).Y(2);
end

[x1,y1]=ddb_coordConvert(x1,y1,cs,handles.ScreenParameters.CoordinateSystem);
[x2,y2]=ddb_coordConvert(x2,y2,cs,handles.ScreenParameters.CoordinateSystem);

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

handles.Toolbox(tb).Charts(iac).xl=xl;
handles.Toolbox(tb).Charts(iac).yl=yl;
handles.Toolbox(tb).Charts(iac).Area=area;


i=handles.Toolbox(tb).ActiveChart;
kar=findobj(gca,'Tag','BBoxENC','UserData',i);
set(kar,'Color','Red');
set(kar,'LineWidth',2);



