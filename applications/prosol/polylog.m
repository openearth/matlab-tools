function y = polylog(n,z,acc)
%%POLYLOG - Computes the n-polylogarithm of z (Li_n)
%
% Usage:   y = polylog(n,z)
%          y = polylog(n,z,acc)
%
% Input:  |z|<1 : complex number defined on open unit disk
%          n    : base of polylogarithm
%          acc  : cutoff accuracy
%
% Output: y
%
% -------------------------------------------------------------------------
%  Copyright (C) 2009 Delft University of Technology
%    Faculty of Civil Engineering and Geosciences
%    Willem Ottevanger  
% -------------------------------------------------------------------------
if nargin == 2
   acc = eps;
end

y  = z;
y0 = y;
for j = 1:length(z);
    k = 1;
    err = 1;
    zk = z(j);
    while (abs(err)>acc);
        k = k+1;
        kn = k.^n;
        zk = zk.*z(j);
        err = zk./kn;
        y(j) = y(j)+err;
    end
end

