function handles=ddb_coordConvertTideDatabase(handles)

ii=strmatch('TideDatabase',{handles.Toolbox(:).name},'exact');

h=findall(gcf,'Tag','TideStations');
if ~isempty(h)
    x=handles.Toolbox(ii).tideStations.x;
    y=handles.Toolbox(ii).tideStations.y;
    cs.name=handles.Toolbox(ii).tideStations.coordinateSystem;
    cs.Type=handles.Toolbox(ii).tideStations.coordinateSystemType;
    [x,y]=ddb_coordConvert(x,y,cs,handles.screenParameters.coordinateSystem);
    handles.Toolbox(ii).tideStations.xy=[x y];
    z=zeros(size(x))+500;
    set(h,'XData',x,'YData',y,'ZData',z);
end

h=findall(gca,'Tag','ActiveTideStation');
if ~isempty(h)
    n=handles.Toolbox(ii).activeTideStation;
    x=handles.Toolbox(ii).tideStations.x(n);
    y=handles.Toolbox(ii).tideStations.y(n);
    cs.name=handles.Toolbox(ii).tideStations.coordinateSystem;
    cs.Type=handles.Toolbox(ii).tideStations.coordinateSystemType;
    [x,y]=ddb_coordConvert(x,y,cs,handles.screenParameters.coordinateSystem);
    z=zeros(size(x))+500;
    set(h,'XData',x,'YData',y,'ZData',z);
end
