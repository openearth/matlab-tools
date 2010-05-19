function ddb_plotHurricane(handles,opt)

switch lower(opt)
    case{'delete'}
        h=findobj(gca,'Tag','HurricaneTrack');
        delete(h);
    case{'activate'}
        h=findobj(gca,'Tag','HurricaneTrack');
        if ~isempty(h)
            set(h,'Visible','on');
        end
    case{'deactivate'}
        h=findobj(gca,'Tag','HurricaneTrack');
        if ~isempty(h)
            set(h,'Visible','off');
        end
end

