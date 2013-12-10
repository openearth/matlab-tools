%% basic

close all; clear classes; clear w; clear s;

n = 90;
profile        = zeros(1,100);
profile(1:n)   = linspace(-1,1,n);
profile(n:end) = linspace(1,15,100-n+1);

w = slamfat_wind('duration',3600);
s = slamfat('wind',w,'profile',profile,'animate',false,'progress',false);

source = zeros(length(s.profile),1);
source(1:20) = 1.5e-3 * w.dt * s.dx;

s.bedcomposition = slamfat_bedcomposition_basic;
s.bedcomposition.source             = source;
s.bedcomposition.grain_size         = .3*1e-3;

s.max_threshold = slamfat_threshold_basic;
s.max_threshold.time = 0:3600;

s.run;
s.show_performance;

%% advanced

close all; clear classes; clear w; clear s;

n = 90;
profile        = zeros(1,100);
profile(1:n)   = linspace(-1,1,n);
profile(n:end) = linspace(1,15,100-n+1);

w = slamfat_wind('duration',600);
s = slamfat('wind',w,'profile',profile,'animate',false,'output_file','slamfat.nc');

source = zeros(length(s.profile),1);
source(1:100) = 1.5e-2 * w.dt * s.dx;

s.bedcomposition = slamfat_bedcomposition;
s.bedcomposition.source             = source;
s.bedcomposition.layer_thickness    = 5e-4;
s.bedcomposition.number_of_layers   = 3;
s.bedcomposition.grain_size         = [1.18 0.6 0.425 0.3 0.212 0.15 0.063]*1e-3;
s.bedcomposition.distribution       = [0.63 0.94 6.80 51.35 30.73 8.07 1.43];

s.max_threshold = slamfat_threshold;
s.max_threshold.time = 0:3600;
s.max_threshold.tide = 0.25 * sin(s.max_threshold.time * 2 * pi / 600);
s.max_threshold.solar_radiation = 1e4;

s.max_source    = 'initial_profile';

s.run;
s.show_performance;

%% knmi and waterbase data



%% async

close all; clear classes; clear w; clear s;

n = 90;
profile        = zeros(1,100);
profile(1:n)   = linspace(-1,1,n);
profile(n:end) = linspace(1,15,100-n+1);

duration = 60 * ones(1,60);
velocity = 4+4*sin((cumsum(duration)-30)/600*2*pi);
velstd   = 0;
w = slamfat_wind('duration',duration,'velocity_mean',velocity,'velocity_std',velstd);

%%

phi = linspace(-pi,pi,21);
A   = [3 4 5]; %2:6; %0:2:8;

for j = 1:length(A)
    for i = 1:length(phi)
        fname = sprintf('s_phi%3.2f_A%d.mat',phi(i),A(j));
        
        if ~exist(fullfile(pwd,fname),'file')
    
            disp(fname);
            
            clear s;
            s = slamfat('wind',w,'profile',profile,'animate',false,'progress',false);

            source = zeros(length(s.profile),1);
            source(1:20) = 1.5e-4 * w.dt * s.dx;

            s.bedcomposition = slamfat_bedcomposition_basic;
            s.bedcomposition.source             = source;
            s.bedcomposition.grain_size         = .3*1e-3;

            s.max_threshold = slamfat_threshold_basic;
            s.max_threshold.time      = 0:3600;
            s.max_threshold.threshold = A(j)*sin(s.max_threshold.time/600*2*pi + phi(i));

            s.run;

            save(fname,'s');
        end
    end
end

%% T=0

phi = linspace(-pi,pi,21);
A   = 3;

for j = 1:length(A)
    for i = 1:length(phi)
        fname = sprintf('s_phi%3.2f_A%d_T=0.mat',phi(i),A(j));
        
        if ~exist(fullfile(pwd,fname),'file')
    
            disp(fname);
            
            clear s;
            s = slamfat('wind',w,'profile',profile,'relaxation',0.05,'animate',false,'progress',false);

            source = zeros(length(s.profile),1);
            source(1:20) = 1.5e-4 * w.dt * s.dx;

            s.bedcomposition = slamfat_bedcomposition_basic;
            s.bedcomposition.source             = source;
            s.bedcomposition.grain_size         = .3*1e-3;

            s.max_threshold = slamfat_threshold_basic;
            s.max_threshold.time      = 0:3600;
            s.max_threshold.threshold = A(j)*sin(s.max_threshold.time/600*2*pi + phi(i));

            s.run;

            save(fname,'s');
        end
    end
end

%% S = small

phi = linspace(-pi,pi,21);
A   = 3;
S   = [3e-5 1.5e-5 3e-6 1.5e-6];

