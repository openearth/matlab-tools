function y = weib2dpdf2(v1,h1,phat)
%WEIB2DPDF2 Joint 2D Weibull probability density function
%
%  CALL:  f = weib2dpdf2(x1,x2,phat); 
%
%      f  = PDF struct with the following fields:
%           f = PDF evaluated at meshgrid(x1,x2)
%	    x = {x1,x2} (i.e., cellarray containing x1 and x2)
%  x1,x2  = vectors of evaluation points
%    phat = [A1 B1 A2 B2 C12], the parameters of the distribution
% 
% Example: 
%    x1=linspace(0,8)';
%    phat=[2 2 2 2 .9];
%    f = weib2dpdf2(x1,x1,phat); 
%    pdfplot(f);
%
% See also  weib2dfit, weib2dpdf 

%tested on: matlab 5.2
% history:
%  Per A. Brodtkorb 28.10.00

error(nargchk(3,3,nargin))

y=createpdf(2);
[X1 X2]=meshgrid(v1,h1);
y.f=  weib2dpdf(X1,X2,phat);
y.x{1}=v1(:);
y.x{2}=h1(:);
[y.cl y.pl]=qlevels(y.f);
y.note='2D Weibull';
y.phat=phat;
