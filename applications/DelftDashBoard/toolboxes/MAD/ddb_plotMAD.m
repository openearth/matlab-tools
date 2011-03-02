function ddb_plotMAD(option,varargin)

switch lower(option)
    case{'delete'}
        h=findall(gca,'Tag','MADModels');
        if ~isempty(h)
            delete(h);
        end
        h=findall(gca,'Tag','ActiveMADModel');
        if ~isempty(h)
            delete(h);
        end
    case{'activate'}
        h=findall(gca,'Tag','MADModels');
        if ~isempty(h)
            set(h,'Visible','on');
        end
        h=findall(gca,'Tag','ActiveMADModel');
        if ~isempty(h)
            set(h,'Visible','on');
        end
    case{'deactivate'}
        h=findall(gca,'Tag','MADModels');
        if ~isempty(h)
            set(h,'Visible','off');
        end
        h=findall(gca,'Tag','ActiveMADModel');
        if ~isempty(h)
            set(h,'Visible','off');
        end
end

