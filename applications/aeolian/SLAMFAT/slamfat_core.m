function result = slamfat_core(varargin)
%SLAMFAT_CORE  Supply Limited Advection Model For Aeolian Transport (SLAMFAT)
%
%   Supply Limited Advection Model For Aeolian Transport (SLAMFAT). This
%   conceptual advection model is a tool to study Aeolian transport
%   situations in supply limited situations, e.g. coastal environments. It
%   is based on a Bagnold (1954) power law for Aeolian transport, extended
%   with a formulation for supply of sediment from the bed.
%
%   The model basics are described in "Physics of Blown Sand and Coastal
%   Dunes", the PhD thesis by De Vries (2013).
%   http://dx.doi.org/10.4233/uuid:9a701423-8559-4a44-be5d-370d292b0df3
%
%   Syntax:
%   result = slamfat_core(varargin)
%
%   Input:
%   varargin  = profile:    beach profile [m]
%               wind:       wind time series matrix size=(nt,nx) [m/s]
%               threshold:  threshold velocity for Aeolian transport per
%                           sediment fraction [m/s]
%               source:     sediment source from the bed size=(nt,nx)
%                           [kg/m2]
%               dx:         spatial step size in input and output [m]
%               dt:         temporal step size in input and output [s]
%               T:          adaptation time scale [s]
%               relvel:     relative velocity of sediment with respect to
%                           wind speed [-]
%
%   Output:
%   result = result structure with all input variables and output
%            concentrations for transport, supply and capacity
%
%   Example
%   result = slamfat_core('wind', slamfat_wind)
%
%   See also slamfat_wind, slamfat_plot

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 25 Oct 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read settings

OPT = struct(               ...
    'profile',      [],     ...
    'wind',         [],     ... t,x
    'threshold',    4,      ... fraction
    'source',       [],     ... t,x,depth,fraction
    'dx',           1,      ...
    'dt',           0.05,   ...
    'T',            0.5,    ...
    'relvel',       1);

OPT = setproperty(OPT, varargin);

% test for stability
if OPT.dx/OPT.dt < max(OPT.wind)
    OPT.dt = OPT.dx / max(OPT.wind);
    warning('Set dt to %4.3f in order to ensure numerical stability', OPT.dt);
end

% if wind is not space-varying or source not space-varying, make it as such
if isvector(OPT.wind)
    nt = length(OPT.wind);
    if isvector(OPT.source)
        nx = length(OPT.source);
        OPT.source = repmat(OPT.source(:)', nt, 1);
    else
        nx = size(OPT.source,2);
    end
    OPT.wind = repmat(OPT.wind(:), 1, nx);
else
    nt = size(OPT.wind,1);
    if isvector(OPT.source)
        nx = length(OPT.source);
        OPT.source = repmat(OPT.source(:)', nt, 1);
    else
        nx = size(OPT.source,2);
    end
end

%% model

% concentration in transport
C_transport     = zeros(size(OPT.source));
C_transport_tl  = zeros(size(OPT.source)); % transport limited
C_transport_sl  = zeros(size(OPT.source)); % supply limited

% concentration at bed
C_supply      = zeros(size(OPT.source));
C_supply(1,:) = OPT.source(1,:);

% concentration capacity (Bagnold)
C_capacity = 1.5e-4 * ((OPT.wind - OPT.threshold).^3) ./ ...
                       (OPT.wind * OPT.relvel);
C_capacity = max(C_capacity, 0);

% supply vs. transport limited
supply_limited  = false(size(OPT.source));

for t = 2:nt
    
    % transport limited concentration
    C_transport_tl(t,2:end) = ((-OPT.relvel * OPT.wind(t-1,1:end-1) .*              ...
        (C_transport(t-1,2:end) - C_transport(t-1,1:end-1)) / OPT.dx) * OPT.dt +    ...
         C_transport(t-1,2:end) + C_capacity (t-1,2:end  ) / (OPT.T / OPT.dt)) / (1+1/(OPT.T/OPT.dt));
    
    % supply limited concentration
    C_transport_sl(t,2:end) =  (-OPT.relvel * OPT.wind(t-1,1:end-1) .*              ...
        (C_transport(t-1,2:end) - C_transport(t-1,1:end-1)) / OPT.dx) * OPT.dt +    ...
         C_transport(t-1,2:end) + C_supply   (t-1,2:end  ) / (OPT.T/OPT.dt);
        
    % determine where transport exceeds supply
    idx = (C_capacity(t-1,:) - C_transport_tl(t,:)) / (OPT.T/OPT.dt) > C_supply(t-1,:);

    C_transport(t,~idx) = C_transport_tl(t,~idx);
    C_transport(t, idx) = C_transport_sl(t, idx);
   
    C_supply(t, idx)    = C_supply(t-1, idx) + OPT.source(t, idx) / OPT.dx - ...
        C_supply(t-1,idx) / (OPT.T/OPT.dt);
    C_supply(t,~idx)    = C_supply(t-1,~idx) + OPT.source(t,~idx) / OPT.dx - ...
        (C_capacity(t-1,~idx) - C_transport(t,~idx)) / (OPT.T/OPT.dt);

    supply_limited(t,:) = idx;
end

%% output

result = struct( ...
    'input',    OPT, ...
    'output',   struct( ...
        'nt',               nt, ...
        'nx',               nx, ...
        'supply_limited',   supply_limited, ...
        'transport',        C_transport, ...
        'supply',           C_supply, ...
        'capacity',         C_capacity));
