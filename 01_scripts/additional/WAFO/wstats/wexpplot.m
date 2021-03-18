function phat = wexpplot(x)
%WEXPPLOT Plots data on a Exponential distribution paper
%
% CALL:  phat = wexpplot(X)
%
%       phat = [m] Parameter (see wexpcdf) estimated from 
%              the plot by least squares method
%          X = data vector or matrix
%
% Example:
%   R=wexprnd(2,1,100);
%   phat=wexpplot(R)
%
% See also  wexpcdf, wweibplot

x = x(:);
F=empdistr(x,[],0);
plot(F(:,1),-log(1-F(:,2)),'b.','markersize',12);

m = mean(x);
hold on
plot(F(:,1),1/m*F(:,1),'r--')
hold off
title(['Exponential Probability Plot, m=' num2str(m)])
xlabel('x')
ylabel('-log(1-F)')
if nargout > 0,
  phat=[m];
end
