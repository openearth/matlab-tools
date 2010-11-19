function [xgr ygr zgr] = xb_1D_grid(zin, xin, varargin)
%PROFILEGEN  Creates 1D model grid.
%
% Function to interpolate (no extrapolation) profile measurements to cross
% shore consant or varying grid for an XBeach profile model. Cross shore grid size is
% limited by user-defined minimum grid size in shallow water and land, long
% wave resolution on offshore boundary, depth to grid size ratio and grid size
% smoothness constraints. The function uses the Courant condition to find the 
% optimal grid size given these constraints.
%
%   Syntax:
%   [xgr ygr zgr] = profilegen(zin, xin, dy, Tm, dxmin)
%
%   Input:
%   zin   = vector with bed levels; positive up
%   xin   = vector with cross-shoe coordinates; increasing from zero
%   towards shore
%
%   Output:
%   xgr   = x-grid coordinates [3,nx+1]
%   ygr   = y-grid coordinates [3,nx+1]
%   zgr   = bed elevations [3,nx+1]
%
%   Example
%   [xgr ygr zgr] = xb_1D_grid(0.1*[0:1:200]-15, [0:1:200]);
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       Robert McCall / Jaap van Thiel de Vries
%
%       robert.mccall@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 19 Nov 2010
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% settings

% defaults
OPT = struct(...
    'Tm',5,...             % incident short wave period (used for maximum grid size at offshore boundary) if you impose time series of wave conditions use the min(Tm) as input
    'dxmin',1,...          % minimum required cross shore grid size (usually over land)  
    'vardx',1,...          % 0 = constant dx, 1 = varying dx    
    'g', 9.81,...          % gravity constant
    'CFL', 0.9,...         % Courant number
    'dtref', 4,...         % Ref value for dt in computing dx from CFL
    'maxfac', 1.5,...      % Maximum allowed grid size ratio
    'dy', 5,...            % dy
    'wl',0,...             % Water level elevation used to estimate water depth
    'depthfac', 2 ...      % Maximum gridsize to depth ratio
     );

% overrule default settings by propertyName-propertyValue pairs, given in varargin
OPT = setproperty(OPT, varargin{:});

%% prepare
k       = xb_disper(2*pi/OPT.Tm, -zin(1), OPT.g);
Llong   = 7*2*pi/k;
x       = xin;
hin     = max(OPT.wl-zin,0.01);

%% set boundaries
xend    = x(end);
xstart  = x(1);
xlast   = xstart;

%% grid settings

ii = 1;
xgr(ii) = xstart;
hgr(ii) = hin(1);
while xlast<xend

    % compute dx; minimum value dx (on dry land) = dxmin
    dxmax = Llong/12;
    % dxmax = sqrt(g*hgr(min(ii)))*Tlong_min/12;
    dx(ii) = sqrt(OPT.g*hgr(ii))*OPT.dtref/OPT.CFL;
    dx(ii) = min(dx(ii),OPT.depthfac*hgr(ii));
    dx(ii) = max(dx(ii),OPT.dxmin);
    if dxmax>OPT.dxmin
        dx(ii)=min(dx(ii),dxmax);
    end

    % make sure that dx(ii)<= maxfac*dx(ii-1) or dx(ii)>= 1/maxfac*dx(ii-1)
    if ii>1
        if dx(ii)>= OPT.maxfac*dx(ii-1); dx(ii) = OPT.maxfac*dx(ii-1); end;
        if dx(ii)<= 1./OPT.maxfac*dx(ii-1); dx(ii) = 1./OPT.maxfac*dx(ii-1); end;
    end

    % compute x(ii+1)...
    ii = ii+1;
    xgr(ii) = xgr(ii-1)+dx(ii-1);
    xtemp   = min(xgr(ii),xend);
    hgr(ii) = interp1(xin,hin,xtemp);
    zgr(ii) = interp1(xin,zin,xtemp);
    xlast=xgr(ii);

end

zgr(:,1) = zgr(:,2);

ygr = [0:OPT.dy:2*OPT.dy]';
nx = length(xgr);
ny = length(ygr);
ygr = repmat(ygr,1,nx);
xgr = repmat(xgr,ny,1);
zgr = repmat(zgr,ny,1);
