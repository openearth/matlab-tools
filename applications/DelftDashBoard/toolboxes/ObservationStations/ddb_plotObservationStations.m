function ddb_plotObservationStations(option,varargin)

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
        end
        h=findobj(gca,'Tag','ActiveObservationStation');
        if ~isempty(h)
            set(h,'Visible','on');
        end
    case{'deactivate'}
        h=findobj(gca,'Tag','ObservationStations');
        if ~isempty(h)
            set(h,'Visible','off');
        end
        h=findobj(gca,'Tag','ActiveObservationStation');
        if ~isempty(h)
            set(h,'Visible','off');
        end
end



