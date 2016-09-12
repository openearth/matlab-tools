function x = pos(x)
%NEG keep only negative values, set >= to NaN
%
% y = neg(x)
%
%See also: pos

x(x >= 0) = nan;