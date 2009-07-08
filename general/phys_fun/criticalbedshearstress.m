function [ThetaCrZanke, ThetaCrBrownlie, ThetaCrVanRijn, Ddim] = criticalbedshearstress(D,rhos,rhow)
%CRITICALBEDSHEARSTRESS computes the critical Shields parameter for diameter D (m)
%
%   [ThetaCrZanke, ThetaCrBrownlie, ThetaCrVanRijn, Ddim] = criticalbedshearstress(D,rhos,rhow)
%
%   Input:
%       D  =  grain diameter (m)
%       rhos = sediment density (kg/m^3)
%       rhow = water density (kg/m^3)
%
%   Output:
%       ThetaCrZanke = nondimensional bed shear stress following Zanke (2003)
%       ThetaCrBrownlie = nondimensional bed shear stress following Brownlie (1981)
%       ThetaCrZanke = nondimensional bed shear stress following Van Rijn (1993)
%       Ddim = Bonnefille dimensionless grain size
%
%   Example
%       D = 0.020;
%       rhos = 2650;
%       rhow = 1000;
%       [ThetaCrZanke, ThetaCrBrownlie, ThetaCrVanRijn, Ddim] =  criticalbedshearstress(D,rhos,rhow)
%
%
%   for the dimensional critical shear stress:
%       TauCr = ThetaCr.* (g .* (rhos - rhow) .* D50)
%   
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Alkyon Hydraulic Consultancy & Research
%       Bart Grasmeijer
%
%       grasmeijer@alkyon.nl
%
%       P.O. Box 248, 8300 AE Emmeloord, The Netherlands
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

% Created: 03 Apr 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%

%constants
s = rhos/rhow;                                                                  % relative density
g = 9.81;                                                                       % gravitational acceleration
salinity = 35;
temperature = 10;
nu = kinviscwater(salinity,temperature);                                        % kinematic viscosity of seawater

%parameters
Ddim=D.*((s-1).*g./nu.^2).^(1/3);                                               % Bonnefille dimensionless grain size

%computation
%ThetaCrZanke = (0.145.*Ddim.^(-1/2) + 0.045*10.^(-1100.*Ddim.^(-9/4)));
ThetaCrZanke = 0.5.*(0.145.*Ddim.^(-1/2) + 0.045*10.^(-1100.*Ddim.^(-9/4)));
%correction Parker: 0.5, then remove 0.5 in pe.m (Parker-Einstein bedload)

% This is the critical bed shear stress from Brownlie (1981), also referred
% to in 'The Civil Engineering Handbook' from Chen (1995)
ReGrain = sqrt(9.81 .* (s - 1) .* D.^3) ./ nu;
Y = ReGrain.^(-0.6);
ThetaCrBrownlie = 0.22 .* Y + 0.06 .* 10.^(-7.7 .* Y);

% The critical bed shear stress by Van Rijn (1993) looks very much like the
% one from Brownlie (1981)
ThetaCrVanRijn = NaN(size(D));
i = find(Ddim > 1 & Ddim <= 4);
ThetaCrVanRijn(i) = 0.24.*Ddim(i).^-1;
i = find(Ddim > 4 & Ddim <= 10);
ThetaCrVanRijn(i) = 0.14.*Ddim(i).^-0.64;
i = find(Ddim > 10 & Ddim <= 20);
ThetaCrVanRijn(i) = 0.04.*Ddim(i).^-0.1;
i = find(Ddim > 20 & Ddim <= 150);
ThetaCrVanRijn(i) = 0.013.*Ddim(i).^0.29;
i = find(Ddim > 150);
ThetaCrVanRijn(i) = 0.055;
