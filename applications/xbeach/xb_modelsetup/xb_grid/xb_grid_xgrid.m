function [xgr zgr] = xb_grid_xgrid(xin, zin, varargin)
%XB_GRID_XGRID  Creates a model grid in x-direction based on bathymetry
%
%   Function to interpolate (no extrapolation) profile measurements to
%   cross shore consant or varying grid for an XBeach profile model. Cross
%   shore grid size is limited by user-defined minimum grid size in shallow
%   water and land, long wave resolution on offshore boundary, depth to
%   grid size ratio and grid size smoothness constraints. The function uses
%   the Courant condition to find the optimal grid size given these
%   constraints.
%
%   Syntax:
%   [xgr zgr] = xb_grid_xgrid(xin, zin, varargin)
%
%   Input:
%   xin   = vector with cross-shore coordinates; increasing from zero
%   towards shore
%   zin   = vector with bed levels; positive up
% 
%   Optional input in keyword,value pairs
%     - xgrid    :: [m] vector which defines the variable xgrid
%     - Tm       :: [s] incident short wave period (used for maximum grid size at offshore boundary) 
%                       if you impose time series of wave conditions use the min(Tm) as input (default = 5)
%     - dxmin    :: [m] minimum required cross shore grid size (usually over land) (default = 1)
%     - dxmax    :: [m] user-specified maximum grid size, when usual wave
%                       period / CFL condition does not suffice (default Inf)
%     - vardx    :: [-] 0 = constant dx, 1 = varying dx (default = 1)
%     - g        :: [ms^-2] gravity constant (default = 9.81)
%     - CFL      :: [-] Courant number in grid generator (default = 0.9)
%     - dtref    :: [-] Ref value for dt in computing dx from CFL (default = 4)
%     - maxfac   :: [-] Maximum allowed grid size ratio between adjacent cells (default = 1.15)
%     - dy, 5    :: [m] dy (default = 5)
%     - wl,0     :: [m] water level elevation relative to bathymetry used to estimate water depth (default = 0)
%     - ppwl     :: [-] numer of points per wave length
%     - depthfac :: [-] Maximum gridsize to water depth ratio (default = 2)
%     - nonh     :: [-] Switch option for generation of non-hydrostatic
%                       model grid
%     - dxdry    :: [m] grid size for dry points
%     - zdry     :: [m] elevation above which points are dry 
%     - xdry     :: [m] cross-shore distance from which points are dry
%
%   Output:
%   xgr   = x-grid coordinates
%   zgr   = bed elevations
%
%   Example
%   [xgr zgr] = xb_grid_xgrid([0:1:200], 0.1*[0:1:200]-15);
%
%   See also xb_generate_grid, xb_grid_ygrid

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Robert McCall / Jaap van Thiel de Vries
%
%       robert.mccall@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 01 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% settings

% defaults
OPT = struct(...
    'xgrid', [],...        % predefined xgrid vector
    'Tm',5,...             % incident short wave period (used for maximum grid size at offshore boundary) if you impose time series of wave conditions use the min(Tm) as input
    'dxmin',2,...          % minimum required cross shore grid size (usually over land)
    'dxmax',Inf,...        % user-specified maximum grid size, when usual wave period / CFL condition does not suffice
    'vardx',1,...          % 0 = constant dx, 1 = varying dx
    'g', 9.81,...          % gravity constant
    'CFL', 0.9,...         % Courant number
    'dtref', 4,...         % Ref value for dt in computing dx from CFL
    'maxfac', 1.15,...     % Maximum allowed grid size ratio
    'wl',0,...             % Water level elevation used to estimate water depth
    'depthfac', 2, ...     % Maximum gridsize to depth ratio
    'ppwl', 12 ,...        % desired points per wavelength
    'nonh', false, ...     % setting grid to solve individual short waves instead of infragravity waves
    'dxdry', [], ...       % grid size to use for dry cells
    'zdry', [],...         % vertical level above which cells should be considered dry
    'xdry', []...          % horizontal (cross-shore) level from which cells should be considered dry
    );

