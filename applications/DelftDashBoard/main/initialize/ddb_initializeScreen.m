function handles=ddb_initializeScreen(handles)

% Setting some screen parameters

% Model tabs
for i=1:length(handles.Model)
    elements=handles.Model(i).GUI.elements;
    subFields{1}='Model';
    subFields{2}='Input';
    subIndices={i,1};
    if ~isempty(elements)
        elements=addUIElements(gcf,elements,'subFields',subFields,'subIndices',subIndices,'getFcn',@getHandles,'setFcn',@setHandles);
        set(elements(1).handle,'Visible','off');
        handles.Model(i).GUI.elements=elements;
    end
end

% Map panel

% First make large panel to contain map axis, colorbar etc.
% The large panel will be a child of the active model gui

handles.GUIHandles.mapPanel=uipanel('Units','pixels','Position',[10 10 870 440],'Parent',handles.Model(i).GUI.elements(1).handle);

% Add map axis

ax=axes;
set(ax,'Parent',handles.GUIHandles.mapPanel);
set(ax,'Units','pixels');
set(ax,'NextPlot','replace');
set(ax,'Position',[70 200 870 440]);
handles.GUIHandles.Axis=ax;

handles.GUIHandles.textAnn=annotation('textbox',[0.02 0.02 0.4 0.2]);

handles.screenParameters.cMin=-10000;
handles.screenParameters.cMax=10000;
handles.screenParameters.automaticColorLimits=1;
handles.screenParameters.colorMap='Earth';

handles.screenParameters.xLim=[-180 180];
handles.screenParameters.yLim=[-90 90];

view(2);
set(handles.GUIHandles.Axis,'xlim',[-180 180],'ylim',[-90 90],'zlim',[-12000 10000]);
hold on;
zoom v6 on;

load([handles.settingsDir 'colormaps\earth.mat']);
handles.GUIData.ColorMaps.Earth=earth;

setHandles(handles);

x=0;
y=0;
z=zeros(size(x))+500;

plt=plot3(x,y,z,'k');hold on;
set(plt,'HitTest','off');
set(plt,'Tag','WorldCoastLine');

ddb_updateDataInScreen;

handles=getHandles;

load([handles.settingsDir 'geo\worldcoastline.mat']);
handles.GUIData.WorldCoastLine5000000(:,1)=wclx;
handles.GUIData.WorldCoastLine5000000(:,2)=wcly;

setHandles(handles);

c=load([handles.settingsDir 'geo\cities.mat']);
for i=1:length(c.cities)
    handles.GUIData.cities.Lon(i)=c.cities(i).Lon;
    handles.GUIData.cities.Lat(i)=c.cities(i).Lat;
    handles.GUIData.cities.Name{i}=c.cities(i).Name;
end

