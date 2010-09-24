function handles=ddb_initializeScreen(handles)

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

ax=axes;
set(ax,'Units','pixels');
set(ax,'NextPlot','replace');
set(ax,'Position',[70 200 870 440]);
handles.GUIHandles.Axis=ax;

handles.ScreenParameters.CMin=-10000;
handles.ScreenParameters.CMax=10000;
handles.ScreenParameters.AutomaticColorLimits=1;
handles.ScreenParameters.ColorMap='Earth';

handles.ScreenParameters.XLim=[-180 180];
handles.ScreenParameters.YLim=[-90 90];

view(2);
set(handles.GUIHandles.Axis,'xlim',[-180 180],'ylim',[-90 90],'zlim',[-12000 10000]);
hold on;
zoom v6 on;

load([handles.SettingsDir 'colormaps\earth.mat']);
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

load([handles.SettingsDir 'geo\worldcoastline.mat']);
handles.GUIData.WorldCoastLine5000000(:,1)=wclx;
handles.GUIData.WorldCoastLine5000000(:,2)=wcly;

setHandles(handles);

c=load([handles.SettingsDir 'geo\cities.mat']);
for i=1:length(c.cities)
    handles.GUIData.cities.Lon(i)=c.cities(i).Lon;
    handles.GUIData.cities.Lat(i)=c.cities(i).Lat;
    handles.GUIData.cities.Name{i}=c.cities(i).Name;
end

