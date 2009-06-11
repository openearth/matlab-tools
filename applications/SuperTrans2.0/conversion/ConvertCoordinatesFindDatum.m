function CS = ConvertCoordinatesFindDatum(CS,STD)
ind1 = find(STD.coordinate_reference_system.coord_ref_sys_code == CS.geoRefSys.code);
CS.datum.code = STD.coordinate_reference_system.datum_code(ind1); %#ok<FNDSB>
ind2 = find(STD.datum.datum_code == CS.datum.code);
CS.datum.name = STD.datum.datum_name{ind2}; %#ok<FNDSB>
end