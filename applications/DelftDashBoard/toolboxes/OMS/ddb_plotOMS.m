function ddb_plotOMS(handles,opt)

switch lower(opt)
    case{'delete'}
        h=findall(gca,'Tag','OMSStations');
        delete(h);
        h=findall(gca,'Tag','ActiveOMSStation');
        delete(h);
        
        h=findall(gca,'Tag','OMSModelLimits');
        if ~isempty(h)
            usd=get(h,'userdata');
            try
                sh=usd.ch;
                delete(sh);
                delete(h);
            end
        end

    case{'activate'}
        h=findall(gca,'Tag','OMSStations');
        if ~isempty(h)
            set(h,'Visible','on');
            set(h,'HandleVisibility','on');
        end
        h=findall(gca,'Tag','ActiveOMSStation');
        if ~isempty(h)
            set(h,'Visible','on');
            set(h,'HandleVisibility','on');
        end

        h=findall(gca,'Tag','OMSModelLimits');
        if ~isempty(h)
            usd=get(h,'userdata');
            try
                sh=usd.ch;
                set(sh,'Visible','on');
                set(sh,'HandleVisibility','on');
                set(h,'Visible','on');
                set(h,'HandleVisibility','on');
            end
        end

    case{'deactivate'}
        h=findobj(gca,'Tag','OMSStations');
        if ~isempty(h)
            set(h,'Visible','off');
            set(h,'HandleVisibility','off');
        end
        h=findobj(gca,'Tag','ActiveOMSStation');
        if ~isempty(h)
            set(h,'Visible','off');
            set(h,'HandleVisibility','off');
        end

        h=findall(gca,'Tag','OMSModelLimits');
        if ~isempty(h)
            usd=get(h,'userdata');
            try
                sh=usd.ch;
                set(sh,'Visible','off');
                set(sh,'HandleVisibility','off');
                set(h,'Visible','off');
                set(h,'HandleVisibility','off');
            end
        end

end





