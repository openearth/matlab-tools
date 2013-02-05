function P = werklijn_pdf(X, a, b)
% pdf according to "werklijn"  
% probability is translated to frequency.
% X is a linear function of log(frequency)

% input
%   X:    x-value
%   a,b:  parameters of the linear relation
%
% output
%   P:    probability density

% transform probability of non-exceedance frequency of exceedance
P = werklijn_cdf(X, a, b).*exp(-(X-b)./a).*(1./a);