function x = wnorminv(F,m,v)
%WNORMINV Inverse of the Normal distribution function
%
% CALL:  x = wnorminv(F,m,v)
%
%        x = inverse cdf for the Normal distribution evaluated at F
%        m = mean     (default 0)
%        v = variance (default 1)
%
% Example:
%   F = linspace(0,1,100);
%   x = wnorminv(F,2.5,0.6);
%   plot(F,x)
% 
% See also  wnorminv
  
% Tested on: Matlab 6.0, 5.3
% History:
% revised pab 23.03.2003
% -replace erfinv with PHIINV which perform more accurate
%  inversion in the lower tail. This also results in faster execution.
% revised jr 03.04.2001
%  - fixed a bug in the last if statement
%  - updated information, example
% revised pab 24.10.2000
%  - added comnsize, nargchk
%  - added default values
% added ms 17.06.2000

error(nargchk(1,3,nargin))
if nargin<2|isempty(m),  m=0;  end
if nargin<3|isempty(v),  v=1;  end

[errorcode, F, m, v] = comnsize (F,m, v);
if (errorcode > 0)
  error ('F, m and v must be of common size or scalar');
end

x=zeros(size(F));

ok = ((v>0)&(F>=0)&(F<=1));
k = find (ok);
if any(k)
  % old call
  %x(k) = sqrt(2*v(k)).*erfinv(2 * F(k) - 1) + m(k);
  % new call
  x(k) = sqrt(v(k)).*PHIINV(F(k))+m(k);
end

k1 = find (~ok);
if any(k1)
  tmp=NaN;
  x(k1) = tmp(ones(size(k1)));
end

return


function PHINV = PHIINV( P ) 
%
%	ALGORITHM AS241  APPL. STATIST. (1988) VOL. 37, NO. 3
%
%	Produces the normal deviate Z corresponding to a given lower
%	tail area of P.
%  
%       Absolute error less than 1e-13
%       Relative error less than 1e-15 for abs(VAL)>0.1
%  
%	The hash sums below are the sums of the mantissas of the
%	coefficients.   They are included for use in checking
%	transcription.
%

   SPLIT1 = 0.425;
   SPLIT2 = 5;
   CONST1 = 0.180625;
   CONST2 = 1.6; 
   
   
%  Coefficients in rational approximations.  
%!     
%!     Coefficients for P close to 0.5
%!     
A0 = 3.3871328727963666080E00;
A1 = 1.3314166789178437745E+2;
A2 = 1.9715909503065514427E+3;
A3 = 1.3731693765509461125E+4;
A4 = 4.5921953931549871457E+4;
A5 = 6.7265770927008700853E+4;
A6 = 3.3430575583588128105E+4;
A7 = 2.5090809287301226727E+3;

B1 = 4.2313330701600911252E+1;
B2 = 6.8718700749205790830E+2;
B3 = 5.3941960214247511077E+3;
B4 = 2.1213794301586595867E+4;
B5 = 3.9307895800092710610E+4;
B6 = 2.8729085735721942674E+4;
B7 = 5.2264952788528545610E+3;
%*     HASH SUM AB    55.88319 28806 14901 4439
%!     
%!     Coefficients for P not close to 0, 0.5 or 1.
%!     
C0 = 1.42343711074968357734E00;
C1 = 4.63033784615654529590E00;
C2 = 5.76949722146069140550E00;
C3 = 3.64784832476320460504E00; 
C4 = 1.27045825245236838258E00;
C5 = 2.41780725177450611770E-1;
C6 = 2.27238449892691845833E-2;
C7 = 7.74545014278341407640E-4;
D1 = 2.05319162663775882187E00;
D2 = 1.67638483018380384940E00;
D3 = 6.89767334985100004550E-1;
D4 = 1.48103976427480074590E-1;
D5 = 1.51986665636164571966E-2;
D6 = 5.47593808499534494600E-4;
D7 = 1.05075007164441684324E-9 ;
%*     HASH SUM CD    49.33206 50330 16102 89036
%!
%!	Coefficients for P near 0 or 1.
%!
E0 = 6.65790464350110377720E00;
E1 = 5.46378491116411436990E00;
E2 = 1.78482653991729133580E00;
E3 = 2.96560571828504891230E-1;
E4 = 2.65321895265761230930E-2;
E5 = 1.24266094738807843860E-3;
E6 = 2.71155556874348757815E-5;
E7 = 2.01033439929228813265E-7;
F1 = 5.99832206555887937690E-1;
F2 = 1.36929880922735805310E-1;
F3 = 1.48753612908506148525E-2;
F4 = 7.86869131145613259100E-4;
F5 = 1.84631831751005468180E-5;
F6 = 1.42151175831644588870E-7;
F7 = 2.04426310338993978564E-15;
%     HASH SUM EF    47.52583 31754 92896 71629

