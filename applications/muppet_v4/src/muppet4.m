function muppet4(varargin)

handles.muppetversion='4.0';

warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

% Initialize
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
