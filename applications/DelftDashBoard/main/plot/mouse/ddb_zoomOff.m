function ddb_zoomOff

handles=getHandles;

pan off;

set(handles.GUIHandles.ToolBar.Pan,'State','off');
set(handles.GUIHandles.ToolBar.ZoomIn,'State','off');
set(handles.GUIHandles.ToolBar.ZoomOut,'State','off');
% zoom off;
% plotedit off;
% 
% pan off;
% 
% ddb_setWindowButtonUpDownFcn;
% ddb_setWindowButtonMotionFcn;
