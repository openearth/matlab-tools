function [f,k,s] = wgpdfit_ml(x,data)
%WGPDFIT_ML Internal routine for wgpdfit (ML estimates for GPD data) 
%
% CALL:  [f,k,s] = wgpdfit_ml(x,data)
%
% f = function values.
% k = shape parameter of GPD.
% s = scale parameter of GPD.
%
% This function is used by wgpdfit for numerical solution of 
% the ML estimate, i.e. solve f=0 for x.
%   data = wgpdrnd(0.3,1,0,200,1);
%   x_ML = fzero('wgpdfit_ml',0,[],data);
%   [f,k_ML,s_ML] = wgpdfit_ml(x_ML,data)  % Estimates k_ML and s_ML
%
% See also  wgpdfit

% References
%
%  Davidson & Smith (1990)
%  Models for Exceedances over high Threholds.
%  Journal of the Royal Statistical Society B,52, pp. 393-442.

% Tested on; Matlab 5.3
% History: 
% Created by PJ 22-Jun-2000
% Revised by PJ 10-Oct-2000
% - Help text added w*

% In order to avoid boundary problems in numerical solution we use a transformation
%   Transformation: x = log(1/max_data - t),   -Inf < t < 1/max_data
%   Inverse Trans.: t = 1/max(data) - exp(x),  -Inf < x < Inf

t = 1/max(data) - exp(x); % Inverse Transformation

N = length(data);

k = -1/N*sum(log(1-t*data)); % Shape parameter
s = k/t;                     % Scale parameter

% Evaluate function
f = (1/k-1)*sum(data./(1-t*data)) - N/t; 
