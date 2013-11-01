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
%               g:          gravitational constant
%               relvel:     relative velocity of sediment with respect to
%                           wind speed [-]
%               bedcomposition: structure with settings for the
%                               bedcomposition module
%
%   Output:
%   result = result structure with all input variables and output
%            concentrations for transport, supply and capacity
%
%   Example
%   result = slamfat_core('wind', slamfat_wind)
%
%   See also slamfat_wind, slamfat_plot, bedcomposition

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

OPT0 = struct(                      ...
    'profile',              [],     ...
    'wind',                 [],     ... t,x
    'threshold',            4,      ... 
    'source',               [],     ... t,x,fraction
    'dx',                   1,      ...
    'dt',                   0.05,   ...
    'T',                    0.5,    ...
    'g',                    9.81,   ...
    'relvel',               1,      ...
    'bedcomposition',       struct( ...
        'enabled',          false,  ...
        'grain_size',       [],     ... fractions
        'distribution',     1,      ... fractions
        'threshold',        [],     ... fractions
        'bed_density',      1600,   ... fractions
        'grain_density',    2650,   ... fractions
        'air_density',      1.25,   ...
        'water_density',    1025,   ...
        'sediment_type',    1,      ...
        'logsigma',         1.34,   ...
        'morfac',           1,      ...
        'A',                100));

OPT = setproperty(OPT0, varargin);

if iscell(OPT.bedcomposition)
    OPT.bedcomposition = setproperty(OPT0.bedcomposition, OPT.bedcomposition);
end

OPT_BC = OPT.bedcomposition;

%% check settings

% test for stability
if OPT.dx/OPT.dt < max(OPT.wind)
    OPT.dt = OPT.dx / max(OPT.wind);
    warning('Set dt to %4.3f in order to ensure numerical stability', OPT.dt);
end

if OPT.bedcomposition.enabled
    
    % align bed composition input
    OPT_BC = align_options(OPT_BC, ...
        {'grain_size' 'distribution' 'bed_density' 'grain_density' 'sediment_type' 'logsigma'});

    if isempty(OPT_BC.threshold) && isempty(OPT_BC.grain_size)
        OPT_BC.threshold = OPT.threshold;
    end
    
    % if grain size is given, compute threshold velocities or vice versa
    if isempty(OPT_BC.threshold) && ~isempty(OPT_BC.grain_size)

        % Bagnold formulation for threshold velocity:
        %     u* = A * sqrt(((rho_p - rho_a) * g * D) / rho_p)
        OPT_BC.threshold = OPT_BC.A * sqrt(((OPT_BC.bed_density - OPT_BC.air_density) .* ...
            OPT.g .* OPT_BC.grain_size) ./ OPT_BC.bed_density);

    elseif ~isempty(OPT_BC.threshold) && isempty(OPT_BC.grain_size)
        warning('Computing grain size from threshold velocity. It is better to define the threshold velocity.')

        % Inversed Bagnold formulation for threshold velocity:
        %     D = (u* / A)^2 * rho_p / g / (rho_p - rho_a)
        OPT_BC.grain_size = (OPT_BC.threshold ./ OPT_BC.A).^2 .* OPT_BC.bed_density ./ ...
            OPT.g ./ (OPT_BC.bed_density - OPT_BC.air_density);
    end
    
    % normalize distribution
    OPT_BC.distribution = OPT_BC.distribution / sum(OPT_BC.distribution);
    
    % distribute bed composition options
    OPT.bedcomposition = OPT_BC;
    OPT.threshold      = OPT_BC.threshold;
    
    nf = length(OPT.threshold);
else
    nf = 1;
end

% if wind is not space-varying or source not space-varying, make it as such
OPT = align_options(OPT, {'wind' 'source' 'profile'});
nt  = size(OPT.wind,1);
nx  = size(OPT.source,2);

% initialize profile
if isempty(OPT.profile)
    OPT.profile = zeros(nt,nx);
end
z = OPT.profile;

% expand matrices for numerical reasons
OPT.threshold = shiftdim(repmat(OPT.threshold(:),[1 nt nx]),1);
OPT.wind      = repmat(OPT.wind,[1 1 nf]);
OPT.source    = repmat(OPT.source,[1 1 nf]);
for i = 1:nf
    OPT.source(:,:,i) = OPT.source(:,:,i) * OPT_BC.distribution(i);
end

%% initialize bed composition module

if OPT.bedcomposition.enabled
    if ~exist('bedcomposition.m','file')
        fpath = fullfile(fileparts(which(mfilename)), ...
            '../../../../programs/SandMudBedModule/02_Matlab/');
        if exist(fpath,'dir')
            warning('Added %s to path', fpath);
            addpath(fpath);
        else
            error('Bed composition module not found');
        end
    end

    fprintf('LOADED: %s\n', bedcomposition.version);

    bc = bedcomposition;

    bc.number_of_columns            = nx;
    bc.number_of_fractions          = nf;
    bc.bed_layering_type            = 2;
    bc.base_layer_updating_type     = 1;
    bc.number_of_lagrangian_layers  = 0;
    bc.number_of_eulerian_layers    = 10;
    bc.diffusion_model_type         = 0;
    bc.number_of_diffusion_values   = 5;
    bc.flufflayer_model_type        = 0;

    bc.initialize

    bc.thickness_of_transport_layer     = 0.1;
    bc.thickness_of_lagrangian_layers   = 0.1;
    bc.thickness_of_eulerian_layers     = 0.1;

    bc.fractions(                           ...
        OPT_BC.sediment_type,               ...
        OPT_BC.grain_size,                  ...
        OPT_BC.logsigma,                    ...
        OPT_BC.bed_density);
