function [vt] = computelandwarddecay_wind(vmax, t, alpha)
% Simple function that computes the landward decay 
% like Kaplan & DeMaria (1995), but simpler

% Compute decay with an exponential curve
vt          = vmax*exp(-alpha.*t);

end

