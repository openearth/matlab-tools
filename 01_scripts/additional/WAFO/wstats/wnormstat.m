function [m,v]= wnormstat(m0,v0);
%WNORMSTAT Mean and variance for the Normal distribution.
% 
% CALL:  [m,v] = wnormstat(m0,v0)
%
%   m, v = the mean and variance, respectively 
% m0, v0 = parameters of the Normal distribution.
%
%  Mean (m) and variance (v) for the Normal distribution is
%
%  m=m0  and  v=v0;
%
% Example:
%   [m,v] = wnormstat(5,3) % Trivial!

if nargin < 2,    
    error('Requires two input arguments.'); 
end

m =  m0;
v = v0;

