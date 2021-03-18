function  [y ,eps1] = dist2dprb(phat,x1lo,x1up,x2lo,x2up)
%DIST2DPRB returns the probability for rectangular regions.
%
% CALL: [P tol] = dist2dprb(phat,x1lo,x1up,x2lo,x2up);
%
%   P    = probability
%   tol  = absolute tolerance, i.e., abs(int-intold)
%   phat = parameter structure (see dist2dfit)
%   xilo = lower integration limits
%   xiup = upper integration limits
% 
%  The size of P is the common size of XILO and XIUP.  
% 
% Example
%  x1=linspace(0,10)';
%  phat.x={[x1,exp(-0.1*x1)] 2 };
%  phat.dist={'rayl','rayl'};
%  dist2dprb(phat,1,2,1,2)
%  f = dist2dpdf2(x1,x1,phat);
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
%defining global variables
global PHAT CONDON
condon=CONDON; % save old value
CONDON=1;
if (nargin < 5), 
  error('Requires 5 input arguments.'); 
end
eps2=1e-5;%relative tolerance
% nit toolbox function
[y eps1] = gaussq2d('dist2dfun',x1lo,x1up,x2lo,x2up,eps2);
CONDON=condon; %restore the default value


