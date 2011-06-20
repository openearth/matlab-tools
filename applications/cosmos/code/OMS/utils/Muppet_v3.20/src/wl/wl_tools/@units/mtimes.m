function C = mtimes(A,B)
%Units multiplication.  Called for u1*u2.

if isa(B,'double')
   C = A;
   C.val = A.val * B;
elseif isa(A,'double')
   C = B;
   C.val = A * B.val;
else
   A = units(A);
   B = units(B);
   if ~isequal(A.bas,B.bas)
      if all((A.pow & B.pow) == 0)
         for k = find(B.pow)
            A.bas{k} = B.bas{k};
         end
      else
         B = units(B,A);
      end
   end
   C = A;
   C.val = A.val * B.val;
   C.pow = A.pow + B.pow;
end
