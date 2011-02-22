function ddb_plotTimeSeries(times,prediction,name)

handles=getHandles;

fig=MakeNewWindow('Time Series',[600 400],[handles.settingsDir '\icons\deltares.gif']);

c=load([handles.settingsDir '\icons\icons_muppet.mat']);

figure(fig);

tbh = uitoolbar;

h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom In');
set(h,'ClickedCallback',{@ddb_zoomInOutPan,1,'dummy',[],[],[]});
set(h,'Tag','UIToggleToolZoomIn');
set(h,'cdata',c.ico.zoomin16);

h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom Out');
set(h,'ClickedCallback',{@ddb_zoomInOutPan,2,'dummy',[],[],[]});
set(h,'Tag','UIToggleToolZoomOut');
set(h,'cdata',c.ico.zoomout16);

% h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Pan');
% set(h,'ClickedCallback',{@ddb_zoomInOutPan,3,'dummy',[],[],[]}');
% set(h,'Tag','UIToggleToolPan');
% set(h,'cdata',cpan.icons.pan);

handles.screenParameters.xMaxRange=[0 1000000];
handles.screenParameters.yMaxRange=[-1000 1000];
guidata(gcf,handles);

plot(times,prediction);
xtck=datestr(get(gca,'Xtick'),24);
%xtck=datestr(get(gca,'Xtick'));
set(gca,'XTickLabel',xtck);
grid on;
xlabel('Date');
ylabel('Water Level (m)');
title(name);

