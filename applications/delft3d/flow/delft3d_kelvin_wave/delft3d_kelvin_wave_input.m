function [G, F, C]=delft3d_kelvin_wave_input(G,varargin)
%DELFT3D_KELVIN_WAVE_INPUT  MAIN INPUT specification of delft3d_kelvin_wave_*
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
   C.Td            = 24*60*60;               % [s] length of a day

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
   F.eta0          = [1.25   ];  % [m] spring HvH tidal amplitude in south-east
   F.eta0          = [0.75   ];  % [m] neap   HvH tidal amplitude in south-east
   C.Tt            = [12*3600];  % [s] S2 tidal period

%% General calculations

   C.omega         = 2*pi/C.Td;              % [rad] angular velocity of the earth
   C.w             = 2*pi./C.Tt;             % [1/s] angular frequency of the tide
   C.c0            = sqrt(C.g*G.D0);         % [m/s] initial velocity of tidal wave
   C.k0            = C.w/C.c0;               % [1/m] initial wave number of tidal wave, no friction
   C.L0            = C.c0*C.Tt;              % [m] initial wave length

   C.phi           = deg2rad(52.5);          % [degrees] latitude (updated may 25th 2005)
   C.f             = 2*C.omega*sin(C.phi);   % [rad/s] Coriolis parameter

   C.eta_irreg     = 1.0;                    % [m]height of bottom irregularities
   C.labda_irreg   = 200;                    % [m]distance between bottom irregularities

%% Friction

   C.Ks            = (25*(C.eta_irreg)^2)/C.labda_irreg; % [m] ripple geometry Swart
   C.Z0            = C.Ks/30;                            % [m] relative thickness of the bed layer
   C.Chezy2D       = 18*log10((12*G.D0)/C.Ks);           % [m^0.5/s] Chezy coefficient
   C.Cf            = C.g/C.Chezy2D^2;                    % [-] friction parameter
   C.n2D           = (G.D0).^(1/6)./C.Chezy2D;           % [-] Manning parameter

%% ----------------------------------

function [U1, V1] = rotatevector(u0,v0,a);
%ROTATEVECTOR   Rotate vectors to other coordinate system.
%
%  [U2 V2] = rotatevector (u1,v1,angle)
%
%  Maps vector (u0,v0) given in one cartesian grid 1
%  onto vector (U1,V1) in cartesian grid 2,which is 
%  rotated over angle a with respect to the cartesian
%  grid 1 (angle positive anti-clockwise).
%  u0,v0 should have the same size. 'a' can either
%  be a scalar or have the same size as (u0,v0). Likewise
%  (u0,v0) can be a scaler and a can be an array.
%
%         Y0
%         ^
%         |      X1
%  Y1     |     /   
%     \   |   / \ a = angle (positive anit-clockwise)
%       \ | /    |
% --------+------------------> X0
%        /|\
%      /  |  \
%    /    |    \
%
%  N.B. angle given in radians
%       for degrees: angle*pi/180
%
%  Method:
%  ____        ____
%  Unew =  M * uold;
% 
%
% | U2 |  =  | cos(angle)   - sin(angle) |   | u1 |;
% |    |     |                           | * |    |
% | V2 |  =  | sin(angle)   + cos(angle) |   | v1 |; 
%

%13-9-2004

method = 1;

%if method==1

   U1 = cos(a) .* u0 - sin(a) .* v0;
   V1 = sin(a) .* u0 + cos(a) .* v0;

%elseif method==2

   % slower
   %tic
   %[TH0,R0] = cart2pol(u0,v0);
   % TH1     = + a + TH0 ;
   %[U1 ,V1] = pol2cart(TH1,R0)
   %toc

%elseif method==2

   %% Method below is almost 2 times as slow
   %% - - - - - - - - - - - - - - - - - - - 
   %tic
   %M   = [cos(a),  - sin(a) 
   %       sin(a),  + cos(a)]
   %       
   %UV1 = M*[u0(:) v0(:)];
   %U1  = UV1(1,:)
   %V1  = UV1(2,:)
   %toc

%end
%% EOF
