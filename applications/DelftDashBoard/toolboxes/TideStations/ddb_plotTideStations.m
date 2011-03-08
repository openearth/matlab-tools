function ddb_plotTideStations(option,varargin)

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
        end
        h=findobj(gca,'Tag','ActiveTideStation');
        if ~isempty(h)
            set(h,'Visible','on');
        end
    case{'deactivate'}
        h=findobj(gca,'Tag','TideStations');
        if ~isempty(h)
            set(h,'Visible','off');
        end
        h=findobj(gca,'Tag','ActiveTideStation');
        if ~isempty(h)
            set(h,'Visible','off');
        end
end
