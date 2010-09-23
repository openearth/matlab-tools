function ddb_plotOPeNDAPBrowser(handles,opt)

switch lower(opt)
    case{'delete'}
        h=findall(gca,'Tag','OPeNDAPPoint');
        delete(h);
        h=findall(gca,'Tag','OPeNDAPGrid');
        delete(h);
    case{'activate'}
        h=findall(gca,'Tag','OPeNDAPPoint');
        if ~isempty(h)
            set(h,'Visible','on');
            set(h,'HandleVisibility','on');
        end
        h=findall(gca,'Tag','OPeNDAPGrid');
        if ~isempty(h)
            set(h,'Visible','on');
            set(h,'HandleVisibility','on');
        end
    case{'deactivate'}
        h=findall(gca,'Tag','OPeNDAPPoint');
        if ~isempty(h)
            set(h,'Visible','off');
            set(h,'HandleVisibility','off');
        end
        h=findall(gca,'Tag','OPeNDAPGrid');
        if ~isempty(h)
            set(h,'Visible','off');
            set(h,'HandleVisibility','off');
        end
end



