function ddb_plotOMS(option,varargin)

switch lower(option)
    case{'delete'}
        h=findobj(gca,'Tag','OMSStations');
        delete(h);
        h=findobj(gca,'Tag','ActiveOMSStation');
        delete(h);
        
        h=findobj(gca,'Tag','OMSModelLimits');
        if ~isempty(h)
            usd=get(h,'userdata');
            try
                sh=usd.ch;
                delete(sh);
                delete(h);
            end
        end

    case{'activate'}
        h=findobj(gca,'Tag','OMSStations');
        if ~isempty(h)
            set(h,'Visible','on');
            set(h,'HandleVisibility','on');
        end
        h=findobj(gca,'Tag','ActiveOMSStation');
        if ~isempty(h)
            set(h,'Visible','on');
            set(h,'HandleVisibility','on');
        end

        h=findobj(gca,'Tag','OMSModelLimits');
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

        h=findobj(gca,'Tag','OMSModelLimits');
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





