function ddb_plotDD(option,varargin)

switch lower(option)
    case{'delete'}
        h=findobj(gca,'Tag','DDCornerPoint');
        if ~isempty(h)
            delete(h);
        end
        h=findobj(gca,'Tag','TemporaryDDGrid');
        if ~isempty(h)
            delete(h);
        end
    case{'activate'}
        h=findobj(gca,'Tag','TemporaryDDGrid');
        if ~isempty(h)
            set(h,'Visible','on');
        end
        h=findobj(gca,'Tag','DDCornerPoint');
        if ~isempty(h)
            set(h,'Visible','on');
        end
    case{'deactivate'}
        h=findobj(gca,'Tag','TemporaryDDGrid');
        if ~isempty(h)
            set(h,'Visible','off');
        end
        h=findobj(gca,'Tag','DDCornerPoint');
        if ~isempty(h)
            set(h,'Visible','off');
        end
end
