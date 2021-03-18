function [m,v]= wchi2stat(p);
%WCHI2STAT Mean and variance for the Chi squared distribution.
% 
% CALL:  [m,v] = wchi2stat(p)
%
%   m, v = the mean and variance, respectively 
%      p = degrees of freedom, p=1,2,3,....
%
%  Mean (m) and variance (v) for the Chi squared distribution is
%
%  m=p  and  v=2p;
%
% Example: 
%   [m,v] = wchi2stat(2)

% Reference: Johnson, Kotz and Balakrishnan (1994)
% "Continuous Univariate Distributions, vol. 1", p. 415 ff
% Wiley

% Tested on; Matlab 5.3
% History: 
% revised pab 25.10.2000
% - found a bug: forgot multiplication
% - added warning+nan's
% added ms 26.06.2000

m =  p;
v = 2*p;
ok = find(p~=round(p) & p>0);
if any(~ok),
  warning('p should be a positive integer')
  m(k)=NaN;
  v(k)=NaN;
end



