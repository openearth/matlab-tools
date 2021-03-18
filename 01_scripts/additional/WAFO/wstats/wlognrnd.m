function R = wlognrnd(mu,v,varargin);
%WLOGNRND Random matrices from a Lognormal distribution.
%
% CALL:  R = wlognrnd(mu,v,sz);
%
%     mu, v = parameters (see wlognpdf) (Default 0 and 1, respectively)
%        sz = size(R)    (Default common size of mu and v)
%             sz can be a comma separated list or a vector 
%             giving the size of R (see zeros for options).
% Example:
%   R = wlognrnd(1,2,100,2);
%   wnormplot(log(R))
%
% See also  wlogninv, wnormrnd, wlognpdf

% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 59 ff, Marcel Dekker.



% Tested on; Matlab 5.3
% History: 
% revised pab 23.10.2000
%  - added comnsize, nargchk
%  - added greater flexibility on the sizing of R
% added ms 10.08.2000


error(nargchk(2,inf,nargin))
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

R = exp(wnormrnd(mu,v));

