function ddb_plotOPeNDAPBrowser(option,varargin)

switch lower(option)
    case{'delete'}
        h=findobj(gca,'Tag','OPeNDAPPoint');
        delete(h);
        h=findobj(gca,'Tag','OPeNDAPGrid');
        delete(h);
    case{'activate'}
        h=findobj(gca,'Tag','OPeNDAPPoint');
        if ~isempty(h)
            set(h,'Visible','on');
            set(h,'HandleVisibility','on');
        end
        h=findobj(gca,'Tag','OPeNDAPGrid');
        if ~isempty(h)
            set(h,'Visible','on');
            set(h,'HandleVisibility','on');
        end
    case{'deactivate'}
        h=findobj(gca,'Tag','OPeNDAPPoint');
        if ~isempty(h)
            set(h,'Visible','off');
            set(h,'HandleVisibility','off');
        end
        h=findobj(gca,'Tag','OPeNDAPGrid');
        if ~isempty(h)
            set(h,'Visible','off');
            set(h,'HandleVisibility','off');
        end
end



