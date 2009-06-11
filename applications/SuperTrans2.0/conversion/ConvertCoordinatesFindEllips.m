function CS = ConvertCoordinatesFindEllips(CS,STD)
ind1 = find(STD.datum.datum_code == CS.datum.code);
ell.code = STD.datum.ellipsoid_code(ind1) ; %#ok<FNDSB>
ind2 = find(STD.ellipsoid.ellipsoid_code == ell.code);

ell.name  = STD.ellipsoid.ellipsoid_name{ind2}; %#ok<FNDSB>
ell.inv_flattening = STD.ellipsoid.inv_flattening(ind2); %#ok<FNDSB>
ell.semi_major_axis = STD.ellipsoid.semi_major_axis(ind2); %#ok<FNDSB>
ell.semi_minor_axis = STD.ellipsoid.semi_minor_axis(ind2); %#ok<FNDSB>

% calculate inv_flattening if it is not given
if isnan(ell.inv_flattening)
    ell.inv_flattening=ell.semi_major_axis/(ell.semi_major_axis-ell.semi_minor_axis);
end

% calculate semi minor axis if it is not given
if isnan(ell.semi_minor_axis)
    ell.semi_minor_axis = -(ell.semi_major_axis/ell.inv_flattening)+ell.semi_major_axis;
end

CS.ellips = ell;
end


