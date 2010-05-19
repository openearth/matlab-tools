function [x1,y1]=ddb_coordConvert(x1,y1,OldSys,NewSys)

%x1=x0;
%y1=y0;

if strcmpi(OldSys.Name,NewSys.Name)
    return
end

handles=getHandles;

if strcmp(OldSys.Type,'Cartesian')
    tp0='xy';
else
    tp0='geo';
end

if strcmp(NewSys.Type,'Cartesian')
    tp1='xy';
else
    tp1='geo';
end

cs0=OldSys.Name;
cs1=NewSys.Name;

[x1,y1]=convertCoordinates(x1,y1,handles.EPSG,'CS1.name',cs0,'CS1.type',tp0,'CS2.name',cs1,'CS2.type',tp1);
