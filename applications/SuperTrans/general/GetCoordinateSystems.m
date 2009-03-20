function handles=GetCoordinateSystems(handles)
%GETCOORDINATESYSTEMS
%
% [CS,ok]=GetCoordinateSystems
%
% loads a struct with (meta-)info of all CoordinateSystems
% stored in CoordinateSystems.mat   
%
%See also: SuperTrans = GetCoordinateSystems > SelectCoordinateSystem > ConvertCoordinates

curdir=fileparts(which('SuperTrans'));
load([curdir '\data\CoordinateSystems.mat']);
load([curdir '\data\Operations.mat']);

handles.CoordinateSystems=CoordinateSystems;
handles.Operations       =Operations;

nproj=0;
ngeo=0;
for i=1:length(handles.CoordinateSystems)
    switch lower(handles.CoordinateSystems(i).coord_ref_sys_kind),
        case{'projected'}
            nproj =nproj+1;
            CSProj=handles.CoordinateSystems(i);
            handles.CoordSysCart{nproj}=CSProj.coord_ref_sys_name;
        case{'geographic 2d'}
            ngeo =ngeo+1;
            CSGeo                    =handles.CoordinateSystems(i);
            handles.CoordSysGeo{ngeo}=CSGeo.coord_ref_sys_name;
    end
end
