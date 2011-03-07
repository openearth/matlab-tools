function ddb_plotGeoImage(option,varargin)

switch lower(option)
    case{'delete'}
        h=findobj(gca,'Tag','ImageOutline');
        delete(h);
    case{'activate'}
        h=findobj(gca,'Tag','ImageOutline');
        if ~isempty(h)
            set(h,'Visible','on');
        end
    case{'deactivate'}
        h=findobj(gca,'Tag','ImageOutline');
        if ~isempty(h)
            set(h,'Visible','off');
        end
end