PHINV = zeros(size(P));
Q = ( 2*P - 1 )/2;
region1 =  abs(Q) <= SPLIT1;
k1 = find(region1);
if any(k1)
  R1 = CONST1 - Q(k1).^2;
  PHINV(k1) = Q(k1).*( ( ( ((((A7.*R1 + A6).*R1 + A5).*R1 + A4).*R1 + A3) ...
			   .*R1 + A2 ).*R1 + A1 ).*R1 + A0 )              ...
      ./( ( ( ((((B7.*R1 + B6).*R1 + B5).*R1 + B4).*R1 + B3)  ...
	      .*R1 + B2 ).*R1 + B1 ).*R1 + 1 );
end

k2 = find(~region1);
if any(k2)
  R2 = min( P(k2), 1 - P(k2) );
  k3 = find(R2>0);
  if any(k3) %         if ( R2 > 0 ) %THEN
    R3 = sqrt( -log(R2(k3)) );
    k4 = find(R3 <= SPLIT2);
    if any(k4)  %if ( R2 <= SPLIT2 ) % THEN
      R4 = R3(k4) - CONST2;
      PHINV(k2(k3(k4))) = ( ( ( ((((C7.*R4 + C6).*R4 + C5).*R4 + ...
				  C4).*R4 + C3).*R4 + C2 ).*R4 + ...
			      C1 ).*R4 + C0 )  ...
	  ./( ( ( ((((D7.*R4 + D6).*R4 + D5).*R4 + D4).*R4 + D3)  ...
		  .*R4 + D2 ).*R4 + D1 ).*R4 + 1 );
    end
    k5 = find(R3 > SPLIT2);
    if any(k5)
      R5 = R3(k5) - SPLIT2;
      PHINV(k2(k3(k5))) = ( ( ( ((((E7.*R5 + E6).*R5 + E5).*R5 + ...
				  E4).*R5 + E3).*R5 + E2 ).*R5 + ...
			      E1 ).*R5 + E0 ) ...
	  ./( ( ( ((((F7.*R5 + F6).*R5 + F5).*R5 + F4).*R5 + F3)  ...
		  .*R5 + F2 ).*R5 + F1 ).*R5 + 1 );
    end % IF
  end
  k6 = find(R2<=0);
  if any(k6)
    PHINV(k2(k6)) = inf;
  end %IF
  k7 = find(Q(k2)<0);
  if any(k7) %( Q < 0 ) %THEN
    PHINV(k2(k7)) = - PHINV(k2(k7));
  end %IF
end %IF

% The relative error of the approximation has absolute value less
% than 1.e-13.  One iteration of Halley's rational method (third
% order) gives full machine precision.
%k = find(0 < P & P < 1);
if 0 %any(k)
  e = wnormcdf(PHINV(k)) - P(k);          % error
  u = e * sqrt(2*pi) .* exp(PHINV(k).^2/2);        % f(z)/df(z)
  % Newton's method:
  %PHINV(k) = PHINV(k) - u; 
  % Halley's method:
  PHINV(k) = PHINV(k) - u./( 1 + PHINV(k).*u/2 );   
end
return



