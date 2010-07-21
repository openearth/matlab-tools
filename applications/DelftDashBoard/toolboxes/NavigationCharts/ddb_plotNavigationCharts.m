function ddb_plotNavigationCharts(handles,opt)

switch lower(opt)
    case{'delete'}
        h=findall(gca,'Tag','BBoxENC');
        if ~isempty(h)
            delete(h);
        end
        h=findall(gca,'Tag','NavigationChartLayer');
        if ~isempty(h)
            delete(h);
        end
    case{'activate'}
        h=findall(gca,'Tag','BBoxENC');
        if ~isempty(h)
            set(h,'Visible','on');
            set(h,'HandleVisibility','on');
        end
        ii=strmatch('NavigationCharts',{handles.Toolbox(:).Name},'exact');
        h=findall(gca,'Tag','NavigationChartLayer','UserData','LNDARE');
        if ~isempty(h)
            set(h,'HandleVisibility','on');
            if handles.Toolbox(ii).ShowShoreline
                set(h,'Visible','on');
            else
                set(h,'Visible','off');
            end
        end
        h=findall(gca,'Tag','NavigationChartLayer','UserData','SOUNDG');
        set(h,'HandleVisibility','on');
        if ~isempty(h)
            if handles.Toolbox(ii).ShowSoundings
                set(h,'Visible','on');
            else
                set(h,'Visible','off');
            end
        end
        h=findall(gca,'Tag','NavigationChartLayer','UserData','DEPCNT');
        set(h,'HandleVisibility','on');
        if ~isempty(h)
            if handles.Toolbox(ii).ShowContours
                set(h,'Visible','on');
            else
                set(h,'Visible','off');
            end
        end       
%         h=findall(gca,'Tag','NavigationChartLayer');
%         if ~isempty(h)
%             set(h,'Visible','on');
%             set(h,'HandleVisibility','on');
%         end
    case{'deactivate'}
        h=findall(gca,'Tag','BBoxENC');
        if ~isempty(h)
            set(h,'Visible','off');
            set(h,'HandleVisibility','off');
        end
        h=findall(gca,'Tag','NavigationChartLayer');
        if ~isempty(h)
            set(h,'Visible','off');
            set(h,'HandleVisibility','off');
        end
end



