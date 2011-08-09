function [G, F, C]=input(G,varargin)
%DELFT3D_KELVIN_WAVE.INPUT  MAIN INPUT specification of delft3d_kelvin_wave_*
%
% [G, F, C] = delft3d_kelvin_wave_input(G)
%
% with grid G (input)
%       cor.x:
%       cor.y:
%           D:
%       angle: 
%       base.x:
%      base.y:
%
% and grid G (added to G for as output)
%       cen.x:
%       cen.y:
%     coast.x: corners of delftd grid padded with dummy row/col
%     coast.y:
%
% with forcing F (as input fields)
%       alpha:
%        eta0:
%           T:
%
% and with constants C
%         lat:
%   eta_irreg:     
% labda_irreg:   
%           g:
%
%See also: delft3d_kelvin_wave

%% transform co-ordinates to describe a coastally trapped wave
%  with G.x_coast crossshore and 
%       G.y_coast alongshore.

   if ~isfield(G,'cord')
      [G.cord.x]          = addrowcol(G.cor.x,1,1,0);
      [G.cord.y]          = addrowcol(G.cor.y,1,1,0);
   end  

   if ~isfield(G,'cend')
      [G.cend.x]          = center2corner(G.cor.x);
      [G.cend.y]          = center2corner(G.cor.y);
   end  

   [G.coast.x, G.coast.y] = rotatevector((G.cord.x-G.base.x),...
                                         (G.cord.y-G.base.y),...
                                          G.angle);

   C.g             = 9.81;                   % [m/s^2] gravity
   C.Td            = 24*60*60;               % [s]     length of a day

%% GRID and BATHYMETRY

   F.alpha         = 0;                      % [rad] initial phase at t=0

   % spring-neap
   F.eta0          = [0.25     1.25        ];% [m] tidal amplitude in south-east
   C.Tt            = [12*3600 (12*60+25)*60];% [s] tidal period

   F.eta0          = [0.5      1.0         ];% [m] tidal amplitude in south-east
   C.Tt            = [12*3600 (12*60+40)*60];% [s] tidal period

   % spring or neap
   F.eta0          = [0.90   ];  % [m] spring M2 S2 HvH tidal amplitude in south-east
   F.eta0          = [0.60   ];  % [m] neap   M2 S2 HvH tidal amplitude in south-east
   F.eta0          = [0.75   ];  % [m] neap   HvH tidal amplitude in south-east
   C.Tt            = [12*3600];  % [s] S2 tidal period

   F.eta0          = [0.25 1.00];% [m] HvH tidal amplitudes in south-east
   F.eta0          = [1.5    ];  % [m] higher then spring HvH tidal amplitude in south-east
   F.eta0          = [1.0    ];  % [m] mean semi-diurnal HvH tidal amplitude in south-east
   F.eta0          = [0.5    ];  % [m] lower then neap   HvH tidal amplitude in south-east
   F.eta0          = [0.75   ];  % [m] neap   HvH tidal amplitude in south-east
   F.eta0          = [1.25   ];  % [m] spring HvH tidal amplitude in south-east
   C.Tt            = [12*3600];  % [s] S2 tidal period

%% General calculations

   C.omega         = 2*pi/C.Td;              % [rad]     angular velocity of the earth
   C.w             = 2*pi./C.Tt;             % [1/s]     angular frequency of the tide
   C.c0            = sqrt(C.g*G.D0);         % [m/s]     initial velocity of tidal wave
   C.k0            = C.w/C.c0;               % [1/m]     initial wave number of tidal wave, no friction
   C.L0            = C.c0*C.Tt;              % [m]       initial wave length
   C.lat           = 52.5;                   % [degrees] latitude (updated may 25th 2005)

   C.phi           = deg2rad(C.lat);         % [radians] latitude (updated may 25th 2005)
   C.f             = 2*C.omega*sin(C.phi);   % [rad/s]   Coriolis parameter

   C.eta_irreg     = 1.0;                    % [m] height of bottom irregularities
   C.labda_irreg   = 200;                    % [m] distance between bottom irregularities

%% Friction

   C.Ks            = (25*(C.eta_irreg)^2)/C.labda_irreg; % [m]       ripple geometry Swart
   C.Z0            = C.Ks/30;                            % [m]       relative thickness of the bed layer
   C.Chezy2D       = 18*log10((12*G.D0)/C.Ks);           % [m^0.5/s] Chezy coefficient
   C.Cf            = C.g/C.Chezy2D^2;                    % [-]       friction parameter
   C.n2D           = (G.D0).^(1/6)./C.Chezy2D;           % [-]       Manning parameter

