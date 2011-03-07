function ddb_plotTideDatabase(option,varargin)

switch lower(option)
    case{'delete'}
        h=findobj(gca,'Tag','TideStations');
        delete(h);
        h=findobj(gca,'Tag','ActiveTideStation');
        delete(h);
    case{'activate'}
        h=findobj(gca,'Tag','TideStations');
        if ~isempty(h)
            set(h,'Visible','on');
            set(h,'HandleVisibility','on');
        end
        h=findobj(gca,'Tag','ActiveTideStation');
        if ~isempty(h)
            set(h,'Visible','on');
            set(h,'HandleVisibility','on');
        end
    case{'deactivate'}
        h=findobj(gca,'Tag','TideStations');
        if ~isempty(h)
            set(h,'Visible','off');
            set(h,'HandleVisibility','off');
        end
        h=findobj(gca,'Tag','ActiveTideStation');
        if ~isempty(h)
            set(h,'Visible','off');
            set(h,'HandleVisibility','off');
        end
end
