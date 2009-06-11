function CS = ConvertCoordinatesFindGeoRefSys(CS,STD)
if strcmp(CS.type,'projected')
    ind1 = find(STD.coordinate_reference_system.coord_ref_sys_code == CS.code);
    CS.geoRefSys.code = STD.coordinate_reference_system.source_geogcrs_code(ind1); %#ok<FNDSB>
    ind2 = find(STD.coordinate_reference_system.coord_ref_sys_code == CS.geoRefSys.code);
    CS.geoRefSys.name = STD.coordinate_reference_system.coord_ref_sys_name{ind2}; %#ok<FNDSB>
else
    CS.geoRefSys.name = CS.name;
    CS.geoRefSys.code = CS.code;
end
