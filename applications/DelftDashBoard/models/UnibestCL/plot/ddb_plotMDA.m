function ddb_plotMDA(handles,opt,id)

handles=getHandles;
tag = 'mda';
imd=strmatch('UnibestCL',{handles.Model(:).name},'exact');

switch lower(opt)
    case{'plot'}
        h=findall(gca,'Tag',tag,'UserData',id);
        delete(h);
        
        grd = plot(handles.Model(imd).Input.MDAdata.X, handles.Model(imd).Input.MDAdata.Y,'r');
        set(grd,'Color',[1 0 0],'marker','.','linewidth',1);
        
        set(grd,'HitTest','off');
        set(grd,'Tag',tag,'UserData',id);
        if strcmp(get(findobj((get(handles.GUIHandles.Menu.View.Model,'Children')),'Label','Grid'),'Checked'),'off')
            set(grd,'Visible','off');
        end

    case{'delete'}
        h=findall(gca,'Tag',tag,'UserData',id);
        delete(h);
        
    case{'activate'}
        h=findall(gca,'Tag',tag,'UserData',id);
        if ~isempty(h)
            set(h,'Color',[1 0 0]);
        end
        
    case{'deactivate'}
        h=findall(gca,'Tag',tag,'UserData',id);
        if ~isempty(h)
            set(h,'Color',[1 0.7 0.7]);
        end
end
