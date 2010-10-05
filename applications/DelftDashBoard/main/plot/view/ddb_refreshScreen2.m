function ddb_refreshScreen2

handles=getHandles;

h=findobj(gcf,'Tag','UIControl');
if ~isempty(h)
    delete(h);
end

ddb_setWindowButtonUpDownFcn;
ddb_setWindowButtonMotionFcn;
set(gcf, 'KeyPressFcn',[]);
set(gcf, 'Pointer', 'arrow');
ddb_zoomOff;

for j=1:length(handles.Model)
    f=handles.Model(j).PlotFcn;
    feval(f,handles,'deactivate');
end

for j=1:length(handles.Toolbox)
    f=handles.Toolbox(j).PlotFcn;
    feval(f,handles,'deactivate');
end
