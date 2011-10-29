function ddb_plotCycloneTrack

handles=getHandles;
h=findobj(gcf,'Tag','cycloneTrack');
if ~isempty(h)
    delete(h);
end
for i=1:handles.Toolbox(tb).Input.nrTrackPoints
    txt{i}=datestr(handles.Toolbox(tb).Input.trackT(i),'dd-mmm-yyyy HH:MM');
end
UIPolyline(gca,'plot','Tag','cycloneTrack','Marker','o','Callback',@ddb_changeCycloneTrack,'DoubleClickCallback',@ddb_selectCyclonePoint, ...
    'closed',0,'x',handles.Toolbox(tb).Input.trackX,'y',handles.Toolbox(tb).Input.trackY,'text',txt);
