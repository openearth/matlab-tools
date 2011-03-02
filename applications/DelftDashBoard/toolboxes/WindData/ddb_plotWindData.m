function ddb_plotWindData(option,varargin)

switch lower(option)
    case{'delete'}
        h=findobj(gca,'Tag','WindDataStations');
        delete(h);
        h=findobj(gca,'Tag','ActiveWindDataStation');
        delete(h);
    case{'activate'}
        h=findobj(gca,'Tag','WindDataStations');
        if ~isempty(h)
            set(h,'Visible','on');
            set(h,'HandleVisibility','on');
        end
        h=findobj(gca,'Tag','ActiveWindDataStation');
        if ~isempty(h)
            set(h,'Visible','off');
            set(h,'HandleVisibility','on');
        end
    case{'deactivate'}
        h=findobj(gca,'Tag','WindDataStations');
        if ~isempty(h)
            set(h,'Visible','off');
            set(h,'HandleVisibility','off');
        end
        h=findobj(gca,'Tag','ActiveWindDataStation');
        if ~isempty(h)
            set(h,'Visible','off');
            set(h,'HandleVisibility','off');
        end
end



