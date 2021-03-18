function x = wgaminv(F,a,b)
%WGAMINV Inverse of the Gamma distribution function
%
% CALL:  x = wgaminv(F,a,b)
%
%        x = inverse cdf for the Gamma distribution evaluated at F
%        a = parameter, a>0
%        b = parameter, b>0 (default b=1)
%
% Example:
%   F = linspace(0,1,100);
%   x = wgaminv(F,5);
%   plot(F,x)
%
% See also  wgamcdf

% Reference: Johnson, Kotz and Balakrishnan (1994)
% "Continuous Univariate Distributions, vol. 1", p. 494 ff
% Wiley

% Tested on; Matlab 5.3
% History: 
% adapted from stixbox ms 26.06.2000
% Revised by jr 01-August-2000
% - Added approximation for higher degrees of freedom (see References)
% added b parameter ms 23.08.2000
% revised pab 23.10.2000
%  - added comnsize, nargchk

error(nargchk(2,3,nargin))
if nargin<3|isempty(b), b=1;end

[errorcode F a b] = comnsize(F,a,b);
if errorcode > 0
    error('F, a and b must be of common size or scalar.');
end
x=zeros(size(F));

ok = (0<=F& F<=1 & a>0 & b>0);


k = find(a>130 & ok);
if any(k),  % This approximation is from Johnson et al, p. 348, Eq. (17.33).
  za = wnorminv(F(k),0,1);
  x(k) = a(k) + sqrt(a(k)).*( sqrt(a(k)).*( (1-(1/9).*a(k).^(-1)+...
      (1/3).*a(k).^(-0.5).*za(k)).^3 -1) );
end

k1 = find(0<F& F<1& a<=130 & ok);
if any(k1)
  a1 = a(k1);
  x1 = max(a1-1,0.1); % initial guess 
  F1=F(k1);
  dx = ones(size(x1));
  iy=0;
  max_count=100;
  ix =find(x1);
  while (any(ix) & iy<max_count)
    xi=x1(ix);ai=a1(ix);
    dx(ix) = (wgamcdf(xi,ai) - F1(ix)) ./wgampdf(xi,ai);
    xi = xi -dx(ix);
    % Make sure that the current guess is larger than zero.
    x1(ix) = xi + 0.5*(dx(ix) - xi).* (xi<=0);
    iy=iy+1;
    ix=find((abs(dx) > sqrt(eps)*abs(x1))  &  abs(dx) > sqrt(eps)); 
    %disp(['Iteration ',num2str(iy),...
    %'  Number of points left:  ' num2str(length(ix)) ]),
  end
  x(k1)=x1; 
  if iy == max_count, 
    disp('Warning: wgaminv did not converge.');
    str = 'The last step was:  ';
    outstr = sprintf([str,'%13.8f'],dx(ix));
    fprintf(outstr);
  end
end


 
k2=find(F==1&ok);
if any(k2)
  tmp=inf;
  x(k2)=tmp(ones(size(k2)));
end

x=x.*b;

k3=find(~ok);
if any(k3)
  tmp=NaN;
  x(k3)=tmp(ones(size(k3)));
end

















