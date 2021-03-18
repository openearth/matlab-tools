function phat = wweibplot(x)
%WWEIBPLOT Plots data on a Weibull distribution paper
%
% CALL:  phat = wweibplot(X)
%
%       phat = [a c] Parameters (see wweibcdf) estimated from 
%              the plot by least squares method
%          X = data vector or matrix
%
% Example:
%   R=wweibrnd(2,2,1,100);
%   phat=wweibplot(R)
%
% See also  wwibcdf, wweibinv



% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 25 ff, Marcel Dekker.

% Revised jr 28.08.2000: line 23 added.
% rewritten ms 20.06.2000

x = x(:);
F=empdistr(x,[],0);
plot(log(F(:,1)),log(-log(1-F(:,2))),'b.','markersize',12);
U=[ones(size(x)) log(F(:,1))];
b=U\log(-log(1-F(:,2)));
c=b(2);
a=exp(-b(1)/c);
hold on
plot(log(F(:,1)),U*b,'r--')
hold off
title('Weibull Probability Plot')
xlabel('log(X)')
ylabel('log(-log(1-F))')
if nargout > 0,
  phat=[a,c];
end