for k = 1:length(S)
    for j = 1:length(A)
        for i = 1:length(phi)
            fname = sprintf('s_phi%3.2f_A%d_S=%3.2e.mat',phi(i),A(j),S(k));

            if ~exist(fullfile(pwd,fname),'file')

                disp(fname);

                clear s;
                s = slamfat('wind',w,'profile',profile,'animate',false,'progress',false);

                source = zeros(length(s.profile),1);
                source(1:20) = S(k) * w.dt * s.dx;

                s.bedcomposition = slamfat_bedcomposition_basic;
                s.bedcomposition.source             = source;
                s.bedcomposition.grain_size         = .3*1e-3;

                s.max_threshold = slamfat_threshold_basic;
                s.max_threshold.time      = 0:3600;
                s.max_threshold.threshold = A(j)*sin(s.max_threshold.time/600*2*pi + phi(i));

                s.run;

                save(fname,'s');
            end
        end
    end
end

%% plot results

close all;

figure; hold on;

clr = 'rgbcymk';

phi = linspace(-pi,pi,21);
A   = 3:5; %0:2:8;
S   = [3e-5 1.5e-5 3e-6 1.5e-6];

transport = zeros(length(phi),length(A),1);
for j = 1:length(A)
    for i = 1:length(phi)
        fname = sprintf('s_phi%3.2f_A%d.mat',phi(i),A(j));
        
        if exist(fname,'file')
            disp(fname);
            try
                load(fname);
                transport(i,j,:) = squeeze(s.data.total_transport(end,end,:));
            end
        end
    end
    
    t = squeeze(transport(:,j,:));
    if ~all(t==0)
        plot(phi/pi*180,t/t(1),'-','Color',clr(j));
    end
end

transport = zeros(length(phi),length(A),1);
for j = 1:length(A)
    for i = 1:length(phi)
        fname = sprintf('s_phi%3.2f_A%d_T=0.mat',phi(i),A(j));
        
        if exist(fname,'file')
            disp(fname);
            load(fname);
            transport(i,j,:) = squeeze(s.data.total_transport(end,end,:));
        end
    end
    
    t = squeeze(transport(:,j,:));
    if ~all(t==0)
        plot(phi/pi*180,t/t(1),':','Color',clr(j));
    end
end

transport = zeros(length(phi),length(A),length(S),1);
for k = 1:length(S)
    for j = 1:length(A)
        for i = 1:length(phi)
            fname = sprintf('s_phi%3.2f_A%d_S=%3.2e.mat',phi(i),A(j),S(k));

            if exist(fname,'file')
                disp(fname);
                load(fname);
                transport(i,j,k,:) = squeeze(s.data.total_transport(end,end,:));
            end
        end

        t = squeeze(transport(:,j,k,:));
        if ~all(t==0)
            plot(phi/pi*180,t/t(1),'--','Color',clr(j));
        end
    end
end

xlabel('phase difference between threshold and wind velocity [^o]')
ylabel('relative transport volume w.r.t. 180^o phase difference [-]')

xlim([-180 180]);

legend([arrayfun(@(x) sprintf('threshold amplitude = %d',x), A, 'UniformOutput', false) ...
    {'no relaxation' 'decreasing supply'}], ...
    'Location','SouthWest');

grid on;
box on;

set(findobj(gca,'Type','line'),'LineWidth',2)

%% plot supply

load('s_phi0.00_A3.mat');

figure;
pcolor(s.data.supply);
shading flat;
colorbar;
title(sprintf('S = %d', 1.4e-4));

fnames = dir('s_phi0.00_A3_S=*.mat');

for i = 1:length(fnames)
    fname = fnames(i).name;
    
    re = regexp(fname, 's_phi0.00_A3_S=([\d-+\.e]+).mat', 'tokens');
    
    if ~isempty(re)
        load(fname);
        
        figure;
        pcolor(s.data.supply);
        shading flat;
        colorbar;
        title(sprintf('S = %d', str2double(re{1}{1})));
    end
end

%% 

figure;
s1 = subplot(2,2,1); hold on;

x = linspace(0,6*pi,1000);

plot(x,sin(x),'-k');
plot(x,.6*sin(x+20/180*pi),'-r');
plot(x,.6*sin(x-20/180*pi),'-b');

s2 = subplot(2,2,3); hold on;
plot(x,max(0,sin(x)-.6*sin(x+20/180*pi)),'-r');
plot(x,max(0,sin(x)-.6*sin(x-20/180*pi)),'-b');

s3 = subplot(2,2,2); hold on;

s_plus = load('s_phi0.63_A3.mat');
s_min  = load('s_phi-0.63_A3.mat');

plot(s_plus.s.output_time, s_plus.s.data.wind,'-k');
plot(s_plus.s.output_time, s_plus.s.data.threshold(:,1),'-r');
plot(s_min.s.output_time, s_min.s.data.threshold(:,1),'-b');

duration = 60 * ones(1,60);
velocity = 4+4*sin(cumsum(duration)/600*2*pi);
plot(cumsum(duration)-60, velocity,'-k');

s4 = subplot(2,2,4); hold on;

plot(s_plus.s.output_time, max(0,s_plus.s.data.wind(:,1) - s_plus.s.data.threshold(:,1)),'-r');
plot(s_min.s.output_time, max(0,s_plus.s.data.wind(:,1) - s_min.s.data.threshold(:,1)),'-b');

linkaxes([s1 s2],'x');
linkaxes([s3 s4],'x');

%xlim(minmax(x));

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