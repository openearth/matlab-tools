function handles=ddb_initializeFigure(handles)

handles.GUIHandles.MainWindow=MakeNewWindow('Delft Dashboard',[1030 680],[handles.SettingsDir '\icons\deltares.gif']);
h=handles.GUIHandles.MainWindow;
set(h,'Tag','MainWindow','Visible','off');

handles.GUIHandles.TextXCoordinate = uicontrol(gcf,'Style','text','String',['X : ' num2str(0)],'Position',[300 650 100 20],'HorizontalAlignment','left');
handles.GUIHandles.TextYCoordinate = uicontrol(gcf,'Style','text','String',['Y : ' num2str(0)],'Position',[380 650 100 20],'HorizontalAlignment','left');
handles.GUIHandles.TextCoordinateSystem = uicontrol(gcf,'Style','text','String','WGS 84 - Geographic','Position',[100 650 200 20],'HorizontalAlignment','left');

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
tabpanel(gcf,'tabpanel','create',[10 10 sz(3)-20 sz(4)-40],strings,callbacks,width);

handles.ScreenParameters.ActiveTab='Toolbox';
handles.activeToolbox.Name='ModelMaker';
handles.activeToolbox.Nr=1;
set(handles.GUIHandles.Menu.Toolbox.ModelMaker,'Checked','on');
set(handles.GUIHandles.Menu.Model.Delft3DFLOW,'Checked','on');

str=['WGS 84 / UTM zone ' num2str(handles.ScreenParameters.UTMZone{1}) 'N'];
set(handles.GUIHandles.Menu.CoordinateSystem.UTM,'Label',str);

set(handles.GUIHandles.MainWindow,'Visible','off');
