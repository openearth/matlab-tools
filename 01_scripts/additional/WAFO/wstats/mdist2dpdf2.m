function y = dist2dpdf2(v1,h1,phat)
% MDIST2DPDF2 Joint 2D PDF due to Plackett given as  f{x1}*f{x2}*G(x1,x2;Psi). 
%
%  CALL:  f = dist2dpdf2(x1,x2,phat); 
%
%      f  = PDF struct with the following fields:
%           f = PDF evaluated at meshgrid(x1,x2)
%	    x = {x1,x2} (i.e., cellarray containing x1 and x2)
%  x1,x2  = vectors of evaluation points
%    phat = structure array containing
%           x    = cellarray of distribution parameters
%           dist = cellarray of strings defining the marginal 
%                  distributions of X1 and X2, respectively. Options are:
%                  'tgumbel', 'gumbel', 'lognormal','rayleigh','weibull',
%                  and 'gamma'.
% 
%  MDIST2DPDF2 evaluates f{x1}*f{x2}*psi(x1,x2). 
%   The parameter(s) of the marginal distribution of X1 and X2,
%   must be in in phat.x{1} and phat.x{2}, respectively. phat.x{3}
%   gives the interaction parameter.
%
% Example: 2D Rayleigh
%    x1 = linspace(0,10)';
%    phat.x={2 3  10 };
%    phat.dist={'rayl','rayl'};
%    f = mdist2dpdf2(x1,x1,phat); 
%    pdfplot(f);
%
% See also  mdist2dfit, mdist2dpdf 

%tested on: matlab 5.2
% history:
% revised pab 29.10.2000
% - updated to new wstats
%  Per A. Brodtkorb 28.10.98

error(nargchk(3,3,nargin))
y=createpdf(2);
[X1 X2]=meshgrid(v1,h1);
y.f=  mdist2dpdf(X1,X2,phat);
y.x{1}=v1(:);
y.x{2}=h1(:);
[y.cl y.pl]=qlevels(y.f);
y.phat=phat;



