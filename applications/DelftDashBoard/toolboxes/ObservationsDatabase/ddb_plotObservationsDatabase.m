function ddb_plotObservationsDatabase(option,varargin)

switch lower(option)
    case{'delete'}
        h=findobj(gca,'Tag','ObservationStations');
        delete(h);
        h=findobj(gca,'Tag','ActiveObservationStation');
        delete(h);
    case{'activate'}
        h=findobj(gca,'Tag','ObservationStations');
        if ~isempty(h)
            set(h,'Visible','on');
            set(h,'HandleVisibility','on');
        end
        h=findobj(gca,'Tag','ActiveObservationStation');
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



