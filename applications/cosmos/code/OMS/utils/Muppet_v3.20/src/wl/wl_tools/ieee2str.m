function [Str,Val]=ieee2str(x),
[f,e] = log2(x);
n = pow2(f,52);
k = e-52;
Str=[num2str(n,16) '*2^(' num2str(k) ')'];
if nargout==2,
  Val=[n k];
end;

% the numbers stored are
% x = (2^52 + m)*2^j,  with   0 <= m < 2^52
