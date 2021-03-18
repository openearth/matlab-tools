function y = dist2dpdf2(v1,h1,phat)
%DIST2DPDF2 Joint 2D PDF computed as f(x1|X2=x2)*f(x2)
%
%  CALL:  f = dist2dpdf2(x1,x2,phat); 
%
%      f  = PDF struct with the following fields:
%           f = PDF evaluated at meshgrid(x1,x2)
%	    x = {x1,x2} (i.e., cellarray containing x1 and x2)
%  x1,x2  = vectors of evaluation points
%    phat = structure array containing
%            x    = cellarray of distribution parameters
%            dist = cellarray of strings defining the distributions of 
%                   X2 and X1 given X2, respectively. Options are:
%                   'tgumbel', 'gumbel', 'lognormal','rayleigh','weibull',
%                   and 'gamma'.
% 
%  DIST2DPDF2 evaluates f{x1|X2=x2 }*f{x2}. 
%   The parameter(s) of the unconditional distribution of X2,
%   f{x2}, must be in in phat.x{2}. The parameters of the conditional
%   distribution of X1 given X2 must be in phat.x{1}. The first column
%   in phat.x{1} contains the X2 values the parameters in column 2 and 3 are
%   conditioned on.  
%
% Example: 2D Rayleigh
%    x1=linspace(0,10)';
%    phat.x={[x1,2*ones(size(x1))] 2 };
%    phat.dist={'rayl','rayl'};
%    f = dist2dpdf2(x1,x1,phat); 
%    pdfplot(f);
%
% See also  dist2dfit, dist2dpdf 

%tested on: matlab 5.2
% history:
%  Per A. Brodtkorb 28.10.98

error(nargchk(3,3,nargin))

y=createpdf(2);
[X1 X2]=meshgrid(v1,h1);
y.f=  dist2dpdf(X1,X2,phat);
y.x{1}=v1(:);
y.x{2}=h1(:);
%contour(v1,h1,y.f)
%y.f(isinf(y.f)|isnan(y.f))=0;
try
  [y.cl y.pl]=qlevels(y.f);
catch
  y.cl=[];
  y.pl=[];
end
y.phat=phat;


