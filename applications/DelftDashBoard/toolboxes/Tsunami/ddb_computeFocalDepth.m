function handles=ddb_computeFocalDepth(handles)

degrad=pi/180;
nseg   = max(handles.Toolbox(tb).Input.NrSegments,1);
for i=1:nseg
    handles.Toolbox(tb).Input.FocalDepth(i) = 0.5*handles.Toolbox(tb).Input.FaultWidth*sin(handles.Toolbox(tb).Input.Dip(i)*degrad) + handles.Toolbox(tb).Input.DepthFromTop;
end
