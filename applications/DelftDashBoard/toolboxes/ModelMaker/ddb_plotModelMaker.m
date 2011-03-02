function ddb_plotModelMaker(option,varargin)

switch lower(option)
    case{'delete'}
        h=findall(gca,'Tag','GridOutline');
        if ~isempty(h)
            usd=get(h,'userdata');
            sh=usd.ch;
            delete(sh);
            delete(h);
        end
        h=findall(gca,'Tag','CoastSpline');
        if ~isempty(h)
            delete(h);
        end
    case{'activate'}
        h=findobj(gca,'Tag','GridOutline');
        if ~isempty(h)
            usd=get(h,'userdata');
            sh=usd.ch;
            set(h,'Visible','on');
            set(sh,'Visible','on');
        end
        h=findobj(gca,'Tag','CoastSpline');
        if ~isempty(h)
            set(h,'Visible','on');
        end
    case{'deactivate'}
        h=findobj(gca,'Tag','GridOutline');
        if ~isempty(h)
            usd=get(h,'userdata');
            sh=usd.ch;
            set(h,'Visible','off');
            set(sh,'Visible','off');
        end
        h=findobj(gca,'Tag','CoastSpline');
        if ~isempty(h)
            set(h,'Visible','off');
        end
end

