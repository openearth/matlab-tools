function handles=ddb_coordConvertMAD(handles)

ii=strmatch('MAD',{handles.Toolbox(:).Name},'exact');

h=findall(gcf,'Tag','MADModels');
if ~isempty(h)
    for i=1:length(handles.Toolbox(ii).Models)
        x(i,1)=handles.Toolbox(ii).Models(i).Longitude;
        y(i,1)=handles.Toolbox(ii).Models(i).Latitude;
    end
    cs.Name='WGS 84';
    cs.Type='Geographic';
    [x,y]=ddb_coordConvert(x,y,cs,handles.ScreenParameters.CoordinateSystem);
    z=zeros(size(x))+500;
    handles.Toolbox(ii).xy=[x y];
    set(h,'XData',x,'YData',y,'ZData',z);
end

h=findall(gca,'Tag','ActiveMADModel');
if ~isempty(h)
    n=handles.Toolbox(ii).ActiveMADModel;
    x=handles.Toolbox(ii).Models(n).Longitude;
    y=handles.Toolbox(ii).Models(n).Latitude;
    cs.Name='WGS 84';
    cs.Type='Geographic';
    [x,y]=ddb_coordConvert(x,y,cs,handles.ScreenParameters.CoordinateSystem);
    set(h,'XData',x,'YData',y);
end
