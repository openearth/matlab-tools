function ddb_menuView(hObject, eventdata, handles)

handles=getHandles;

tg=get(hObject,'Tag');

switch tg,
    case{'menuViewShorelines'}
        menuViewShorelines_Callback(hObject,eventdata,handles);
    case{'menuViewBackgroundBathymetry'}
        menuViewBackgroundBathymetry_Callback(hObject,eventdata,handles);
    case{'menuViewCities'}
        menuViewCities_Callback(hObject,eventdata,handles);
    case{'menuViewSettings'}
        menuViewSettings_Callback(hObject,eventdata,handles);
end    

%%
function menuViewShorelines_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    h=findall(gcf,'Tag','WorldCoastLine');
    if ~isempty(h)
        set(h,'Visible','off');
    end        
else
    set(hObject,'Checked','on');
    h=findall(gcf,'Tag','WorldCoastLine');
    if ~isempty(h)
        set(h,'Visible','on');
    end        
end    

%%
function menuViewBackgroundBathymetry_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    h=findall(gcf,'Tag','BackgroundBathymetry');
    if ~isempty(h)
        set(h,'Visible','off');
    end
else
    set(hObject,'Checked','on');
    h=findall(gcf,'Tag','BackgroundBathymetry');
    if ~isempty(h)
        set(h,'Visible','on');
    end
end

%%
function menuViewCities_Callback(hObject, eventdata, handles)
checked=get(hObject,'Checked');
if strcmp(checked,'on')
    set(hObject,'Checked','off');
    h=findobj(gca,'Tag','WorldCities');
    if ~isempty(h)
        delete(h);
    end        
else
    set(hObject,'Checked','on');
    h=findobj(gca,'Tag','WorldCities');
    for i=1:length(handles.GUIData.cities.Lon)
        xc(i)=handles.GUIData.cities.Lon(i);
        yc(i)=handles.GUIData.cities.Lat(i);
        tx=text(xc(i),yc(i),[' ' handles.GUIData.cities.Name{i}]);
        set(tx,'HorizontalAlignment','left','VerticalAlignment','bottom');
        set(tx,'FontSize',7,'Clipping','on');
        set(tx,'Tag','WorldCities');
    end
    zc=zeros(size(xc))+500;
    plt=plot3(xc,yc,zc,'o');
    set(plt,'MarkerSize',4,'MarkerEdgeColor','none','MarkerFaceColor','r');
    set(plt,'Tag','WorldCities');
end    

%%
function menuViewSettings_Callback(hObject, eventdata, handles)

ddb_editViewSettings;

