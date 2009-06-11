function CS = ConvertCoordinatesFindCoordSys(CS,STD)
ind1             = find(STD.coordinate_reference_system.coord_ref_sys_code == CS.code);
CS.coordSys.code =      STD.coordinate_reference_system.coord_sys_code(ind1); %#ok<FNDSB>
ind2             = find(STD.coordinate_system.coord_sys_code == CS.coordSys.code);
CS.coordSys.name =      STD.coordinate_system.coord_sys_name{ind2}; %#ok<FNDSB>
end