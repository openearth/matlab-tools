function [y ] = gauss_3(A,B);
% gauss elimination to solve A*X = B
% for three diagonal array 
% test to speed things up
na = length(A);
jdn = 3;
jup = 2;

for ja = 1:na-1
 fac = A(ja,jdn)/A(ja,1);
 A(ja+1,1) = A(ja+1,1)-fac*A(ja+1,jup);
 B(ja+1) = B(ja+1)-fac*B(ja);
end

y(na) = B(na)/A(na,1);
for ja = na-1:-1:1
 y(ja) = (B(ja)-A(ja+1,jup)*y(ja+1))/A(ja,1);
end