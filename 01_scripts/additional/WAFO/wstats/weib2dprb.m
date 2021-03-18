function  [y ,eps1] = weib2dprb(phat,x1lo,x1up,x2lo,x2up)
%WEIB2DPRB returns the probability for rectangular regions.
%
% CALL: [P tol] = weib2dprb(phat,x1lo,x1up,x2lo,x2up);
%
%   P    = probability
%   tol  = absolute tolerance, i.e., abs(int-intold)
%   phat = parameter vectr (see weib2dfit)
%   xilo = lower integration limits
%   xiup = upper integration limits
% 
%  The size of P is the common size of XILO and XIUP.  
% 
% Example
%  x1=linspace(0,10)';
%  phat = [ 1 2 .5 1.5 .8];
%  weib2dprb(phat,1,2,1,2)
%  f = weib2dpdf2(x1,x1,phat);
%  pdfplot(f); hold on,
%  plot([ 1 1 2 2 1],[1 2 2 1 1]), hold off
%
%  See also  dist2dfit dist2drnd dist2dpdf dist2dcdf


% tested on: matlab 5.2
% history:
% revised pab 27.10.2000
%  - added example text
%  Per A. Brodtkorb 28.10.98

error(nargchk(5,5,nargin))
if length(phat)~=5, error('phat must have 5 elements'),end
eps2=1e-5;%relative tolerance
% nit toolbox function
ph=num2cell(phat(:)',1);
[y eps1] = gaussq2d('weib2dpdf',x1lo,x1up,x2lo,x2up,eps2,ph{:});