% overrule default settings by propertyName-propertyValue pairs, given in varargin
OPT = setproperty(OPT, varargin{:});
if isempty(OPT.dxdry)
    OPT.dxdry = OPT.dxmin;
end
if isempty(OPT.zdry)
    OPT.zdry = OPT.wl;
end

%% make grid
% fix if z-values contain NaN's
xin = xin(~isnan(zin));
zin = zin(~isnan(zin));

% set boundaries
xend    = xin(end);
xstart  = xin(1);
xlast   = xstart;

if OPT.vardx == 0
    
    % constant dx
    xgr = (xin(1):OPT.dxmin:xin(end));
    zgr = interp1(xin, zin, xgr);
    
    xb_verbose(1,'Create equidistant cross-shore grid');
    xb_verbose(2,'Grid size',dxmin);
    
elseif OPT.vardx == 1 && ~isempty(OPT.xgrid)
    
    % predefined xgrid
    xgr = OPT.xgrid;
    zgr = interp1(xin, zin, xgr);
    
    xb_verbose(1,'Use pre-defined cross-shore grid');
    
elseif OPT.vardx == 1
    
    % prepare
    hin      = max(OPT.wl-zin,0.01);
    %k       = disper(2*pi/OPT.Tm, hin(1), OPT.g);
    if OPT.nonh
    	k       = disper(2*pi/OPT.Tm, hin(1), OPT.g);
        %Llong = 2*pi/k;
    else
        %Llong   = 4*2*pi/k;
        k       = disper(2*pi/(OPT.Tm*4), hin(1), OPT.g);% assume Tlong = 4 * Tshort, instead of Llong = 4*Lshort
    end
    Llong = 2*pi/k;
    x       = xin;
        
    % grid settings
    ii = 1;
    xgr(ii) = xstart;
    zgr(ii) = zin(1);
    hgr(ii) = hin(1);
    while xlast < xend
        
        % what is the minimum grid size in this area
        if ~isempty(OPT.xdry)
            drycell = xgr(ii)>OPT.xdry;
        else
            drycell = zgr(ii)>OPT.zdry;
        end
        if drycell
            localmin = OPT.dxdry;
        else
            localmin = OPT.dxmin;
        end
        
        % compute dx; minimum value dx (on dry land) = dxmin
        dxmax = Llong/OPT.ppwl;
        dxmax = min(dxmax,OPT.dxmax);
        % dxmax = sqrt(g*hgr(min(ii)))*Tlong_min/12;
        dx(ii) = sqrt(OPT.g*hgr(ii))*OPT.dtref/OPT.CFL;
        dx(ii) = min(dx(ii),OPT.depthfac*hgr(ii));
        dx(ii) = max(dx(ii),localmin);
        if dxmax > localmin
            dx(ii) = min(dx(ii),dxmax);
        end
        
        % make sure that dx(ii)<= maxfac*dx(ii-1) or dx(ii)>= 1/maxfac*dx(ii-1)
        if ii>1
            if dx(ii) >= OPT.maxfac*dx(ii-1); dx(ii) = OPT.maxfac*dx(ii-1); end;
            if dx(ii) <= 1./OPT.maxfac*dx(ii-1); dx(ii) = 1./OPT.maxfac*dx(ii-1); end;
        end
        
        % compute x(ii+1)...
        ii = ii+1;
        xgr(ii) = xgr(ii-1)+dx(ii-1);
        xtemp   = min(xgr(ii),xend);
        hgr(ii) = interp1(xin,hin,xtemp);
        zgr(ii) = interp1(xin,zin,xtemp);
        xlast=xgr(ii);
    end
    
    xb_verbose(1,'Optimize cross-shore grid using CFL condition');
    
else
    error('Nope, this is not going to work; vardx = [0 1]');
end

% chop off last grid cell, if limit is exceeded
if xlast > xend
    xgr = xgr(1:end-1);
    zgr = zgr(1:end-1);
end

xb_verbose(2,'Grid cells',length(xgr));