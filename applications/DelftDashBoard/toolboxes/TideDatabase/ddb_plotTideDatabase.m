function ddb_plotTideDatabase(handles,opt)

switch lower(opt)
    case{'delete'}
        h=findall(gca,'Tag','TideStations');
        delete(h);
        h=findall(gca,'Tag','ActiveTideStation');
        delete(h);
    case{'activate'}
        h=findall(gca,'Tag','TideStations');
        if ~isempty(h)
            set(h,'Visible','on');
            set(h,'HandleVisibility','on');
        end
        h=findall(gca,'Tag','ActiveTideStation');
        if ~isempty(h)
            set(h,'Visible','on');
            set(h,'HandleVisibility','on');
        end
    case{'deactivate'}
        h=findall(gca,'Tag','TideStations');
        if ~isempty(h)
            set(h,'Visible','off');
            set(h,'HandleVisibility','off');
        end
        h=findall(gca,'Tag','ActiveTideStation');
        if ~isempty(h)
            set(h,'Visible','off');
            set(h,'HandleVisibility','off');
        end
end



