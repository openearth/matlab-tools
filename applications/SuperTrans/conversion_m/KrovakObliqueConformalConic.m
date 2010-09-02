function [x2,y2]= KrovakObliqueConformalConic(x1,y1,a,finv,fe,fn,latpc,alphac,lat1,sf,lon0,iopt)

%KROVAKOBLIQUECONFORMALCONIC   map between (lon,lat) and (x,y) in Krovak Oblique Conformal Conic projection
%
%  [x2,y2]=
%  KrovakObliqueConformalConic(x1,y1,a,invf,fe,fn,latpc,alphac,lat1,sf,lon0,iopt);
%
% where iopt==1:geo2xy, else: xy2geo
%
%See also: CONVERTCOORDINATES

n1  = length(x1(:));
x2  = repmat(nan,size(x1));
y2  = repmat(nan,size(x1));

f=1/finv;
e2=2.0*f-f^2;
e=sqrt(e2);

A = a*(1-e2)^(0.5)/(1-e2*(sin(latpc))^2);
B = (1+e2*(cos(latpc))^4/(1-e2))^(0.5);
gam0 = asin(sin(latpc)/B);
t0 = tan(pi/4+gam0/2)*((1+e*sin(latpc))/(1-e*sin(latpc)))^(e*B/2)/(tan(pi/4+latpc/2))^B;
n=sin(lat1);
r0=sf*A/tan(lat1);
lon0 = lon0 - 2*pi*(17+40/60)/360; % Longitude of Ferro is 17°40'00" West of Greenwich

for i=1:n1
    if (iopt==1) % then
        %%          geo2xy
        lon=x1(i);
        lat=y1(i);
        U = 2*(atan(t0*tan(lat/2+pi/4)^B/((1+e*sin(lat))/(1-e*sin(lat)))^(e*B/2))-pi/4);
        V = B*(lon0-lon);
        S = asin(cos(alphac)*sin(U)+sin(alphac)*cos(U)*cos(V));
        D = asin(cos(U)*sin(V)/cos(S));
        th= n*D;
        r = r0*tan(pi/4+lat1/2)^n/tan(S/2+pi/4)^n;
        
        x2 = fn + r * cos(th);
        y2 = fe + r * sin(th);
        
    else
        %%          xy2geo
        x=x1(i);
        y=y1(i);
        r = ((y-fe)^2+(x-fn)^2)^(0.5);
        th = atan((y-fe)/(x-fn));
        D = th/sin(lat1);
        S = 2*(atan((r0/r)^(1/n)*tan(pi/4+lat1/2))-pi/4);
        U = asin(cos(alphac)*sin(S)-sin(alphac)*cos(S)*cos(D));
        V = asin(cos(S)*sin(D)/cos(U));
        
        phi_j = U;
        for j = 1:3
            phi_j = 2*(atan(t0^(-1/B)*tan(U/2+pi/4)^(1/B)*((1+e*sin(phi_j))/(1-e*sin(phi_j)))^(e/2))-pi/4);
        end
        
        lon = lon0 - V/B;
        lat = phi_j;
        
        x2 = lon;
        y2 = lat;
        
    end%if
    
end