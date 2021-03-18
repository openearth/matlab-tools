function R = walpharnd(a,varargin);
%WALPHARND Random matrices from a symmetric alpha-stable distribution
% 
% CALL:  R = walpharnd(a,sz);
%
%        R = matrix of random numbers, 
%        a = the parameter  alpha, 
%       sz = size(R)    (Default size(a))
%            sz is a comma separated list or a vector 
%            giving the size of R (see zeros for options).
%
% The characteristic function of a symmetric alpha-stable distribution is
%   h(t) = exp(-abs(t)^a)
% a = 1 gives the Cauchy distribution and a = 2 the Gaussian distribution.
%
% Example:
%   R=walpharnd(0.5,1,100);
%   plot(R,'.')
%   R=walpharnd(2,1,100);
%   wnormplot(R)
% 
% See also  zeros

% Reference:
% Samordnitsky & Taqqu (1994) "Non-Gaussian and Stable Processes"
% Chapman & Hall

% Tested on: Matlab 5.3
% History: 
% Revised by jr 22.12.1999
% revised ms 15.06.2000
% - updated header info
% - changed name to walpharnd (from alpharnd)
% - rewrote code to work with matrices
% revised pab 23.10.2000
%  - added comnsize, nargchk
%  - added greater flexibility on the sizing of R

error(nargchk(1,inf,nargin))
if nargin>1,
  [errorcode a ] = comnsize(a,zeros(varargin{:}));
  if errorcode > 0
    error('a  must be  scalar or conform to the size information given.');
  end
end

csiz=size(a);
Y1=-log(rand(csiz));
Y2=pi*(rand(csiz)-0.5);

R=sin(a.*Y2)./cos(Y2).^(1./a).*(cos((1-a).*Y2)./Y1).^((1-a)./a);
