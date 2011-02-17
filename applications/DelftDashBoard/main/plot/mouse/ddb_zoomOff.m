function ddb_zoomOff

handles=getHandles;

pan off;

set(handles.GUIHandles.toolBar.pan,'State','off');
set(handles.GUIHandles.toolBar.zoomIn,'State','off');
set(handles.GUIHandles.toolBar.zoomOut,'State','off');
% zoom off;
% plotedit off;
% 
% pan off;
% 
% ddb_setWindowButtonUpDownFcn;
% ddb_setWindowButtonMotionFcn;
