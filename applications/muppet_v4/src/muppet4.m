function muppet4(varargin)

handles.muppetversion='4.00';

warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

% Initialize
handles.currentpath=pwd;
handles=muppet_getDirectories(handles);

if isempty(varargin)
    % Splash screen
    handles.splashscreen = SplashScreen( 'Splashscreen',[handles.settingsdir 'icons' filesep 'muppets.jpg']);
    handles.splashscreen.addText( 10, 30, 'Muppet', 'FontSize', 30, 'Color', [0 0 0.6] ); 
    handles.splashscreen.addText( 10, 50, ['v ' handles.muppetversion], 'FontSize', 20, 'Color',[1 1 1]);
end

handles=muppet_initialize(handles);

setHandles(handles);

if ~isempty(varargin)
    mupfile=varargin{1};
    curdir=pwd;
    pth=fileparts(mupfile);
    cd(pth);
    [handles,ok]=muppet_newSession(handles,mupfile);
    muppet_exportFigure(handles,1,'export');
    cd(curdir);
else
   muppet_initializegui;
   muppet_gui;
end
