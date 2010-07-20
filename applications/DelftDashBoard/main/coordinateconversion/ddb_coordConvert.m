function [x1,y1]=ddb_coordConvert(x1,y1,OldSys,NewSys)

if strcmpi(OldSys.Name,NewSys.Name)
    return
end

handles=getHandles;

switch lower(OldSys.Type)
    case{'cartesian','cart','xy','projection','projected','proj'}
        tp0='xy';
    case{'geo','geographic','geographic 2d','geographic 3d','spherical','latlon'}
        tp0='geo';
end

switch lower(NewSys.Type)
    case{'cartesian','cart','xy','projection','projected','proj'}
        tp1='xy';
    case{'geo','geographic','geographic 2d','geographic 3d','spherical','latlon'}
        tp1='geo';
end

cs0=OldSys.Name;
cs1=NewSys.Name;

[x1,y1]=convertCoordinates(x1,y1,handles.EPSG,'CS1.name',cs0,'CS1.type',tp0,'CS2.name',cs1,'CS2.type',tp1);
