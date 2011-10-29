function ddb_plotTideDatabase(option,varargin)

switch lower(option)
    case{'delete'}
        h=findobj(gca,'Tag','TideDatabaseBox');
        delete(h);
    case{'activate'}
        h=findobj(gca,'Tag','TideDatabaseBox');
        set(h,'Visible','on');
    case{'deactivate'}
        h=findobj(gca,'Tag','TideDatabaseBox');
        set(h,'Visible','off');
end
