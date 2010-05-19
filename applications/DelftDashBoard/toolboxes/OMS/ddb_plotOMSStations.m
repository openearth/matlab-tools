function ddb_plotOMSStations(handles)

h=findall(gca,'Tag','OMSStations');
delete(h);
h=findall(gca,'Tag','ActiveOMSStation');
delete(h);

if handles.Toolbox(tb).NrStations>0

    for i=1:handles.Toolbox(tb).NrStations
        x(i)=handles.Toolbox(tb).Stations(i).x;
        y(i)=handles.Toolbox(tb).Stations(i).y;
    end

    z=zeros(size(x))+500;
    plt=plot3(x,y,z,'o');hold on;
    set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','y');
    set(plt,'Tag','OMSStations');
    set(plt,'ButtonDownFcn',{@SelectOMSStation});

    n=handles.Toolbox(tb).ActiveStation;
    plt=plot3(x(n),y(n),1000,'o');
    set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','r','Tag','ActiveOMSStation');
%     set(handles.GUIHandles.ListOMSStations,'Value',n);

end

%%
function SelectOMSStation(imagefig, varargins)

h=gco;
if strcmp(get(h,'Tag'),'OMSStations')  
    handles=getHandles;
    pos = get(gca, 'CurrentPoint');
    posx=pos(1,1);
    posy=pos(1,2);

    for i=1:handles.Toolbox(tb).NrStations
        x(i)=handles.Toolbox(tb).Stations(i).x;
        y(i)=handles.Toolbox(tb).Stations(i).y;
    end
    
    dxsq=(x-posx).^2;
    dysq=(y-posy).^2;
    dist=(dxsq+dysq).^0.5;
    [dummy,n]=min(dist);
    h0=findobj(gca,'Tag','ActiveOMSStation');
    delete(h0);

    plt=plot3(x(n),y(n),1000,'o');
    set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','r','Tag','ActiveOMSStation');
%     set(handles.GUIHandles.ListOMSStations,'Value',n);
    handles.Toolbox(tb).ActiveStation=n;
    
    if strcmpi(handles.ScreenParameters.ActiveSecondTab,'stations')
        ddb_refreshOMSStations(handles);
    end
    
    setHandles(handles);
end

