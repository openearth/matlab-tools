%close all; clear all; clc;
close all; clear w; clear s;

w = slamfat_wind;
s = slamfat('wind',w,'profile',zeros(1,100),'animate',true,'visualization',@slamfat_plot_sierd);

source = zeros(length(s.profile),1);
source(1:20) = 1.5e-4 * w.dt * s.dx;

s.bedcomposition.enabled            = false;
s.bedcomposition.source             = source;
s.bedcomposition.initial_deposit    = .01;
%s.bedcomposition.grain_size         = [1.18 0.6 0.425 0.3 0.212 0.15 0.063]*1e-3;
%s.bedcomposition.distribution       = [0.63 0.94 6.80 51.35 30.73 8.07 1.43];

%s.source_maximalization  = 'initial_profile';
%s.threshold_maximalization = 'tide';

s.run;