function R = wnormrnd(mu,v,varargin);
%WNORMRND Random matrices from a Normal distribution.
%
% CALL:  R = wnormrnd(mu,v,sz);
%
%        mu = mean       (Default 0)
%         v = variance   (Default 1)
%        sz = size(R)    (Default common size of mu and v)
%             sz can be a comma separated list or a vector 
%             giving the size of R (see zeros for options). 
%
% Examples:
%   R  = wnormrnd(1,2,100,2,2);
%   R2 = wnormrnd(1,2,[100,3,2]);
%   wnormplot([R(:,:,1) R2(:,:,2)])
%
% See also  wnorminv

% tested on: matlab 5.3
% History:
% revised pab 23.10.2000
%  - added default mu,v
%  - added comnsize, nargchk
%  - added greater flexibility on the sizing of R
% by ??

error(nargchk(0,inf,nargin))
if nargin<1|isempty(mu),mu=0;end
if nargin<2|isempty(v), v=1;end

if nargin<3,
  [errorcode mu v] = comnsize(mu,v);
else
  [errorcode mu v] = comnsize(mu,v,zeros(varargin{:}));
end
if errorcode > 0
    error('mu and v must be of common size or scalar.');
end
R=zeros(size(mu));
k=find(v>=0);
if any(k)
  R(k)=randn(size(k)).*sqrt(v(k))+mu(k);
end
k1=find(v<0);
if any(k1)
  tmp=NaN;
  R(k1)=tmp(ones(size(k1)));
end
