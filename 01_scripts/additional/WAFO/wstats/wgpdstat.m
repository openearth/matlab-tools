function [m,v]= wgpdstat(k,s,m0);
%WGPDSTAT Mean and variance for the Generalized Pareto distribution.
% 
% CALL:  [m,v] = wgpdstat(k,s,m0)
%
%       m, v = the mean and variance, respectively 
%  k, s, m0  = parameters of the  Generalized Pareto distribution
%              (see wgpdcdf).
%
% Mean (m) and variance (v) for the Generalized Pareto distribution is
%
%  m=m0+s/(1+k)  and
%  v=s^2/((1+k)^2*(1+2k))
%
% The mean does not exist for k<-1, and the variance does not exist for 
% k<-0.5.
%
% Example:
%   [m,v] = wgpdstat(1,10,10)
%   [m,v] = wgpdstat(-0.75,1,0)


% Tested on; Matlab 5.3
% History: 
% Revised by PJ 02-Apr-2001
%  - Added non-existing mean and var (k<-1 and k<-0.5).
% revised pab 24.10.2000
%  - added comnsize, nargchk + default value for s and m0
% added ms 09.08.2000

error(nargchk(1,3,nargin))
if nargin<2,  s=1;end
if nargin<3,  m0=0;end
[errorcode k,s,m0] = comnsize(k,s,m0);
if errorcode > 0
    error('k s and m0 must be of common size or scalar.');
end

% Initialize  m  and v to zero.
m = zeros(size(k));
v=m;

k1=find(s>0);
if any(k1),
  m(k1) =m0(k1)+ s(k1)./(1+k(k1));
v(k1) = s(k1).^2./((1+k(k1)).^2.*(1+2*k(k1)));
end

k2=find(s<=0);
if any(k2),
  m(k2) = NaN;
  v(k2) = NaN;
end

% Variance doesn't exist for k<-0.5
k2=find(k<-0.5);
if any(k2),
  v(k2) = NaN;
end

% Mean doesn't exist for k<-0.5
k2=find(k<-1);
if any(k2),
  m(k2) = NaN;
end
