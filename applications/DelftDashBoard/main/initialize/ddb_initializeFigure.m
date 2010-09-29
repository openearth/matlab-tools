function ddb_initializeFigure

handles=getHandles;

handles.GUIHandles.MainWindow=MakeNewWindow('Delft Dashboard',[1100 700],[handles.SettingsDir '\icons\deltares.gif']);
h=handles.GUIHandles.MainWindow;

% fullscreen = get(0,'ScreenSize');
% set(h,'Position',[0 0 fullscreen(3) fullscreen(4)]);

% maximize(h);
% pause(2.0);

set(h,'Tag','MainWindow','Visible','off');

set(h,'Renderer','opengl');

handles.backgroundColor=get(h,'Color');

figure(h);

fh = get(h,'JavaFrame'); % Get Java Frame 
fh.setFigureIcon(javax.swing.ImageIcon([handles.SettingsDir '\icons\deltares.gif']));

set(h,'toolbar','figure');
set(h,'Tag','MainWindow');

handles=ddb_makeMenu(handles);
handles=ddb_makeToolBar(handles);

set(handles.GUIHandles.Menu.Toolbox.ModelMaker,'Checked','on');
set(handles.GUIHandles.Menu.Model.Delft3DFLOW,'Checked','on');

str=['WGS 84 / UTM zone ' num2str(handles.ScreenParameters.UTMZone{1}) 'N'];
set(handles.GUIHandles.Menu.CoordinateSystem.UTM,'Label',str);

set(handles.GUIHandles.MainWindow,'Visible','off');

setHandles(handles);
