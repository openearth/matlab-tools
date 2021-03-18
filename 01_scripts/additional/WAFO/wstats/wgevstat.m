function [m,v]= wgevstat(k,s,m0);
%WGEVSTAT Mean and variance for the GEV distribution.
% 
% CALL:  [m,v] = wgevstat(k,s,m0)
%
%       m, v = the mean and variance, respectively 
%   k, s, m0 = parameter of the GEV distribution. (see wgevcdf)
%
%  Mean (m) and variance (v) for the GEV distribution is
%
%  m=(m0*k+s)/k-s*gamma(k+1)/k  and
%  v=(m0*k+s)^2/(k^2)+(-2*m0*k-2*s)*s*gamma(k+1)/(k^2)...
%    +s^2*gamma(2*k+1)/(k^2)-m^2
%
%  Note: mean only exists for k>-1 and variance for k>0
%
% Example:
%   [m,v] = wgevstat(0.5,2,0)
%   [m,v] = wgevstat(-0.5,2,0)
  
% Tested on; Matlab 5.3
% History: 
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
ok = (s > 0 & k>-1 );
k1=find(ok);
if any(k1),
  m(k1) = (m0(k1).*k(k1)+s(k1))./k(k1)-s(k1).*gamma(k(k1)+1)./k(k1);
end

ok1 = (s>0 & k>0 );
k2=find(ok1);
if any(k2),
v(k2) = (m0(k2).*k(k2)+s(k2)).^2./(k(k2).^2)+...
    (-2*m0(k2).*k(k2)-2*s(k2)).*s(k2).*gamma(k(k2)+1)./...
    (k(k2).^2)+s(k2).^2*gamma(2*k(k2)+1)./(k(k2).^2)-m(k2).^2;
end


k3 = find(~ok);     
if any(k3)
  tmp = NaN;
  m(k3) = tmp(ones(size(k1)));
end
k4 = find(~ok1);     
if any(k4)
  tmp = NaN;
  v(k4) = tmp(ones(size(k1)));
end



