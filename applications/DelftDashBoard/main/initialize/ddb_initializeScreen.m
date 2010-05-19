function handles=ddb_initializeScreen(handles)

ax=axes;
set(ax,'Units','pixels');
set(ax,'NextPlot','replace');
set(ax,'Position',[70 200 870 440]);
handles.GUIHandles.Axis=ax;

% h=findall(gcf,'Tag','colorbar');
% axes(h);
%axes(handles.GUIHandles.Axis);

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

%handles.ScreenParameters.XMaxRange=[-270 270];
cl=load([handles.SettingsDir '\colormaps\earth2.txt']);
%handles.GUIData.ColorMaps.Earth=cl(:,1:3);
handles.GUIData.ColorMaps.Earth=cl;

setHandles(handles);

ddb_updateDataInScreen;

handles=getHandles;

[x,y]=landboundary('read',[handles.GeoDir '\worldcoastline5000000.ldb']);
handles.GUIData.WorldCoastLine5000000(:,1)=x;
handles.GUIData.WorldCoastLine5000000(:,2)=y;

[x,y]=ddb_getWVS([handles.GeoDir 'wvs\l\'],[-180 180],[-90 90],'l');

z=zeros(size(x))+500;

plt=plot3(x,y,z,'k');hold on;
set(plt,'HitTest','off');
set(plt,'Tag','WorldCoastLine');
setHandles(handles);

c=load([handles.GeoDir '\cities.mat']);
for i=1:length(c.cities)
    handles.GUIData.cities.Lon(i)=c.cities(i).Lon;
    handles.GUIData.cities.Lat(i)=c.cities(i).Lat;
    handles.GUIData.cities.Name{i}=c.cities(i).Name;
%     xc(i)=c.cities(i).Lon;
%     yc(i)=c.cities(i).Lat;
%     tx=text(xc(i),yc(i),[' ' c.cities(i).Name]);
%     set(tx,'HorizontalAlignment','left','VerticalAlignment','bottom');
%     set(tx,'FontSize',7,'Clipping','on');
%     set(tx,'Tag','WorldCities');
%     set(tx,'Visible','off');
end
% zc=zeros(size(xc))+500;
% plt=plot3(xc,yc,zc,'o');
% set(plt,'MarkerSize',4,'MarkerEdgeColor','none','MarkerFaceColor','r');
% set(plt,'Tag','WorldCities');
% set(plt,'Visible','off');

