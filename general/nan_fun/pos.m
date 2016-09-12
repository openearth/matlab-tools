function x = pos(x)
%POS keep only positive values, set <= to NaN
%
% y = pos(x)
%
%See also: neg

x(x <=0) = nan;