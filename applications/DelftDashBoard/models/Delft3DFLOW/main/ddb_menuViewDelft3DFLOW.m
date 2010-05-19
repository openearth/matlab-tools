function ddb_menuViewDelft3DFLOW(hObject, eventdata, handles)

handles=getHandles;

tg=get(hObject,'Tag');

switch tg,
    case{'menuViewModelGrid'}
        menuViewGrid_Callback(hObject,eventdata,handles);
    case{'menuViewModelModelBathymetry'}
        menuViewModelBathymetry_Callback(hObject,eventdata,handles);
    case{'menuViewModelObservationPoints'}
        menuViewObservationPoints_Callback(hObject,eventdata,handles);
    case{'menuViewModelOpenBoundaries'}
        menuViewOpenBoundaries_Callback(hObject,eventdata,handles);
    case{'menuViewModelThinDams'}
        menuViewThinDams_Callback(hObject,eventdata,handles);
    case{'menuViewModelDryPoints'}
        menuViewDryPoints_Callback(hObject,eventdata,handles);
    case{'menuViewModelCrossSections'}
        menuViewCrossSections_Callback(hObject,eventdata,handles);
end    

%%
function menuViewGrid_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    h=findall(gcf,'Tag','FlowGrid');
    if ~isempty(h)
        set(h,'Visible','off');
    end        
else
    set(hObject,'Checked','on');
    h=findall(gcf,'Tag','FlowGrid');
    if ~isempty(h)
        set(h,'Visible','on');
    end        
end    

%%
function menuViewModelBathymetry_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    h=findall(gcf,'Tag','FlowBathymetry');
    if ~isempty(h)
        set(h,'Visible','off');
    end
else
    set(hObject,'Checked','on');
    h=findall(gcf,'Tag','FlowBathymetry');
    if ~isempty(h)
        set(h,'Visible','on');
    end
%     if strcmp(get(handles.GUIHandles.Menu.View.BackgroundBathymetry,'Checked'),'on')
%         set(handles.GUIHandles.Menu.View.BackgroundBathymetry,'Checked','off');
%         h=findall(gcf,'Tag','BackgroundBathymetry');
%         if length(h)>0
%             set(h,'Visible','off');
%         end
%     end
end

%%
function menuViewOpenBoundaries_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    h=findall(gcf,'Tag','OpenBoundary');
    if ~isempty(h)
        set(h,'Visible','off');
    end        
    h=findall(gcf,'Tag','OpenBoundaryText');
    if ~isempty(h)
        set(h,'Visible','off');
    end        
else
    set(hObject,'Checked','on');
    h=findall(gcf,'Tag','OpenBoundary');
    if ~isempty(h)
        set(h,'Visible','on');
    end        
    h=findall(gcf,'Tag','OpenBoundaryText');
    if ~isempty(h)
        set(h,'Visible','on');
    end        
end    

%%
function menuViewObservationPoints_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    h=findall(gcf,'Tag','ObservationPoint');
    if ~isempty(h)
        set(h,'Visible','off');
    end        
    h=findall(gcf,'Tag','ObservationPointText');
    if ~isempty(h)
        set(h,'Visible','off');
    end        
else
    set(hObject,'Checked','on');
    h=findall(gcf,'Tag','ObservationPoint');
    if ~isempty(h)
        set(h,'Visible','on');
    end        
    h=findall(gcf,'Tag','ObservationPointText');
    if ~isempty(h)
        set(h,'Visible','on');
    end        
end    

%%
function menuViewThinDams_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    h=findall(gcf,'Tag','ThinDam');
    if ~isempty(h)
        set(h,'Visible','off');
    end        
else
    set(hObject,'Checked','on');
    h=findall(gcf,'Tag','ThinDam');
    if ~isempty(h)
        set(h,'Visible','on');
    end        
end    

%%
function menuViewDryPoints_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    h=findall(gcf,'Tag','DryPoint');
    if ~isempty(h)
        set(h,'Visible','off');
    end        
else
    set(hObject,'Checked','on');
    h=findall(gcf,'Tag','DryPoint');
    if ~isempty(h)
        set(h,'Visible','on');
    end        
end    

%%
function menuViewCrossSections_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    h=findall(gcf,'Tag','CrossSection');
    if ~isempty(h)
        set(h,'Visible','off');
    end        
    h=findall(gcf,'Tag','CrossSectionText');
    if ~isempty(h)
        set(h,'Visible','off');
    end        
else
    set(hObject,'Checked','on');
    h=findall(gcf,'Tag','CrossSection');
    if ~isempty(h)
        set(h,'Visible','on');
    end        
    h=findall(gcf,'Tag','CrossSectionText');
    if ~isempty(h)
        set(h,'Visible','on');
    end        
end    

%%
