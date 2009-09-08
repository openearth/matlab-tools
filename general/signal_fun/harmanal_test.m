function OK = harmanal_test
%HARMANAL_TEST   test for harmanal
%
%See also: harmanal_test

D.T     = [ .5  1  2]; % day
D.phi   = [10  20 30]; % deg
D.A     = [ 1   2  3]; % any unit
D.w     = 2*pi./D.T;   % rad/day

OPT.eps = min(D.A)./1e12;

T.t  = 0:(1/24):max(D.T);
T.h  = 0.*T.t;
for j=1:length(D.T)
T.h  = T.h + D.A(j).*cos(D.w(j).*T.t - deg2rad(D.phi(j)));
end

plot  (T.t,T.h,'.-')
xlabel('day')
xlabel('signal')

FIT = harmanal(T.t,T.h,'omega',D.w,'screenoutput',0);

OK = 1;
for i=1:length(D.A)
   if abs(D.A(i)-FIT.hamplitudes(i)) > OPT.eps
   OK = 0;
   end
   if abs(D.phi(i)-rad2deg(FIT.hphases(i))) > OPT.eps
   OK = 0;
   end
end
