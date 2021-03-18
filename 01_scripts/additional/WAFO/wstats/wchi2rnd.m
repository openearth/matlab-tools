function R = wchi2rnd(p,varargin);
%WCHI2RND Random matrices from a Chi squared distribution.
%
%  CALL:  R = wchi2rnd(p,sz);
%
%         p = degrees of freedom, p=1,2,3,...
%        sz = size(R)    (Default size(p))
%             sz is a comma separated list or a vector 
%             giving the size of R (see zeros for options).
%
%  The Chi squared distribution is a special case of 
%  the gamma distribution. Thus the wgamrnd is used to
%  generate R.
%
% Example:
%   R=wchi2rnd(2,1,100);
%   plot(R,'.')
%
% See also  wgamrnd

% Reference: Johnson, Kotz and Balakrishnan (1994)
% "Continuous Univariate Distributions, vol. 1", p. 415 ff
% Wiley

% Tested on; Matlab 5.3
% History: 
% revised pab Dec2003
% removed old call
% revised pab 25.10.2000
% - replaced code with a call to wgamrnd
% added ms 26.06.2000

error(nargchk(1,inf,nargin))

if nargin>1,
  [errorcode p] = comnsize(p,zeros(varargin{:}));
  if errorcode > 0
    error('p must be a scalar or comply to the size given.');
  end
end

R = wgamrnd(p/2,2);

k1=find(p~=round(p)|p<=0);
if any(k1)
  warning('p must be a positive integer')
  tmp=NaN;
  R(k1)=tmp(ones(size(k1)));
end

return





