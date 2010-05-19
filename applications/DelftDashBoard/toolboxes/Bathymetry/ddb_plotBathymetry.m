function ddb_plotBathymetry(handles,opt)

switch lower(opt)
    case{'delete'}
        h=findobj(gca,'Tag','BathymetryPolygon');
        delete(h);
    case{'activate'}
        h=findobj(gca,'Tag','BathymetryPolygon');
        set(h,'Visible','on');
    case{'deactivate'}
        h=findobj(gca,'Tag','BathymetryPolygon');
        set(h,'Visible','off');
end
