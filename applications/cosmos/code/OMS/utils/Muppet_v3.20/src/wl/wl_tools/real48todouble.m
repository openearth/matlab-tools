function y = real48todouble(x)
%REAL48TODOUBLE Convert Borland 6 byte reals (Real48) to doubles. %
%  REAL48TODOUBLE(R), where R is a vector of uint8 integers (values %  in the range 0,1,...,255), returns a vector of doubles.  Six uint8 %  values are converted into one double, so the length of R must be a %  multiple of 6.
%
%  For example, to read N Real48 values from a file identifier FID %  and convert them to doubles, one can use
%
%      u8 = fread( fid, n*6, 'uint8' );
%      x = real48todouble( u8 );
 
%  Author:      Peter J. Acklam
%  Time-stamp:  1999-10-18 16:58:18
%  E-mail:      jacklam@math.uio.no
%  WWW URL:    http://www.math.uio.no/~jacklam
 
% Check number of input arguments.
error( nargchk( 1, 1, nargin ) );
 
% Quick exit if input is empty.
if isempty(x)
  y = [];
  return;
end
 
% Make sure input is a vector whose length is a multiple of 6.
sx = size(x);
lx = length(x);
if sum( sx > 1 ) > 1
  error( 'Input must be a vector.' );
end
if rem( lx, 6 )
  error( 'Lenght of input vector must be a multiple of 6.' );
end
 
n = lx/6;
x = reshape(x, 6, n);
 
% Get the sign and remove it from the input data.
s = ones(1,n);
k = x(6,:) > 127;
s(k) = -1;
x(6,k) = x(6,k) - 128;
 
% Get the floating point part and the exponent and calculate output. %f = ((((((((x(2,:)/256)+x(3,:))/256)+x(4,:))/256)+x(5,:))/256)+x(6,:))/128; f = pow2(-39:8:-7)*x(2:6,:);
e = x(1,:);
y = s.*pow2( 1+f, e-129 );
 
% Let output be a column vector if input is.
if sx(1) > 1
  y = y.';
end