%close all; clear all; clc;
close all; clear w; clear s;

w = slamfat_wind;
%s = slamfat('wind',w,'profile',linspace(0,1,100),'animate',true);
s = slamfat('wind',w,'profile',zeros(1,100),'animate',true);


source = zeros(length(s.profile),1);
source(1:20) = 1.5e-4 * w.dt * s.dx;

s.bedcomposition.enabled            = true;
s.bedcomposition.source             = source;
%s.bedcomposition.initial_deposit    = .01;
%s.bedcomposition.layer_thickness    = 5e-4;
%s.bedcomposition.number_of_layers   = 5;
%s.bedcomposition.grain_size         = [1.18 0.6 0.425 0.3 0.212 0.15 0.063]*1e-3;
%s.bedcomposition.distribution       = [0.63 0.94 6.80 51.35 30.73 8.07 1.43];

%s.max_threshold.time = [0 3600];
%s.max_threshold.tide = [0 .5];

%s.max_source    = 'initial_profile';

s.run;

%% Aeolian Sand and Sand Dunes By Kenneth Pye, Haim Tsoar

% threshold velocity (Bagnold, 1941)
% u_t = A * sqrt((rho_p - rho_a) * g * D / rho_p)
%
% A     = constant [0.08 - 0.10]
% rho_p = grain density [kg/m^3]
% rho_a = air density [kg/m^3]
% g     = gravitational acceleration [m/s^2]
% D     = grain diameter [m]

% bed slope (Howard, 1977)
% u_ts = F^2 * D * [sqrt(tan(psi)^2 * cos(phi)^2 - sin(ksi)^2 * sin(phi)^2) - cos(ksi) * sin(phi)]
%
% F     = beta * sqrt((rho_p - rho_a) * g / rho_p)
% beta  = constant [0.31]
% psi   = angle of internal friction [-]
% phi   = bed slope [-]
% ksi   = angle between local wind direction and maximum bed slope direction [-]

% bed slope (Howard, 1978)
% u_ts = E * (F/k) * sqrt(D) * [sqrt(tan(psi)^2 * cos(phi)^2 - sin(ksi)^2 * sin(phi)^2) - cos(ksi) * sin(phi)]
%
% E     = constant [-]
% k     = von Karman constant [0.4]

% bed slope (Dyer, 1986)
% u_ts = sqrt(tan(psi) - tan(phi)/tan(psi) - cos(phi))

% surface moisture (Belly, 1964 and Johnson, 1965)
% u_tw = u_t * (1.8 + 0.6 * log(W))
%
% W     = moisture content percentage [0.05% - 4%]

% surface moisture (Hotta et al, 1985) 0.2 - 0.8 mm grain size
% u_tw = u_t + 7.5*W*I_w
%
% I_w   = function for evaporation rate [0 - 1]

% salt crusts (Nickling and Ecclestone, 1981)
% u_t = A * (0.95 * exp(0.1031 * S)) * sqrt((rho_p - rho_a) * g * D / rho_p)
%
% S     = salt content [mg/g]

% evaporation (Penman, 1984 and Shuttleworth, 1993)
% E_m = (m * R_n + gamma * 6.43 * (1 + 0.536 * U_2) * delta) / (lamda_v * (m + gamma))
%
% E_m      = evaporation rate [mm/day]
% m        = slope of the vaporation pressure curve [kPa/K]
% R_n      = net irradiance [MJ/m^2/day]
% gamma    = (0.0016286 * P) / lambda_v = psychrometric constant [kPa/K]
% U_2      = wind speed [m/s]
% delta    = vapor pressure deficit [kPa]
% lambda_v = latent heat of vaporation [MJ/kg]