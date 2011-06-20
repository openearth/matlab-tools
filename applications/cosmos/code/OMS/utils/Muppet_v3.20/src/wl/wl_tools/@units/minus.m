function C = minus(A,B)
%Units minus.  Called for u1-u2.
%  Disparate arguments are converted to SI units.
%  Both arguments must have the same .pow field.

A = units(A);
B = units(B);
if ~isequal(A.bas,B.bas)
   B = units(B,A);
end
if ~isequal(A.pow,B.pow)
   error('Incompatible for subtraction.')
end
C = A;
C.val = A.val - B.val;
