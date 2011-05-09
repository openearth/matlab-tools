function y = rpascal(x)
%RPASCAL Convert Delphi/Turbo Pascal 6 byte reals to Matlab doubles.
%
%  RPASCAL(R), where R is an N-by-6 vector of integers in the range
%  0,...,255 returns an N-by-1 vector of real numbers.  Each row of R
%  contains the 6 bytes used to store one real.

s = ones( size( x, 1 ), 1 );
k = x(:,6) > 127;
s( logical( k ) ) = -1;
x(:,6) = rem( x(:,6), 128 );
 
f = ((((((((x(:,2)/256)+x(:,3))/256)+x(:,4))/256)+x(:,5))/256)+x(:,6))/128;   e = x(:,1);
y = s.*pow2( 1+f, e-129 );
 
