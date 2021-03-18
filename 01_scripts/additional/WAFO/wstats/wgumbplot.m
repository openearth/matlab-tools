function phat = wgumbplot(x)
%WGUMBPLOT Plots data on a Gumbel distribution paper.
%
% CALL:  phat = wgumbplot(X)
%
%       phat = [a b] Parameters (see wgumbcdf) estimated from the plot by
%              least squares method 
%          X = data vector or matrix
%
% Example:
%   R=wgumbrnd(2,0,[],1,100);
%   phat=wgumbplot(R)

% Reference: 
%  Johnson  N.L., Kotz S. and Balakrishnan, N. (1994)
%  Continuous Univariate Distributions, Volume 2. Wiley. 


% rewritten ms 20.06.2000

F=empdistr(x,[],0);
plot(F(:,1),-log(-log(F(:,2))),'b.','markersize',12);
U=[ones(size(F(:,1))) F(:,1)];
c=U\(-log(-log(F(:,2))));
a=1/c(2);
b=-c(1)*a;
hold on
plot(F(:,1),U*c,'r--')
hold off
title('Gumbel Probability Plot')
xlabel('X')
ylabel('-log(-log(F))')
if nargout > 0,
  phat=[a,b];
end
