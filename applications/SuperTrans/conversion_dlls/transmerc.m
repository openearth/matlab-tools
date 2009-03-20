function [x2,y2]=transmerc(x1,y1,a,invf,k0,FE,FN,lat0,lon0,iopt)
%TRANSMERC   transverse Mercator projection
%
% [x2,y2]=transmerc(x1,y1,a,invf,k0,FE,FN,lat0,lon0,iopt)
%
%See also: 

%% Transverse Mercator

if iopt==1
%     lon=pi*x1/180;
%     lat=pi*y1/180;
    lon=x1;
    lat=y1;
else
    E=x1;
    N=y1;
end

f=1/invf;
e2=2*f-f^2;
e4=e2^2;
e6=e2^3;
eac2=e2/(1-e2);
M0 = a*((1 - e2/4 - 3*e4/64 - 5*e6/256)*lat0 - (3*e2/8 + 3*e4/32 + 45*e6/1024)*sin(2*lat0) + (15*e4/256 + 45*e6/1024)*sin(4*lat0) - (35*e6/3072)*sin(6*lat0));

if iopt==1
    %% geo2xy
    T  = (tan(lat))^2;
    nu = a /(1 - e2*(sin(lat))^2)^0.5;
    C  = e2*(cos(lat))^2/(1 - e2);
    A  = (lon - lon0)*cos(lat);
    M  = a*((1 - e2/4 - 3*e4/64 - 5*e6/256)*lat - (3*e2/8 + 3*e4/32 + 45*e6/1024)*sin(2*lat) + (15*e4/256 + 45*e6/1024)*sin(4*lat) - (35*e6/3072)*sin(6*lat));
    x2 =  FE + k0*nu*(A + (1 - T + C)*A^3/6 + (5 - 18*T + T^2 + 72*C - 58*eac2)*A^5/120);
    y2 =  FN + k0*(M - M0 + nu*tan(lat)*(A^2/2 + (5 - T + 9*C + 4*C^2)*A^4/24 + (61 - 58*T + T^2 + 600*C - 330*eac2)*A^6/720));
else
    %% xy2geo
    e1  = (1- (1 - e2)^0.5)/(1 + (1 - e2)^0.5);
    M1  = M0 + (N - FN)/k0;
    mu1 = M1/(a*(1 - e2/4 - 3*e4/64 - 5*e6/256));
    lat1 = mu1 + ((3*e1)/2 - 27*e1^3/32)*sin(2*mu1) + (21*e1^2/16 -55*e1^4/32)*sin(4*mu1)+ (151*e1^3/96)*sin(6*mu1) + (1097*e1^4/512)*sin(8*mu1);
    nu1  = a /(1 - e2*(sin(lat1))^2)^0.5;
    rho1 = a*(1 - e2)/(1 - e2*(sin(lat1))^2)^1.5;
    T1   = (tan(lat1))^2;
    C1   = eac2*(cos(lat1))^2;
    D    = (E - FE)/(nu1*k0);
    lat = lat1 - (nu1*tan(lat1)/rho1)*(D^2/2 - (5 + 3*T1 + 10*C1 - 4*C1^2 - 9*eac2)*D^4/24 + (61 + 90*T1 + 298*C1 + 45*T1^2 - 252*eac2 - 3*C1^2)*D^6/720);
    lon = lon0 + (D - (1 + 2*T1 + C1)*D^3/6 + (5 - 2*C1 + 28*T1 - 3*C1^2 + 8*eac2 + 24*T1^2)*D^5/120) / cos(lat1);
%     x2=180*lon/pi;
%     y2=180*lat/pi;
    x2=lon;
    y2=lat;
end


