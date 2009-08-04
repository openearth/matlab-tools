%% get some arbitrary profile data 
data.x = (-65:5:920)';
data.y = [7.62 7.49 8.26 7.91 7.72 6.03 5.41 5.26 4.82 4.66 4.54 4.17 3.89 3.64 3.55 3.24 3.01 2.72 2.38 2.18 1.96 1.77 1.69 1.53 1.1 0.72 0.3 0.06 0.05 0.01 0.03 -0.06 0 0.09 0.25 0.41 0.37 0.32 0.32 0.33 0.17 0 -0.21 -0.46 -0.67 -0.87 -0.9 -0.92 -0.955 -0.99 -0.96 -0.93 -1.015 -1.1 -1.17 -1.24 -1.39 -1.54 -1.685 -1.83 -1.98 -2.13 -2.3 -2.47 -2.63 -2.79 -2.92 -3.05 -3.175 -3.3 -3.385 -3.47 -3.505 -3.54 -3.49 -3.44 -3.09 -2.74 -2.3 -1.86 -1.905 -1.95 -2.035 -2.12 -2.225 -2.33 -2.435 -2.54 -2.67 -2.8 -2.92 -3.04 -3.145 -3.25 -3.38 -3.51 -3.7 -3.89 -4.08 -4.27 -4.425 -4.58 -4.715 -4.85 -4.945 -5.04 -5.145 -5.25 -5.375 -5.5 -5.73 -5.96 -6.095 -6.23 -6.135 -6.04 -5.925 -5.81 -5.845 -5.88 -5.91 -5.94 -5.99 -6.04 -6.125 -6.21 -6.315 -6.42 -6.485 -6.55 -6.505 -6.46 -6.4 -6.34 -6.325 -6.31 -6.255 -6.2 -6.095 -5.99 -5.845 -5.7 -5.525 -5.35 -5.22 -5.09 -4.995 -4.9 -4.86 -4.82 -4.805 -4.79 -4.805 -4.82 -4.835 -4.85 -4.905 -4.96 -4.99 -5.02 -5.055 -5.09 -5.2 -5.31 -5.375 -5.44 -5.515 -5.59 -5.66 -5.73 -5.83 -5.93 -6.01 -6.09 -6.18 -6.27 -6.365 -6.46 -6.525 -6.59 -6.69 -6.79 -6.865 -6.94 -7.045 -7.15 -7.23 -7.31 -7.39 -7.47 -7.545 -7.62 -7.705 -7.79 -7.845 -7.9 -7.99 -8.08];

%% you can run getVolume with these profile data an no other input arguments
% getVolume will now be run using default settings

[Volume, result, Boundaries] = getVolume(data.x,data.y);

plotVolume(result, figure);
xlabel('Crossshore distance (m wrt. RSP = 0)')
ylabel('Surface elevation (m wrt. NAP = 0)')
title('Example plot getVolume: no boundaries preset');

%% you can run getVolume with preset boundaries
% by specifying a 'LandwardBoundary' and 'SeawardBoundary' the analysis
% area can be focussd further.

[Volume, result, Boundaries] = getVolume(data.x,data.y,'LandwardBoundary', 0, 'SeawardBoundary', 200);

result.xold = data.x;
result.zold = data.y;

plotVolume(result, figure);
xlabel('Crossshore distance (m wrt. RSP = 0)')
ylabel('Surface elevation (m wrt. NAP = 0)')
title('Example plot getVolume: seaward and landward boundaries set');

