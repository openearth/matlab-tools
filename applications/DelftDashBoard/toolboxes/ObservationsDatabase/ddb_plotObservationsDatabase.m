function ddb_plotObservationsDatabase(handles,opt)

switch lower(opt)
    case{'delete'}
        h=findall(gca,'Tag','ObservationStations');
        delete(h);
        h=findall(gca,'Tag','ActiveObservationStation');
        delete(h);
    case{'activate'}
        h=findall(gca,'Tag','ObservationStations');
        if ~isempty(h)
            set(h,'Visible','on');
            set(h,'HandleVisibility','on');
        end
        h=findall(gca,'Tag','ActiveObservationStation');
        if ~isempty(h)
            set(h,'Visible','on');
            set(h,'HandleVisibility','on');
        end
    case{'deactivate'}
        h=findobj(gca,'Tag','ObservationStations');
        if ~isempty(h)
            set(h,'Visible','off');
            set(h,'HandleVisibility','off');
        end
        h=findobj(gca,'Tag','ActiveObservationStation');
        if ~isempty(h)
            set(h,'Visible','off');
            set(h,'HandleVisibility','off');
        end
end



