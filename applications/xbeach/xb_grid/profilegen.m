function [xgr,ygr,zgr] = profilegen(zin,xin,dy,Tm,dxmin)
% [xgr,ygr,zgr] = profilegen(zin,xin,dy,Tm,dxmin)
%
% Function to interpolate (no extrapolation) profile measurements to cross
% shore varying grid for an XBeach profile model. Cross shore grid size is
% limited by user-defined minimum grid size in shallow water and land, long
% wave resolution on offshore boundary, depth to grid size ratio and grid size
% smoothness constraints. The function uses the Courant condition to find the 
% optimal grid size given these constraints.
%
% Output cross shore varying xgr,ygr,zgr for XBeach. Save as ascii file:
%                    save x.grd xgr -ascii
%                    save y.grd ygr -ascii
%                    save bathy.dep zgr -ascii
% Depthfile is positive up (i.e. posdwn=-1). In XBeach params.txt specify vardx=1
% and xgrid = x.grd, ygrid = y.grd, depfile = bathy.dep. Also not the value
% of nx and ny (one less than the matlab dimensions).
%
% Input - zin (positive up), xin (increasing from zero towards shore) are 
%            vectors with profile measurements
%       - dy is required grid size in longshore direction
%       - Tm is mean incident short wave period (used for maximum grid size
%            on the offshore boundary
%       - dxmin is the minimum required cross shore grid size (usually over
%            land)
%
% Created 20-05-2009 : XBeach-group Delft


g=9.81;
k = disper(2*pi/Tm, -zin(1), g);
%Tlong_min = 7*Tm;
Llong=7*2*pi/k;
x=xin;
hin = max(0-zin,0.01);

% set boundaries
xend = x(end);
xstart = x(1);
xlast = xstart;

% grid settings
CFL = 0.85;
dtref=4.0;
maxfac = 1.15;
depthfac = 2.0;

ii = 1;
xgr(ii) = xstart;
hgr(ii) = hin(1);
while xlast<xend

    % compute dx; minimum value dx (on dry land) = dxmin
    dxmax = Llong/12;
%    dxmax = sqrt(g*hgr(min(ii)))*Tlong_min/12;
    dx(ii) = sqrt(g*hgr(ii))*dtref/CFL;
    dx(ii) = min(dx(ii),depthfac*hgr(ii));
    dx(ii) = max(dx(ii),dxmin);
    if dxmax>dxmin
        dx(ii)=min(dx(ii),dxmax);
    end

    % make sure that dx(ii)<= maxfac*dx(ii-1) or dx(ii)>= 1/maxfac*dx(ii-1)
    if ii>1
        if dx(ii)>= maxfac*dx(ii-1); dx(ii) = maxfac*dx(ii-1); end;
        if dx(ii)<= 1./maxfac*dx(ii-1); dx(ii) = 1./maxfac*dx(ii-1); end;
    end

    % compute x(ii+1)...
    ii = ii+1;
    xgr(ii) = xgr(ii-1)+dx(ii-1);
    xtemp   = min(xgr(ii),xend);
    hgr(ii) = interp1(xin,hin,xtemp);
    zgr(ii) = interp1(xin,zin,xtemp);
    xlast=xgr(ii);

end

ygr = [0:dy:2*dy]';
nx = length(xgr);
ny = length(ygr);
ygr = repmat(ygr,1,nx);
xgr = repmat(xgr,ny,1);
zgr = repmat(zgr,ny,1);

