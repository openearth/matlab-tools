function DelftDashBoard

% Compile with ddcompile

handles.DelftDashBoardVersion='1.0';
handles.MatlabVersion=version;

disp(['Delft DashBoard v' handles.DelftDashBoardVersion]);
disp(['Matlab v' version]);

disp('Finding directories ...');
[handles,ok]=ddb_getDirectories(handles);
if ~ok
    return
end

warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

% Open Splash Screen
frame=splash([handles.SettingsDir 'icons' filesep 'DelftDashBoard.jpg'],30);

handles=ddb_initialize(handles,'startup');
setHandles(handles);

% Maximize Figure
maximize(handles.GUIHandles.MainWindow);

% set(gcf,'Renderer','Painters');

% Make Figure Visible
set(handles.GUIHandles.MainWindow,'Visible','on');

% Close Splash Screen
frame.hide;
