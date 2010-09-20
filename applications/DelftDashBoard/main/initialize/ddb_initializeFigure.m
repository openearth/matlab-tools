function handles=ddb_initializeFigure(handles)

%handles.GUIHandles.MainWindow=MakeNewWindow('Delft Dashboard',[1030 680],[handles.SettingsDir '\icons\deltares.gif']);
handles.GUIHandles.MainWindow=MakeNewWindow('Delft Dashboard',[1100 700],[handles.SettingsDir '\icons\deltares.gif']);
h=handles.GUIHandles.MainWindow;

% fullscreen = get(0,'ScreenSize');
% set(h,'Position',[0 0 fullscreen(3) fullscreen(4)]);

% maximize(h);
% pause(2.0);

set(h,'Tag','MainWindow','Visible','off');

handles.backgroundColor=get(h,'Color');

handles.GUIHandles.TextXCoordinate = uicontrol(gcf,'Style','text','String',['X : ' num2str(0)],'Position',[300 655 100 15],'BackgroundColor',handles.backgroundColor,'HorizontalAlignment','left');
handles.GUIHandles.TextYCoordinate = uicontrol(gcf,'Style','text','String',['Y : ' num2str(0)],'Position',[380 655 100 15],'BackgroundColor',handles.backgroundColor,'HorizontalAlignment','left');
handles.GUIHandles.TextCoordinateSystem = uicontrol(gcf,'Style','text','String','WGS 84 - Geographic','Position',[100 655 200 15],'BackgroundColor',handles.backgroundColor,'HorizontalAlignment','left');

figure(h);

fh = get(h,'JavaFrame'); % Get Java Frame 
fh.setFigureIcon(javax.swing.ImageIcon([handles.SettingsDir '\icons\deltares.gif']));

set(h,'toolbar','figure');
set(h,'Tag','MainWindow');

handles=ddb_makeMenu(handles);
handles=ddb_makeToolBar(handles);

% Make Dummy Tab Panel
sz=get(h,'Position');
strings={'Toolbox','Description'};
callbacks={[],[]};
width=[60 60];
tabpanel(gcf,'tabpanel','create','position',[10 10 sz(3)-20 sz(4)-40],'strings',strings,'callbacks',callbacks,'width',width);

handles.ScreenParameters.ActiveTab='Toolbox';
handles.activeToolbox.Name='ModelMaker';
handles.activeToolbox.Nr=1;
set(handles.GUIHandles.Menu.Toolbox.ModelMaker,'Checked','on');
set(handles.GUIHandles.Menu.Model.Delft3DFLOW,'Checked','on');

str=['WGS 84 / UTM zone ' num2str(handles.ScreenParameters.UTMZone{1}) 'N'];
set(handles.GUIHandles.Menu.CoordinateSystem.UTM,'Label',str);

set(handles.GUIHandles.MainWindow,'Visible','off');
