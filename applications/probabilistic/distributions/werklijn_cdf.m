function P = werklijn_cdf(X, a, b)
% cdf according to "werklijn"  
% probability is translated to frequency.
% X is a linear function of log(frequency)

% input
%   X:    x-value
%   a,b:  parameters of the linear relation
%
% output
%   P:    probability of non-exceedance

% transform probability of non-exceedance frequency of exceedance
P = exp(-exp(-(X-b)./a));


