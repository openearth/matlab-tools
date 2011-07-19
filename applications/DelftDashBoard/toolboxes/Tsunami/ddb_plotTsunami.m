function ddb_plotTsunami(option,varargin)

switch lower(option)
    case{'delete'}
        h=findobj(gca,'Tag','Plates');
        if ~isempty(h)
            delete(h);
        end
        h=findobj(gca,'Tag','TsunamiSegments');
        if ~isempty(h)
            delete(h);
        end
        h=findobj(gca,'Tag','FaultArea');
        if ~isempty(h)
            delete(h);
        end
        h=findobj(gca,'Tag','tsunamiFault');
        if ~isempty(h)
            delete(h);
        end
        h=findobj(gca,'Tag','Epicentre');
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
        h=findobj(gca,'Tag','tsunamiFault');
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
        h=findobj(gca,'Tag','tsunamiFault');
        if ~isempty(h)
            set(h,'Visible','off');
        end
        h=findobj(gca,'Tag','Epicentre');
        if ~isempty(h)
            set(h,'Visible','off');
        end
end

