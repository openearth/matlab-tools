function bhat = wraylplot(x)
%WRAYLPLOT Plots data on a Rayleigh distribution paper
%
% CALL:  bhat = wraylplot(X) 
%
%   bhat = Parameter of the distribution estimated from the
%          plot by least squares method.
%   X = data
%
% Example:
%   R=wraylrnd(1,1,100);
%   wraylplot(R);
%
% See also  wqqplot

% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 181 ff, Marcel Dekker.

%tested on: matlab 5.1
% rewritten ms 15.06.2000

F=empdistr(x,[],0);
plot(F(:,1),sqrt(-log(1-F(:,2))),'b.','markersize',12)
U=[ones(size(F(:,1))) F(:,1)];
c=U\sqrt(-log(1-F(:,2)));
b=1/c(2)/2^(1/2);
hold on
plot(F(:,1),U*c,'r--')
hold off
title('Rayleigh Probability Plot')
xlabel('X')
ylabel('(-log(1-F))^{1/2}')
if nargout > 0,
  bhat=b;
end
