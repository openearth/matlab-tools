function rdOut=geo2rd(geoIn);% GEO wgs84 naar RD

% rdOut=geo2rd(geoIn);
% GEO wgs84 naar RD
% geoIn = Mx2 array with lon and lat coordinates
% rdOut = Mx2 array with x and y RD coordinates

dF = 0.36 * (geoIn(:,2) - 52.15517440);
dL = 0.36 * (geoIn(:,1) - 5.38720621);

SomX= (190094.945 .* dL) + (-11832.228 .* dF .* dL) + (-144.221 .* dF.^2 .* dL) + (-32.391 .* dL.^3) + (-0.705 .* dF) + (-2.340 .* dF.^3 .* dL) + (-0.608 .* dF .* dL.^3) + (-0.008 .* dL.^2) + (0.148 .* dF.^2 .* dL.^3);
SomY = (309056.544 .* dF) + (3638.893 .* dL.^2) + (73.077 .* dF.^2 ) + (-157.984 .* dF .* dL.^2) + (59.788 .* dF.^3 ) + (0.433 .* dL) + (-6.439 .* dF.^2 .* dL.^2) + (-0.032 .* dF .* dL) + (0.092 .* dL.^4) + (-0.054 .* dF .* dL.^4);

rdOut=[155000+SomX 463000+SomY];
