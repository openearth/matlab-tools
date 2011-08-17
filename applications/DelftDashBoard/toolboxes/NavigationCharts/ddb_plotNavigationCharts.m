function ddb_plotNavigationCharts(option,varargin)


switch lower(option)
    case{'delete'}
        h=findobj(gca,'Tag','BBoxENC');
        if ~isempty(h)
            delete(h);
        end
        h=findobj(gca,'Tag','NavigationChartLayer');
        if ~isempty(h)
            delete(h);
        end
    case{'activate'}

        handles=getHandles;

        h=findobj(gca,'Tag','BBoxENC');
        if ~isempty(h)
            set(h,'Visible','on');
            set(h,'HandleVisibility','on');
        end
        ii=strmatch('NavigationCharts',{handles.Toolbox(:).name},'exact');
        h=findobj(gca,'Tag','NavigationChartLayer','UserData','LNDARE');
        if ~isempty(h)
            set(h,'HandleVisibility','on');
            if handles.Toolbox(ii).Input.showShoreline
                set(h,'Visible','on');
            else
                set(h,'Visible','off');
            end
        end
        h=findobj(gca,'Tag','NavigationChartLayer','UserData','SOUNDG');
        set(h,'HandleVisibility','on');
        if ~isempty(h)
            if handles.Toolbox(ii)Input.showSoundings
                set(h,'Visible','on');
            else
                set(h,'Visible','off');
            end
        end
        h=findobj(gca,'Tag','NavigationChartLayer','UserData','DEPCNT');
        set(h,'HandleVisibility','on');
        if ~isempty(h)
            if handles.Toolbox(ii).Input.showContours
                set(h,'Visible','on');
            else
                set(h,'Visible','off');
            end
        end       
%         h=findobj(gca,'Tag','NavigationChartLayer');
%         if ~isempty(h)
%             set(h,'Visible','on');
%             set(h,'HandleVisibility','on');
%         end
    case{'deactivate'}
        h=findobj(gca,'Tag','BBoxENC');
        if ~isempty(h)
            set(h,'Visible','off');
            set(h,'HandleVisibility','off');
        end
        h=findobj(gca,'Tag','NavigationChartLayer');
        if ~isempty(h)
            set(h,'Visible','off');
            set(h,'HandleVisibility','off');
        end
end



