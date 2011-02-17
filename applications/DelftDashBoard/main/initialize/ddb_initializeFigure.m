function ddb_initializeFigure

handles=getHandles;

handles.GUIHandles.mainWindow=MakeNewWindow('Delft Dashboard',[1100 700],[handles.settingsDir '\icons\deltares.gif']);
h=handles.GUIHandles.mainWindow;

set(h,'Tag','MainWindow','Visible','off');

%maximizeWindow('Delft Dashboard');

set(h,'Renderer','opengl');

handles.backgroundColor=get(h,'Color');

figure(h);

fh = get(h,'JavaFrame'); % Get Java Frame 
fh.setFigureIcon(javax.swing.ImageIcon([handles.settingsDir '\icons\deltares.gif']));

set(h,'toolbar','figure');
set(h,'Tag','MainWindow');

handles=ddb_makeMenu(handles);
handles=ddb_makeToolBar(handles);

set(handles.GUIHandles.Menu.Toolbox.ModelMaker,'Checked','on');
set(handles.GUIHandles.Menu.Model.Delft3DFLOW,'Checked','on');

str=['WGS 84 / UTM zone ' num2str(handles.screenParameters.UTMZone{1}) 'N'];
set(handles.GUIHandles.Menu.CoordinateSystem.UTM,'Label',str);

set(handles.GUIHandles.mainWindow,'Visible','off');

setHandles(handles);
