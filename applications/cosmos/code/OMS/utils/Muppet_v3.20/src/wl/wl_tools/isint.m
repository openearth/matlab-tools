function L=isint(X)
%ISINT True for integer elements.
%      Definitions: NaN, Inf and -Inf are no integers.

% Function previously called isinteger, but that name
% conflicts with a built-in function with the same name
% in the latest MATLAB releases.

% (c) Copyright 1998 H.R.A. Jagers
%     University of Twente, The Netherlands

if isa(X,'uint8')
  L=logical(ones(size(X)));
else
  L=(X==round(X)) & ~isinf(X);
end