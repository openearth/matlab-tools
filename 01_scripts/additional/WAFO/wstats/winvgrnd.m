function R = winvgrnd(m0,l,varargin);
%WINVGRND Random matrices from a Inverse Gaussian distribution.
%
% CALL:  R = winvgrnd(m0,l,sz);
%
%      m0,l = parameters  (see winvgpdf)
%        sz = size(R)    (Default common size of m0 and l)
%             sz can be a comma separated list or a vector 
%             giving the size of R (see zeros for options).
%
% Examples:
%   R = winvgrnd(2,2,100,2);
%   R2 = winvgrnd(2,3,[100,2]);
%   wqqplot(R(:,1),R2(:,1))
%
% See also  winvgpdf

% Reference: Chhikara & Folks, "The Inverse Gaussian Distribution", p. 53

% Tested on; Matlab 5.3
% History:
% revised pab 24.10.2000
%  - added comnsize, nargchk
% added ms 14.08.2000

error(nargchk(2,inf,nargin))
if nargin==2,
  [errorcode m0 l] = comnsize(m0,l);
else
  [errorcode m0 l] = comnsize(m0,l,zeros(varargin{:}));
end
if errorcode > 0
  error('m0 and l must be of common size or scalar.');
end
R=zeros(size(m0));
ok=((m0>0)&(l>0));
k=find(ok);
if any(k)
  ksiz=size(k);
  R1=rand(ksiz);
  Y=wchi2rnd(1,ksiz);
  X1=m0(k)./(2*l(k)).*(2*l(k)+m0(k).*Y-(4*l(k).*m0(k).*Y+m0(k).^2.*Y.^2).^(1/2));
  X2=m0(k).^2./X1;
  I=(R1<m0(k)./(m0(k)+X1));
  R(k)=X1.*I+X2.*(1-I);
end
k1=find(~ok);
if any(k1)
  tmp=NaN;
  R(k1)=tmp(ones(size(k1)));
end


