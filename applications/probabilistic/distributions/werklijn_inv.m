function X = werklijn_inv(P, a, b)
% inverse probability distribution function 
% probability is translated to frequency.
% X is a linear function of log(frequency)

% input
%   P:    probability of non-exceedance
%   a,b:  parameters of the linear relation
%
% output
%   X:    x-value, asociated with P

% transform probability of non-exceedance frequency of exceedance
Fe = -log(P);
RP = 1./Fe;    % return period

% compute X
X = a*log(RP)+b;


