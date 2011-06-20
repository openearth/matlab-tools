function [xpl,ypl,sd,ds]=pnt2line(xp,yp,xl,yl,opt)
%PNT2LINE Project sample points onto a line
%      [XPL,YPL]=PNT2LINE(XP,YP,XL,YL)
%      Projects the points (XP,YP) onto the line
%      given by (XL,YL) and returns the projected
%      coordinates (XPL,YPL). Projection is here
%      defined as the closest point on the line
%      or on the linear extrapolation of the first
%      and last line segments.
%
%      [XPL,YPL,DIST,DS]=PNT2LINE(XP,YP,XL,YL)
%      returns also the DISTance between the
%      original and projected point, and the 
%      coordinate DS measured along the line
%      (XL,YL) of the projected point.
%
%      ...,'EXTEND')
%      first and last line segment are extended
%      indefinitely.

% (c) 2001 H.R.A. Jagers
%          WL | Delft Hydraulics
%          bert.jagers@wldelft.nl

sz  = size(xp);
xp  = xp(:);
yp  = yp(:);
sd  = inf*ones(size(xp));
xpl = repmat(NaN,size(xp));
ypl = xpl;
ds  = xpl;
nxl = length(xl);
ds0 = 0;

extendfirstlast=strcmp(lower(opt),'extend');

for i = 1:nxl
  xli  = xl(i);
  yli  = yl(i);
  sdi  = (xp-xli).^2+(yp-yli).^2;
  mask = sdi<sd;
  if any(mask)
    xpl(mask) = xli;
    ypl(mask) = yli;
    sd(mask)  = sdi(mask);
    ds(mask)  = ds0;
  end
  if i==nxl, break; end
%
  dxl  = xl(i+1) - xli;
  dyl  = yl(i+1) - yli;
  ds2  = dxl^2 + dyl^2;
  ndxl = dxl / ds2;
  ndyl = dyl / ds2;
  lmb  = (xp-xli)*ndxl + (yp-yli)*ndyl;
  pxp  = xli + lmb*dxl;
  pyp  = yli + lmb*dyl;
  sdi  = (xp-pxp).^2 + (yp-pyp).^2;
  first = (i==1) & extendfirstlast;
  last  = (i==nxl-1) & extendfirstlast;
  mask  = (sdi<sd) & (first|(lmb>=0)) & (last|(lmb<=1));
  if any(mask)
    xpl(mask) = pxp(mask);
    ypl(mask) = pyp(mask);
    sd(mask)  = sdi(mask);
    ds(mask)  = ds0 + lmb(mask)*sqrt(ds2);
  end
  ds0 = ds0 + sqrt(ds2);
end
sd  = sqrt(sd);
xpl = reshape(xpl,sz);
ypl = reshape(ypl,sz);
sd  = reshape(sd,sz);
ds  = reshape(ds,sz);
