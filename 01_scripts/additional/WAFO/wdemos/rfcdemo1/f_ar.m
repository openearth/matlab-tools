function f = f_ar(y,u0,u1,a1,m,s)
%F_AR  Auxiliary function used by RFCDEMO1
%
% CALL:  f = f_ar(y,u0,u1,a1,m,s)

% Copyright (c) 1997 by P?r Johannesson
% Toolbox: Rainflow Cycles for Switching Processes V.1.0, 2-Oct-1997


sx = s/sqrt(1-a1^2);
m2 = -a1*(y-m) + m;

f = 1/sx*wnormpdf((y-m)/sx).*(wnormcdf((u1-m2)/s)-wnormcdf((u0-m2)/s));
