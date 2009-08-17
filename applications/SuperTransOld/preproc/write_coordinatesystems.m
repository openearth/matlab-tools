clear all ;close all;

load EPSG.mat

ngeo2=0;
ngeo3=0;
nproj=0;
nother=0;
n=length(EPSG.coordinate_reference_system);

coordinate_operation=EPSG.coordinate_operation;
for i=1:n
    %    i
    h=EPSG.coordinate_reference_system(i).coord_ref_sys_kind;
    switch(h),
        case {'geographic 2D'}
            ngeo2=ngeo2+1;
            nproj=nproj+1;
            CoordinateSystems(nproj)=EPSG.coordinate_reference_system(i);
            CoordinateSystems(nproj).source_geogcrs_code=EPSG.coordinate_reference_system(i).coord_ref_sys_code;
%             j=findinstruct(EPSG.datum,'datum_code',CoordinateSystems(nproj).datum_code);
%             CoordinateSystems(nproj).datum_name=EPSG.datum(j).datum_name;
        case {'geographic 3D'}
            ngeo3=ngeo3+1;
            %             nproj=nproj+1;
            %             CoordinateSystems(nproj)=EPSG.coordinate_reference_system(i);
        case {'projected'}
            nproj=nproj+1;
            CoordinateSystems(nproj)=EPSG.coordinate_reference_system(i);
            ic=EPSG.coordinate_reference_system(i).source_geogcrs_code;
            j=findinstruct(EPSG.coordinate_reference_system,'coord_ref_sys_code',ic);
            CoordinateSystems(nproj).datum_code=EPSG.coordinate_reference_system(j).datum_code;
%             j=findinstruct(EPSG.datum,'datum_code',CoordinateSystems(nproj).datum_code);
%             CoordinateSystems(nproj).datum_name=EPSG.datum(j).datum_name;
        otherwise
            nother=nother+1;
    end
end

for i=1:nproj
    id=CoordinateSystems(i).datum_code;
    cscode=CoordinateSystems(i).coord_sys_code;
    j=findinstruct(EPSG.coordinate_system,'coord_sys_code',cscode);
    CoordinateSystems(i).coord_sys_name=EPSG.coordinate_system(j).coord_sys_name;
    if ~isnan(id)
        j=findinstruct(EPSG.datum,'datum_code',id);
        CoordinateSystems(i).datum_name=EPSG.datum(j).datum_name;
        dt=EPSG.datum(j);
        ellcode=dt.ellipsoid_code;
        j=findinstruct(EPSG.ellipsoid,'ellipsoid_code',ellcode);
        ell=EPSG.ellipsoid(j);
        CoordinateSystems(i).ellipsoid.ellipsoid_name=ell.ellipsoid_name;
        CoordinateSystems(i).ellipsoid.semi_major_axis=ell.semi_major_axis;
        CoordinateSystems(i).ellipsoid.semi_minor_axis=ell.semi_minor_axis;
        CoordinateSystems(i).ellipsoid.inv_flattening=ell.inv_flattening;
    end
end

save CoordinateSystems.mat CoordinateSystems


