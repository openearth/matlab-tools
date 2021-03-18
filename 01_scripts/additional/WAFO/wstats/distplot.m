function h = wdistplot(x,dist)
%DISTPLOT Displays a 1D distribution probability plot.
%
% CALL:  H = distplot(R,dist);
%
%   H    = handle to the plotted lines.
%   R    = data
%   dist = string containing the name of the PDF.
% 
%   The purpose of a distribution probability plot is to graphically assess
%   whether the data in X could come from a given distribution. If so
%   the plot will be linear. Other distribution types 
%   will introduce curvature in the plot.  
%
%   This works on any PDF having the following calling syntax:
% 
%    phat = pdffit(R);
%    x    = pdfinv(p,phat(1),phat(2),...,phat(n));
%
%   where R contain the data and phat(1),phat(2)... are
%   the distribution parameters. 
%
% Example:
%   R = wgamrnd(1,2,100,1);
%   distplot(R,'wgampdf');
%

% Tested on: Matlab 5.3
% History:
%   Per A. Brodtkorb 12.11.2000

error(nargchk(2,2,nargin))

x=x(:);
n=length(x);

pdf=dist(1:end-3);


eprob = [0.5./n:1./n:(n - 0.5)./n];
phat  = feval( [ pdf 'fit'],x);% MLE of the distribution parameters
cphat = num2cell(phat,1);

y  = feval([ pdf 'inv'],eprob,cphat{:})';

p     = [0.001 0.02 0.05 0.10 0.25 0.5 0.75 0.90 0.95 0.98 0.99 0.997 0.999];
tick  = feval([ pdf 'inv'],p,cphat{:});

if nargout > 0
   h = wqqplot(x,y);
else 
   wqqplot(x,y);
end


xlabel('Data');
ylabel([ pdf ' Quantiles']) %'Probability');
title( [ pdf ' Probability Plot']);

ax=axis;hold on
plot([ax(1) ax(2)],[tick; tick],'k:'); hold off
for l=1:length(p)
  h1=figtext(1.01,tick(l),num2str(p(l)) ,'norm','data');
  set(h1,'FontSize',10,'FontAngle','Italic')
end
%axis([0 inf 0 inf])
grid on;

