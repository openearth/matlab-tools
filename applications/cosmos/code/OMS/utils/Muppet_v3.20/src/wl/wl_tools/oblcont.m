function [C0,H]=oblcont(x0,y0,z0,normvec,varargin)
%OBLCONT Creates 3-D oblique contour lines.
%
%   OBLCONT(X,Y,Z,VECTOR,...) is the same as CONTOUR3(...) except
%   that the contours are drawn in planes normal to the specified
%   vector. That is, specifying levels [L1 ...] and a vector [V1 V2 V3]
%   draws contour lines in the planes V1*X+V2*Y+V3*Z=L1, ...
%   For VECTOR=[0 0 1] this function is basically equal to CONTOUR3.
%
%   Alternatively the vector can be specified using azimuth and elevation:
%   OBLCONT(X,Y,Z,[AZ EL],...)
%   This will use [SIN(F*AZ)*COS(F*EL) -COS(F*AZ)*COS(F*EL) SIN(F*EL)]
%   as vector, where F=pi/180. VIEW(AZ,EL) will give you a view
%   perpendicular to the slice surface.
%
%   Note: X,Y,Z should be of equal size.
%
%   C = CONTOUR3(...) returns contour matrix C. Unfortunately this matrix
%   does not satisfy the description in CONTOURC. So, it cannot be used
%   by CLABEL. The contour matrix C is a three row matrix of contour lines.
%   Each contiguous drawing segment contains the value of the contour, 
%   the number of (x,y,z) drawing triplets, and the triplets themselves.  
%   The segments are appended end-to-end as
% 
%       C = [level1 x1 x2 x3 ... level2 x2 x2 x3 ...;
%            tripl1 y1 y2 y3 ... tripl2 y2 y2 y3 ...;
%            0      z1 z2 z3 ... 0      z2 z2 z3 ...]
% 
%   [C,H] = CONTOUR3(...) returns a column vector H of handles to PATCH
%   objects. The UserData property of each object contains the height
%   value for each contour. 
%
%   Example:
%       surf(peaks)
%       shading flat
%       hold on
%       oblcont(x,y,peaks,[1 1 0],10,'k')
%
%   See also CONTOUR, CONTOUR3, CLABEL, COLORBAR.

%   Copyright (c) 2001 by H.R.A.Jagers
%                         WL | Delft Hydraulics, The Netherlands
%                         bert.jagers@wldelft.nl
%   Function history:
%             11/ 1/2001: created
%             25/ 1/2001: added recognition of [AZ EL] vector

error(nargchk(4,6,nargin));
if length(normvec)==2, % [azimuth elevation]
  az=normvec(1);
  el=normvec(2);
  normvec=[sin(az*pi/180)*cos(el*pi/180) -cos(az*pi/180)*cos(el*pi/180) sin(el*pi/180)]
end
e1=[1 0 0];
e2=[0 1 0];
e3=[0 0 1];
normvec=normvec(:)';
normvec1=normvec/norm(normvec);
planevec1=e1-sum(e1.*normvec1)*normvec1;
if norm(planevec1)<1e-15, % normvec equal to multiple of e1
  planevec1=e2-sum(e2.*normvec1)*normvec1;
end
planevec1=planevec1/norm(planevec1);
planevec2=cross(normvec1,planevec1);

RotationMatrix=[planevec1; planevec2; normvec];
InverseMatrix=transpose(inv(RotationMatrix));
x1=planevec1(1)*x0+planevec1(2)*y0+planevec1(3)*z0;
y1=planevec2(1)*x0+planevec2(2)*y0+planevec2(3)*z0;
z1=  normvec(1)*x0+  normvec(2)*y0+  normvec(3)*z0;

newplot;
lochold=0;
if ~ishold
  lochold=1;
end
[C,H] = contour3(x1,y1,z1,varargin{:});

for i=1:length(H),
  x1=get(H(i),'xdata');
  y1=get(H(i),'ydata');
  z1=get(H(i),'zdata');
  coords=[x1(:) y1(:) z1(:)];
  coords=coords*InverseMatrix;
  set(H(i),'xdata',coords(:,1),'ydata',coords(:,2),'zdata',coords(:,3))
end
if lochold
  set(gca,'xlimmode','auto','ylimmode','auto','zlimmode','auto');
end

if nargout>0
  InverseMatrix=transpose(InverseMatrix);
  C0=zeros(3,size(C,2));
  i=1;
  while i<size(C,2),
    lvl=C(1,i);
    N=C(2,i);
    C0(1,i)=lvl;
    C0(2,i)=N;
    idx=i+(1:N);
    C0(1:2,idx)=C;
    C0(3,idx)=lvl;
    C0(:,idx)=InverseMatrix*C0(:,idx);
  end
end