end

%% transport model

% concentration in transport
C_transport     = zeros(nt,nx,nf);
C_transport_tl  = zeros(nt,nx,nf); % transport limited
C_transport_sl  = zeros(nt,nx,nf); % supply limited

% concentration at bed
C_supply        = zeros(nt,nx,nf);
C_supply(1,:,:) = OPT.source(1,:,:);

% concentration capacity (Bagnold)
C_capacity = 1.5e-4 * ((OPT.wind - OPT.threshold).^3) ./ ...
                       (OPT.wind * OPT.relvel);
C_capacity = max(C_capacity, 0);

% supply vs. transport limited
supply_limited  = false(nt,nx,nf);

for t = 2:nt
    
    % transport limited concentration
    C_transport_tl(t,2:end,:) = ((-OPT.relvel * OPT.wind(t-1,1:end-1,:) .*              ...
        (C_transport(t-1,2:end,:) - C_transport(t-1,1:end-1,:)) / OPT.dx) * OPT.dt +    ...
         C_transport(t-1,2:end,:) + C_capacity (t-1,2:end  ,:) / (OPT.T / OPT.dt)) / (1+1/(OPT.T/OPT.dt));
    
    % supply limited concentration
    C_transport_sl(t,2:end,:) =  (-OPT.relvel * OPT.wind(t-1,1:end-1,:) .*              ...
        (C_transport(t-1,2:end,:) - C_transport(t-1,1:end-1,:)) / OPT.dx) * OPT.dt +    ...
         C_transport(t-1,2:end,:) + C_supply   (t-1,2:end  ,:) / (OPT.T/OPT.dt);
        
    % determine where transport exceeds supply
    idx = (C_capacity(t-1,:,:) - C_transport_tl(t,:,:)) / (OPT.T/OPT.dt) > C_supply(t-1,:,:);

    C_transport(t,~idx) = C_transport_tl(t,~idx);
    C_transport(t, idx) = C_transport_sl(t, idx);
   
    % compute bed level change and/or change in supply
    if OPT.bedcomposition.enabled
        mass       = zeros(nx,nf);
        mass( idx) = OPT.source(t, idx) / OPT.dx - C_supply(t-1,idx) / (OPT.T/OPT.dt);
        mass(~idx) = OPT.source(t,~idx) / OPT.dx - (C_capacity(t-1,~idx) - C_transport(t,~idx)) / (OPT.T/OPT.dt);
        
        dz = bc.deposit(mass', OPT.dt, OPT_BC.grain_density, zeros(size(mass')), OPT_BC.morfac);
        z(t,:) = z(t-1,:) + dz;
        
        C_supply(t,:,:) = squeeze(bc.layer_mass(:,1,:))';
    else
        C_supply(t, idx)    = C_supply(t-1, idx) + OPT.source(t, idx) / OPT.dx - ...
            C_supply(t-1,idx) / (OPT.T/OPT.dt);
        C_supply(t,~idx)    = C_supply(t-1,~idx) + OPT.source(t,~idx) / OPT.dx - ...
            (C_capacity(t-1,~idx) - C_transport(t,~idx)) / (OPT.T/OPT.dt);
    end

    supply_limited(t,:,:) = idx;
end

%% output

result = struct( ...
    'input', OPT,               ...
    'dimensions', struct(       ...
        'time',         nt,     ...
        'space',        nx,     ...
        'fractions',    nf),    ...
    'output',   struct(         ...
        'supply_limited',   supply_limited, ...
        'transport',        C_transport,    ...
        'supply',           C_supply,       ...
        'capacity',         C_capacity,     ...
        'profile',          z));

if OPT.bedcomposition.enabled
    bc.delete();
end

end

function OPT = align_options(OPT, fields)
    sizes = cell(size(fields));
    for i = 1:length(fields)
        if isfield(OPT, fields{i})
            sizes{i} = size(OPT.(fields{i}));
        end
    end
    
    ndims = max(cellfun(@length, sizes));
    
    for i = 1:length(fields)
        d = ndims - length(sizes{i});
        if d > 0
            sizes{i} = [sizes{i} ones(1,d)];
        end
    end
    
    sizes = reshape([sizes{:}],ndims,length(sizes))';
    
    for i = 1:length(fields)
        for j = 1:ndims
            n = max([1 min(sizes(sizes(:,j)>1,j))]);
            if n ~= sizes(i,j)
                if sizes(i,j) == 1
                    new_dims    = ones(1,ndims);
                    new_dims(j) = n;
                    OPT.(fields{i}) = repmat(OPT.(fields{i}),new_dims);
                elseif sizes(i,j) > 1
                    warning('Truncating dimension %d of %s to match other input', j, fields{i});
                    new_dims    = repmat({':'},1,ndims);
                    new_dims{j} = 1:n;
                    OPT.(fields{i}) = OPT.(fields{i})(new_dims{:});
                end
            end
        end
    end
end
