function [x] = tdsol(A,d);
%%TDSOL - Function solves Ax=d for x using Thomas algorithm 
% Usage : [x] = tdsol(A,d);
%
% Source: http://en.wikipedia.org/wiki/Tridiagonal_matrix_algorithm
% ------------------------------------
%    Willem Ottevanger, Delft University of Technology
%    7 february 2009
% ------------------------------------
a = [0;diag(A,-1)];
b = diag(A);
c = [diag(A,1);0];
n = length(d);
%Modify the coefficients
c(1) = c(1)/b(1); %Division by zero risk -> would imply a singular matrix.
d(1) = d(1)/b(1); 
for j = 2:n
    id   = b(j)-c(j-1)*a(j);
    c(j) = c(j)/id;
    d(j) =(d(j)-d(j-1)*a(j))/id;
end
%Now back substitution
x(n) = d(n);
for j = n-1:-1:1
    x(j) = d(j) - c(j)*x(j+1);
end