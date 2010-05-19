function [lat,lon,h]=xyz2ell(X,Y,Z,a,e2)
% XYZ2ELL  Converts cartesian coordinates to ellipsoidal.
%   Uses iterative alogithm.  Vectorized.  See also XYZ2ELL2,
%   XYZ2ELL3.
% Version: 25 Oct 96
% Useage:  [lat,lon,h]=xyz2ell(X,Y,Z,a,e2)
% Input:   X \
%          Y  > vectors of cartesian coordinates in CT system (m)
%          Z /
%          a   - ref. ellipsoid major semi-axis (m)
%          e2  - ref. ellipsoid eccentricity squared
% Output:  lat - vector of ellipsoidal latitudes (radians)
%          lon - vector of ellipsoidal longitudes (radians)
%          h   - vector of ellipsoidal heights (m)
% Borrowed from the Geodetic Toolbox by Mike Craymer 

%% Reshape to column vector

nx=size(X,1);
ny=size(Y,2);

X=reshape(X,[nx*ny 1]);
Y=reshape(Y,[nx*ny 1]);
Z=reshape(Z,[nx*ny 1]);

% Conversion

elat=1.e-12;
eht=1.e-5;
p=sqrt(X.*X+Y.*Y);
lat=atan2(Z,p./(1-e2));
h=0;
dh=1;
dlat=1;
while sum(dlat>elat) || sum(dh>eht)
  lat0=lat;
  h0=h;
  v=a./sqrt(1-e2.*sin(lat).*sin(lat));
  h=p./cos(lat)-v;
  lat=atan2(Z, p.*(1-e2.*v./(v+h)));
  dlat=abs(lat-lat0);
  dh=abs(h-h0);
end
lon=atan2(Y,X);

%% Back to original shape

lat=reshape(lat,[nx ny]);
lon=reshape(lon,[nx ny]);
h=reshape(h,[nx ny]);
