function yinterp = ntrp113(tinterp,t,y,tnew,ynew,klast,phi,psi)
%NTRP113 Interpolation helper function for ODE113.
%   YINTERP = NTRP113(TINTERP,T,Y,TNEW,YNEW,KLAST,PHI,PSI) uses data
%   computed in ODE113 to approximate the solution at time TINTERP.
%   
%   See also ODE113.

%   Mark W. Reichelt and Lawrence F. Shampine, 6-13-94
%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision$  $Date$

hi = tinterp - tnew;            % scalar (unlike other NTRP functions)
ki = klast + 1;
KI = 1:ki;

w = 1 ./ (1:13)';
g = zeros(13,1);
g(1) = 1;
term = 0;
for j = 2:ki
  gamma = (hi + term) / psi(j-1);
  eta = hi / psi(j-1);
  for i = 1:ki+1-j
    w(i) = gamma * w(i) - eta * w(i+1);
  end
  g(j) = w(1);
  term = psi(j-1);
end

yinterp = ynew + hi * phi(:,KI) * g(KI);
