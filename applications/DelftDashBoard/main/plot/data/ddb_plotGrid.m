function ddb_plotGrid(x,y,id,tag,opt)

handles=getHandles;

switch lower(opt)

    case{'plot'}

        h=findall(gca,'Tag',tag,'UserData',id);
        delete(h);

        grd=plot(x,y,'k');
        set(grd,'Color',[0 0 0]);
        set(grd,'HitTest','off');
        set(grd,'Tag',tag,'UserData',id);
        if strcmp(get(findobj((get(handles.GUIHandles.Menu.View.Model,'Children')),'Label','Grid'),'Checked'),'off')
            set(grd,'Visible','off');
        end

        grd=plot(x',y','k');
        set(grd,'Color',[0 0 0]);
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
            set(h,'Color',[0 0 0]);
        end

    case{'deactivate'}
        h=findall(gca,'Tag',tag,'UserData',id);
        if ~isempty(h)
            set(h,'Color',[0.7 0.7 0.7]);
        end
end
