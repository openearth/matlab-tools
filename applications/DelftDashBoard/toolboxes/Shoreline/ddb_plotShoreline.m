function ddb_plotShoreline(option,varargin)

switch lower(option)
    case{'delete'}
        h=findobj(gca,'Tag','ShorelinePolygon');
        delete(h);
    case{'activate'}
        h=findobj(gca,'Tag','ShorelinePolygon');
        set(h,'Visible','on');
    case{'deactivate'}
        h=findobj(gca,'Tag','ShorelinePolygon');
        set(h,'Visible','off');
end
