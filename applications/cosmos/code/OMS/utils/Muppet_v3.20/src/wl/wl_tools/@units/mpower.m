function C = mpower(A,p)
%Units power.  Called for u^p.
%  p must be numeric and p*u.pow must have integer elements.

if ~isa(p,'double')
   error('Must be numeric power.')
end
C = A;
C.val = A.val.^p;
C.pow = p*A.pow;
if any(C.pow ~= fix(C.pow))
   error('Result must have integer powers.')
end
