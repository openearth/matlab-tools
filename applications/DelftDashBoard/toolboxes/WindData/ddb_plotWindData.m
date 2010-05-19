function ddb_plotWindData(handles,opt)

switch lower(opt)
    case{'delete'}
        h=findall(gca,'Tag','WindDataStations');
        delete(h);
        h=findall(gca,'Tag','ActiveWindDataStation');
        delete(h);
    case{'activate'}
        h=findall(gca,'Tag','WindDataStations');
        if ~isempty(h)
            set(h,'Visible','on');
            set(h,'HandleVisibility','on');
        end
        h=findall(gca,'Tag','ActiveWindDataStation');
        if ~isempty(h)
            set(h,'Visible','off');
            set(h,'HandleVisibility','on');
        end
    case{'deactivate'}
        h=findall(gca,'Tag','WindDataStations');
        if ~isempty(h)
            set(h,'Visible','off');
            set(h,'HandleVisibility','off');
        end
        h=findall(gca,'Tag','ActiveWindDataStation');
        if ~isempty(h)
            set(h,'Visible','off');
            set(h,'HandleVisibility','off');
        end
end



