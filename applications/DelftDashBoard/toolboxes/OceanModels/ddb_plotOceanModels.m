function ddb_plotOceanModels(option,varargin) 

switch lower(option)
    case{'delete'}
        h=findobj(gca,'Tag','OceanModelOutline');
        delete(h);
    case{'activate'}
        h=findobj(gca,'Tag','OceanModelOutline');
        if ~isempty(h)
            set(h,'Visible','on');
        end
    case{'deactivate'}
        h=findobj(gca,'Tag','OceanModelOutline');
        if ~isempty(h)
            set(h,'Visible','off');
        end
end
