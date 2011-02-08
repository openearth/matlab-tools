function ddb_makeMapPanel

handles=getHandles;

% Map panel

% First make large panel to contain map axis, colorbar etc.
% The large panel will be a child of the active model gui

handles.GUIHandles.mapPanel=uipanel('Units','pixels','Position',[5 175 870 440],'Parent',handles.Model(1).GUI.elements(1).handle,'BorderType','none','BackgroundColor','none');

% Add map axis

handles.GUIHandles.mapAxisPanel=uipanel('Units','pixels','Position',[70 200 870 440],'Parent',handles.GUIHandles.mapPanel,'BorderType','beveledin','BorderWidth',2,'BackgroundColor','none');

ax=axes;
set(ax,'Parent',handles.GUIHandles.mapAxisPanel);
set(ax,'Units','pixels');
set(ax,'NextPlot','replace');
set(ax,'Position',[1 1 10 10]);
set(ax,'Box','off');
set(ax,'TickLength',[0 0]);

view(2);
set(ax,'xlim',[-180 180],'ylim',[-90 90],'zlim',[-12000 10000]);
hold on;
zoom v6 on;

handles.GUIHandles.mapAxis=ax;

% Adding colorbar
setHandles(handles);
ddb_colorBar('make');
handles=getHandles;

% Coordinate text
handles.GUIHandles.TextXCoordinate = uicontrol(gcf,'Units','pixels','Parent',handles.GUIHandles.mapPanel,'Style','text', ...
    'String',['X : ' num2str(0)],'Position',[300 655 100 15],'BackgroundColor',handles.backgroundColor,'HorizontalAlignment','left');
handles.GUIHandles.TextYCoordinate = uicontrol(gcf,'Units','pixels','Parent',handles.GUIHandles.mapPanel,'Style','text', ...
    'String',['Y : ' num2str(0)],'Position',[380 655 100 15],'BackgroundColor',handles.backgroundColor,'HorizontalAlignment','left');
handles.GUIHandles.TextCoordinateSystem = uicontrol(gcf,'Units','pixels','Parent',handles.GUIHandles.mapPanel,'Style','text', ...
    'String','WGS 84 - Geographic','Position',[100 655 200 15],'BackgroundColor',handles.backgroundColor,'HorizontalAlignment','left');

% Text box
handles.GUIHandles.textAnn1=annotation('textbox',[0.02 0.3 0.4 0.2]);
set(handles.GUIHandles.textAnn1,'Units','pixels');
set(handles.GUIHandles.textAnn1,'Position',[50 235 600 20]);
set(handles.GUIHandles.textAnn1,'VerticalAlignment','bottom');
set(handles.GUIHandles.textAnn1,'FontSize',12,'FontWeight','bold','LineStyle','none');
handles.GUIHandles.textAnn2=annotation('textbox',[0.02 0.3 0.4 0.2]);
set(handles.GUIHandles.textAnn2,'Units','pixels');
set(handles.GUIHandles.textAnn2,'Position',[50 215 600 20]);
set(handles.GUIHandles.textAnn2,'VerticalAlignment','bottom');
set(handles.GUIHandles.textAnn2,'FontSize',12,'FontWeight','bold','LineStyle','none');
handles.GUIHandles.textAnn3=annotation('textbox',[0.02 0.3 0.4 0.2]);
set(handles.GUIHandles.textAnn3,'Units','pixels');
set(handles.GUIHandles.textAnn3,'Position',[50 195 600 20]);
set(handles.GUIHandles.textAnn3,'VerticalAlignment','bottom');
set(handles.GUIHandles.textAnn3,'FontSize',12,'FontWeight','bold','LineStyle','none');

% Now initialize the dummy data
% Bathymetry
xx=[0 1];
yy=[0 1];
cdata=zeros(2,2,3);
handles.mapHandles.bathymetry=image(xx,yy,cdata);hold on;
set(handles.mapHandles.bathymetry,'Tag','bathymetry','HitTest','off');

% Shoreline
handles.mapHandles.shoreline=plot3(0,0,500,'k');hold on;
set(handles.mapHandles.shoreline,'HitTest','off','Tag','shoreline');

% Cities
for i=1:length(handles.mapData.cities.lon)
    tx=text(handles.mapData.cities.lon(i),handles.mapData.cities.lat(i),[' ' handles.mapData.cities.name{i}]);
    set(tx,'HorizontalAlignment','left','VerticalAlignment','bottom');
    set(tx,'FontSize',7,'Clipping','on','HitTest','off');
    set(tx,'Tag','textWorldCitiesText');
    handles.mapHandles.textCities(i)=tx;
end
zc=zeros(size(handles.mapData.cities.lon))+500;
handles.mapHandles.cities=plot3(handles.mapData.cities.lon,handles.mapData.cities.lat,zc,'o');
set(handles.mapHandles.cities,'MarkerSize',4,'MarkerEdgeColor','none','MarkerFaceColor','r');
set(handles.mapHandles.cities,'Tag','WorldCities','HitTest','off');

set(handles.mapHandles.cities,'Visible','off');
set(handles.mapHandles.textCities,'Visible','off');

setHandles(handles);

