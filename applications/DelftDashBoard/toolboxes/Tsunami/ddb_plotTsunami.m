function ddb_plotTsunami(handles,opt)

switch lower(opt)
    case{'delete'}
        h=findall(gca,'Tag','Plates');
        if ~isempty(h)
            delete(h);
        end
        h=findall(gca,'Tag','TsunamiSegments');
        if ~isempty(h)
            delete(h);
        end
        h=findall(gca,'Tag','FaultArea');
        if ~isempty(h)
            delete(h);
        end
        h=findall(gca,'Tag','Epicentre');
        if ~isempty(h)
            delete(h);
        end
    case{'activate'}
         h=findobj(gca,'Tag','Plates');
        if ~isempty(h)
            set(h,'Visible','on');
        end
        h=findobj(gca,'Tag','TsunamiSegments');
        if ~isempty(h)
            set(h,'Visible','on');
        end
        h=findobj(gca,'Tag','FaultArea');
        if ~isempty(h)
            set(h,'Visible','on');
        end
        h=findobj(gca,'Tag','Epicentre');
        if ~isempty(h)
            set(h,'Visible','on');
        end
   case{'deactivate'}
        h=findobj(gca,'Tag','Plates');
        if ~isempty(h)
            set(h,'Visible','off');
        end
        h=findobj(gca,'Tag','TsunamiSegments');
        if ~isempty(h)
            set(h,'Visible','off');
        end
        h=findobj(gca,'Tag','FaultArea');
        if ~isempty(h)
            set(h,'Visible','off');
        end
        h=findobj(gca,'Tag','Epicentre');
        if ~isempty(h)
            set(h,'Visible','off');
        end
end

