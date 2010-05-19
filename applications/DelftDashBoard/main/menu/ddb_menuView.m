function ddb_menuView(hObject, eventdata, handles)

handles=getHandles;

tg=get(hObject,'Tag');

switch tg,
    case{'menuViewLandBoundaries'}
        menuViewLandBoundaries_Callback(hObject,eventdata,handles);
%     case{'menuViewGrid'}
%         menuViewGrid_Callback(hObject,eventdata,handles);
%     case{'menuViewModelBathymetry'}
%         menuViewModelBathymetry_Callback(hObject,eventdata,handles);
    case{'menuViewBackgroundBathymetry'}
        menuViewBackgroundBathymetry_Callback(hObject,eventdata,handles);
%     case{'menuViewObservationPoints'}
%         menuViewObservationPoints_Callback(hObject,eventdata,handles);
%     case{'menuViewOpenBoundaries'}
%         menuViewOpenBoundaries_Callback(hObject,eventdata,handles);
%     case{'menuViewThinDams'}
%         menuViewThinDams_Callback(hObject,eventdata,handles);
%     case{'menuViewDryPoints'}
%         menuViewDryPoints_Callback(hObject,eventdata,handles);
%     case{'menuViewCrossSections'}
%         menuViewCrossSections_Callback(hObject,eventdata,handles);
    case{'menuViewCities'}
        menuViewCities_Callback(hObject,eventdata,handles);
    case{'menuViewSettings'}
        menuViewSettings_Callback(hObject,eventdata,handles);
end    

%%
function menuViewLandBoundaries_Callback(hObject, eventdata, handles)

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

% %%
% function menuViewGrid_Callback(hObject, eventdata, handles)
% 
% checked=get(hObject,'Checked');
% 
% if strcmp(checked,'on')
%     set(hObject,'Checked','off');
%     h=findall(gcf,'Tag','FlowGrid');
%     if ~isempty(h)
%         set(h,'Visible','off');
%     end        
% else
%     set(hObject,'Checked','on');
%     h=findall(gcf,'Tag','FlowGrid');
%     if ~isempty(h)
%         set(h,'Visible','on');
%     end        
% end    
% 
% %%
% function menuViewModelBathymetry_Callback(hObject, eventdata, handles)
% 
% checked=get(hObject,'Checked');
% 
% if strcmp(checked,'on')
%     set(hObject,'Checked','off');
%     h=findall(gcf,'Tag','FlowBathymetry');
%     if ~isempty(h)
%         set(h,'Visible','off');
%     end
% else
%     set(hObject,'Checked','on');
%     h=findall(gcf,'Tag','FlowBathymetry');
%     if ~isempty(h)
%         set(h,'Visible','on');
%     end
% %     if strcmp(get(handles.GUIHandles.Menu.View.BackgroundBathymetry,'Checked'),'on')
% %         set(handles.GUIHandles.Menu.View.BackgroundBathymetry,'Checked','off');
% %         h=findall(gcf,'Tag','BackgroundBathymetry');
% %         if length(h)>0
% %             set(h,'Visible','off');
% %         end
% %     end
% end
% 
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
%     if strcmp(get(handles.GUIHandles.ddb_menuViewModelBathymetry,'Checked'),'on')
%         set(handles.GUIHandles.ddb_menuViewModelBathymetry,'Checked','off');
%         h=findall(gcf,'Tag','FlowBathymetry');
%         if length(h)>0
%             set(h,'Visible','off');
%         end
%     end
end

% %%
% function menuViewOpenBoundaries_Callback(hObject, eventdata, handles)
% 
% checked=get(hObject,'Checked');
% 
% if strcmp(checked,'on')
%     set(hObject,'Checked','off');
%     h=findall(gcf,'Tag','OpenBoundary');
%     if ~isempty(h)
%         set(h,'Visible','off');
%     end        
%     h=findall(gcf,'Tag','OpenBoundaryText');
%     if ~isempty(h)
%         set(h,'Visible','off');
%     end        
% else
%     set(hObject,'Checked','on');
%     h=findall(gcf,'Tag','OpenBoundary');
%     if ~isempty(h)
%         set(h,'Visible','on');
%     end        
%     h=findall(gcf,'Tag','OpenBoundaryText');
%     if ~isempty(h)
%         set(h,'Visible','on');
%     end        
% end    
% 
% %%
% function menuViewObservationPoints_Callback(hObject, eventdata, handles)
% 
% checked=get(hObject,'Checked');
% 
% if strcmp(checked,'on')
%     set(hObject,'Checked','off');
%     h=findall(gcf,'Tag','ObservationPoint');
%     if ~isempty(h)
%         set(h,'Visible','off');
%     end        
%     h=findall(gcf,'Tag','ObservationPointText');
%     if ~isempty(h)
%         set(h,'Visible','off');
%     end        
% else
%     set(hObject,'Checked','on');
%     h=findall(gcf,'Tag','ObservationPoint');
%     if ~isempty(h)
%         set(h,'Visible','on');
%     end        
%     h=findall(gcf,'Tag','ObservationPointText');
%     if ~isempty(h)
%         set(h,'Visible','on');
%     end        
% end    
% 
% %%
% function menuViewThinDams_Callback(hObject, eventdata, handles)
% 
% checked=get(hObject,'Checked');
% 
% if strcmp(checked,'on')
%     set(hObject,'Checked','off');
%     h=findall(gcf,'Tag','ThinDam');
%     if ~isempty(h)
%         set(h,'Visible','off');
%     end        
% else
%     set(hObject,'Checked','on');
%     h=findall(gcf,'Tag','ThinDam');
%     if ~isempty(h)
%         set(h,'Visible','on');
%     end        
% end    
% 
% %%
% function menuViewDryPoints_Callback(hObject, eventdata, handles)
% 
% checked=get(hObject,'Checked');
% 
% if strcmp(checked,'on')
%     set(hObject,'Checked','off');
%     h=findall(gcf,'Tag','DryPoint');
%     if ~isempty(h)
%         set(h,'Visible','off');
%     end        
% else
%     set(hObject,'Checked','on');
%     h=findall(gcf,'Tag','DryPoint');
%     if ~isempty(h)
%         set(h,'Visible','on');
%     end        
% end    
% 
% %%
% function menuViewCrossSections_Callback(hObject, eventdata, handles)
% 
% checked=get(hObject,'Checked');
% 
% if strcmp(checked,'on')
%     set(hObject,'Checked','off');
%     h=findall(gcf,'Tag','CrossSection');
%     if ~isempty(h)
%         set(h,'Visible','off');
%     end        
%     h=findall(gcf,'Tag','CrossSectionText');
%     if ~isempty(h)
%         set(h,'Visible','off');
%     end        
% else
%     set(hObject,'Checked','on');
%     h=findall(gcf,'Tag','CrossSection');
%     if ~isempty(h)
%         set(h,'Visible','on');
%     end        
%     h=findall(gcf,'Tag','CrossSectionText');
%     if ~isempty(h)
%         set(h,'Visible','on');
%     end        
% end    
% 
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

