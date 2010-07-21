function handles=ddb_makeToolBar(handles)

delete(findall(gcf,'Type','uitoolbar'));

tbh = uitoolbar;

c=load([handles.SettingsDir '\icons\icons_muppet.mat']);

c2=load([handles.SettingsDir '\icons\icons6.mat']);
cpan=load([handles.SettingsDir '\icons\icons.mat']);

h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom In');
set(h,'ClickedCallback',{@ddb_zoomInOutPan,1,@ddb_updateDataInScreen,[],@ddb_updateDataInScreen,[]});
set(h,'Tag','UIToggleToolZoomIn');
set(h,'cdata',c.ico.zoomin16);
handles.GUIHandles.ToolBar.ZoomIn=h;
%set(h,'cdata',c2.ico.zoom_in_32x32);

h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom Out');
set(h,'ClickedCallback',{@ddb_zoomInOutPan,2,@ddb_updateDataInScreen,[],@ddb_updateDataInScreen,[]});
set(h,'Tag','UIToggleToolZoomOut');
set(h,'cdata',c.ico.zoomout16);
handles.GUIHandles.ToolBar.ZoomOut=h;

h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Pan');
set(h,'ClickedCallback',{@ddb_zoomInOutPan,3,@ddb_updateDataInScreen,[],@ddb_updateDataInScreen,[]}');
set(h,'Tag','UIToggleToolPan');
set(h,'cdata',cpan.icons.pan);
handles.GUIHandles.ToolBar.Pan=h;

h = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom Reset');
set(h,'ClickedCallback',{@ddb_zoomInOutPan,4,@ddb_updateDataInScreen,[],@ddb_updateDataInScreen,[]});
set(h,'Tag','UIZoomReset');
set(h,'cdata',cpan.icons.zoomreset);
handles.GUIHandles.ToolBar.ZoomReset=h;

h = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Refresh Bathymetry');
set(h,'ClickedCallback',{@ddb_zoomInOutPan,5,@ddb_updateDataInScreen,[],@ddb_updateDataInScreen,[]});
set(h,'Tag','UIRefreshBathymetry');
set(h,'cdata',cpan.icons.refresh);
handles.GUIHandles.ToolBar.RefreshBathymetry=h;

h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Automatically Refresh Bathymetry');
set(h,'ClickedCallback','');
set(h,'Tag','UIAutomaticallyRefreshBathymetry');
set(h,'cdata',cpan.icons.refreshauto);
set(h,'State','on');
handles.GUIHandles.ToolBar.AutoRefreshBathymetry=h;

% h = uitoggletool(tbh,'Separator','on','HandleVisibility','on','ToolTipString','Set Anchor');
% set(h,'ClickedCallback','');
% set(h,'Tag','UISetAnchor');
% set(h,'cdata',cpan.icons.refreshauto);
% set(h,'State','on');



h = uipushtool(tbh,'Separator','on','HandleVisibility','on','ToolTipString','Quickplot');
%set(h,'ClickedCallback','C:\Delft3D\w32\quickplot\bin\win32\d3d_qp.exe openfile "%1"');
d3dpath=[getenv('D3D_HOME')];
str=['system(''' d3dpath '\w32\quickplot\bin\win32\d3d_qp.exe'');'];
set(h,'ClickedCallback',str);
set(h,'Tag','UIStartQuickplot');
%set(h,'cdata',cpan.icons.refresh);
set(h,'cdata',c.ico.graph_bar16);
handles.GUIHandles.ToolBar.QuickPlot=h;
