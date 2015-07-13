function Mw = calculate_mw(subfaults, varargin)
%calculate_mw - Calculate the moment magnitude from subfault data
%   Detailed explanation goes here

% enter rigidity/shear modulus in Pascals (uniform for all subfaults)
% Multiply by 10 to get dyne/cm^2 value.
if any(strcmpi(varargin,'mu'))==1;
    indi=strcmpi(varargin,'mu');
    ind=find(indi==1);
    mu=varargin{ind+1};
else
    mu = 4e10;
end

% first calculate the seismic moment (Mo)
total_Mo = 0.0;
for i = 1:length(subfaults.latitude)
    total_slip = subfaults.length(i) * subfaults.width(i) * subfaults.slip(i);
    if isfield(subfaults, 'mu')
        Mo = subfaults.mu(i) * total_slip;
        avg_mu = mean(subfaults.mu);
    else
        Mo = mu * total_slip;
    end
    total_Mo = total_Mo + Mo;
end

% Calculate moment agnitude based on seismic moment
% units are in N-m 
% follows usgs definition at http://earthquake.usgs.gov/aboutus/docs/020204mag_policy.php
Mw = 2/3.0 * (log10(total_Mo) - 9.05);

if isfield(subfaults, 'mu')
    disp(sprintf('%i subfaults\nMw = %.3f\naverage rigidity = %.f GPa',length(subfaults.latitude),...
        Mw, avg_mu/1e9));
else 
    disp(sprintf('%i subfaults\nMw = %.3f\nrigidity = %.f GPa',length(subfaults.latitude),...
        Mw, mu/1e9));
end

