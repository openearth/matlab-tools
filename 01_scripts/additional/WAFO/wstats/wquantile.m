function  q = wquantile(x,p,method)
%WQUANTILE Empirical quantile (percentile).
%
%  CALL:  q = wquantile(x,p,method)
%
%      q = empirical quantile
%      x = input vector or matrix
%      p = probability
% method = 1 Interpolation so that F(X_(k)) == (k-0.5)/n. (default)
%	   2 Interpolation so that F(X_(k)) == k/(n+1).
%	   3 Based on the empirical distribution.
%
%  If input  x  is a matrix then the quantile is computed for 
%  every column. Input  p  may be vector also. It even 
%  accepts  x  being a vector and  p  a matrix!

% References: 
%  Holtsberg, Anders (1999)
%  Stixbox. A statistics toolbox for Matlab and Octave. 
%  Lund University
%  http://www.maths.lth.se/matstat/stixbox

% Tested on: Matlab 5.3
% History:
% revised pab 
% - added nargchk
% - updated help header to conform to wafo style
% by Anders Holtsberg 1994, 1998


error(nargchk(2,3,nargin))
if nargin<3|isempty(method), method=1; end
if min(size(x)) == 1
   x = x(:);
   q = zeros(size(p));
else
   if min(size(p)) > 1 
      error('Not both matrix x and matrix p input')
   end
   q = zeros(length(p),size(x,2));
end
if any(any((p>1|p<0)))
   error('Input p is not probability')
end

x = sort(x); 
p = p(:);
n = size(x,1);
if method == 3
   qq1 = x(ceil(max(1,p*n)),:); 
   qq2 = x(floor(min(p*n+1,n)),:);
   qq = (qq1+qq2)/2;
else                         
   x = [x(1,:); x; x(n,:)];
   if method == 2
      % This method is from Hjort's "Computer
      % intensive statistical methods" page 102
      i = p*(n+1)+1;
   else % Metod 1
      i = p*n+1.5;
   end
   iu = ceil(i);
   il = floor(i);
   d = (i-il)*ones(1,size(x,2));
   qq = x(il,:).*(1-d)+x(iu,:).*d;
end

q(:) = qq;







