function DelftDashBoard

% Compile with: mcc -m -B sgl DelftDashBoard.m

handles.DelftDashBoardVersion='1.0';
handles.WorkingDirectory=pwd;

if isdeployed
    inipath=[fileparts(which('DelftDashBoard.m')) filesep];
    inipath=inipath(1:end-39);
else
    inipath=[fileparts(which('DelftDashBoard.m')) filesep];
end

% check existence of ini file DelftDashBoard.ini
if exist([inipath filesep 'DelftDashBoard.ini'],'file')
    handles.IniFile=[inipath filesep 'DelftDashBoard.ini'];
else
    GiveWarning('text','DelftDashBoard.ini not found !');
    return;
end

disp('Finding directories ...');
handles=ddb_getDirectories(handles);

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
