function deg = ddb_dms2degrees(dms)
% Convert N-by-3 [deg min sec] to decimal degrees
sgn = 1 - 2*any(dms < 0, 2);
deg = sgn .* (abs(dms(:,1)) + abs(dms(:,2))/60 + abs(dms(:,3))/3600);
