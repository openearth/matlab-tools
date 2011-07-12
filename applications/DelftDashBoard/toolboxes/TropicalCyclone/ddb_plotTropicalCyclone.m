function ddb_plotTropicalCyclone(option,varargin)

switch lower(option)
    case{'delete'}
        h=findobj(gca,'Tag','cycloneTrack');
        if ~isempty(h)
            delete(h);
        end
    case{'activate'}
         h=findobj(gca,'Tag','cycloneTrack');
        if ~isempty(h)
            set(h,'Visible','on');
        end
   case{'deactivate'}
        h=findobj(gca,'Tag','cycloneTrack');
        if ~isempty(h)
            set(h,'Visible','off');
        end
end

