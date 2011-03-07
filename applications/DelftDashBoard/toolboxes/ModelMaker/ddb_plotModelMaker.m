function ddb_plotModelMaker(option,varargin)

switch lower(option)
    case{'delete'}
        h=findobj(gca,'Tag','GridOutline');
        if ~isempty(h)
            delete(h);
        end
        h=findobj(gca,'Tag','CoastSpline');
        if ~isempty(h)
            delete(h);
        end
    case{'activate'}
        h=findobj(gca,'Tag','GridOutline');
        if ~isempty(h)
            set(h,'Visible','on');
        end
        h=findobj(gca,'Tag','CoastSpline');
        if ~isempty(h)
            set(h,'Visible','on');
        end
    case{'deactivate'}
        h=findobj(gca,'Tag','GridOutline');
        if ~isempty(h)
            set(h,'Visible','off');
        end
        h=findobj(gca,'Tag','CoastSpline');
        if ~isempty(h)
            set(h,'Visible','off');
        end
end

