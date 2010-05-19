function handles=ddb_coordConvertTideDatabase(handles)

ii=strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact');

h=findall(gcf,'Tag','TideStations');
if ~isempty(h)
    x=handles.Toolbox(ii).TideStations.x;
    y=handles.Toolbox(ii).TideStations.y;
    cs.Name=handles.Toolbox(ii).TideStations.CoordinateSystem;
    cs.Type=handles.Toolbox(ii).TideStations.CoordinateSystemType;
    [x,y]=ddb_coordConvert(x,y,cs,handles.ScreenParameters.CoordinateSystem);
    handles.Toolbox(ii).TideStations.xy=[x y];
    z=zeros(size(x))+500;
    set(h,'XData',x,'YData',y,'ZData',z);
end

h=findall(gca,'Tag','ActiveTideStation');
if ~isempty(h)
    n=handles.Toolbox(ii).ActiveTideStation;
    x=handles.Toolbox(ii).TideStations.x(n);
    y=handles.Toolbox(ii).TideStations.y(n);
    cs.Name=handles.Toolbox(ii).TideStations.CoordinateSystem;
    cs.Type=handles.Toolbox(ii).TideStations.CoordinateSystemType;
    [x,y]=ddb_coordConvert(x,y,cs,handles.ScreenParameters.CoordinateSystem);
    z=zeros(size(x))+500;
    set(h,'XData',x,'YData',y,'ZData',z);
end
