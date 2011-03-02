function ddb_plotGeoImage(option,varargin)

switch lower(option)
    case{'delete'}
        h=findobj(gca,'Tag','ImageOutline');
        delete(h);
    case{'activate'}
        h=findobj(gca,'Tag','ImageOutline');
        if ~isempty(h)
            usd=get(h(1),'userdata');
            sh=usd.SelectionHighlights;
            set(h,'Visible','on');
            set(sh,'Visible','on');
        end
    case{'deactivate'}
        h=findobj(gca,'Tag','ImageOutline');
        if ~isempty(h)
            usd=get(h(1),'userdata');
            sh=usd.SelectionHighlights;
            set(h,'Visible','off');
            set(sh,'Visible','off');
        end
end
