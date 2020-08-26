
function dens = density_of_seawater(T,S,P)

% SW_DENS    Density of sea water
%=========================================================================
% SW_DENS  $Revision$  $Date$
%          Copyright (C) CSIRO, Phil Morgan 1992.
%
% USAGE:  dens = density_of_seawater(T,S,P)
%
% DESCRIPTION:
%    Density of Sea Water using UNESCO 1983 (EOS 80) polynomial.
%
% INPUT:  (all must have same dimensions)
%   S = salinity    [psu      (PSS-78)]
%   T = temperature [degree C (IPTS-68)]
%   P = pressure    [db]
%       (P may have dims 1x1, mx1, 1xn or mxn for S(mxn) )
%
% OUTPUT:
%   dens = density  [kg/m^3] 
% 
% AUTHOR:  Phil Morgan 92-11-05  (morgan@ml.csiro.au)
%
% DISCLAIMER:
%   This software is provided "as is" without warranty of any kind.  
%   See the file sw_copy.m for conditions of use and licence.
%
% REFERENCES:
%    Fofonoff, P. and Millard, R.C. Jr
%    Unesco 1983. Algorithms for computation of fundamental properties of 
%    seawater, 1983. _Unesco Tech. Pap. in Mar. Sci._, No. 44, 53 pp.
%
%    Millero, F.J., Chen, C.T., Bradshaw, A., and Schleicher, K.
%    " A new high pressure equation of state for seawater"
%    Deap-Sea Research., 1980, Vol27A, pp255-264.
%=========================================================================

% CALLER: general purpose
% CALLEE: sw_dens0.m sw_seck.m

% UNESCO 1983. eqn.7  p.15

%----------------------
% CHECK INPUT ARGUMENTS
%----------------------
if nargin ~=3
   error('sw_dens.m: Must pass 3 parameters')
end %if

% CHECK S,T,P dimensions and verify consistent
[ms,ns] = size(S);
[mt,nt] = size(T);
[mp,np] = size(P);

  
% CHECK THAT S & T HAVE SAME SHAPE
if (ms~=mt) | (ns~=nt)
   error('check_stp: S & T must have same dimensions')
end %if

% CHECK OPTIONAL SHAPES FOR P
if     mp==1  & np==1      % P is a scalar.  Fill to size of S
   P = P(1)*ones(ms,ns);
elseif np==ns & mp==1      % P is row vector with same cols as S
   P = P( ones(1,ms), : ); %   Copy down each column.
elseif mp==ms & np==1      % P is column vector
   P = P( :, ones(1,ns) ); %   Copy across each row
elseif mp==ms & np==ns     % PR is a matrix size(S)
   % shape ok 
else
   error('check_stp: P has wrong dimensions')
end %if
[mp,np] = size(P);
 

  
% IF ALL ROW VECTORS ARE PASSED THEN LET US PRESERVE SHAPE ON RETURN.
Transpose = 0;
if mp == 1  % row vector
   P       =  P(:);
   T       =  T(:);
   S       =  S(:);   

   Transpose = 1;
end %if
%***check_stp

%------
% BEGIN
%------
densP0 = sw_dens0(S,T);
K      = sw_seck(S,T,P);
P      = P/10;  % convert from db to atm pressure units
dens   = densP0./(1-P./K);

if Transpose
   dens = dens';
end %if

return
%--------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function dens = sw_dens0(S,T)

% SW_DENS0   Denisty of sea water at atmospheric pressure
%=========================================================================
% SW_DENS0  $Revision$  $Date$
%           Copyright (C) CSIRO, Phil Morgan 1992
%
% USAGE:  dens0 = sw_dens0(S,T)
%
% DESCRIPTION:
%    Density of Sea Water at atmospheric pressure using
%    UNESCO 1983 (EOS 1980) polynomial.
%
% INPUT:  (all must have same dimensions)
%   S = salinity    [psu      (PSS-78)]
%   T = temperature [degree C (IPTS-68)]
%
% OUTPUT:
%   dens0 = density  [kg/m^3] of salt water with properties S,T,
%           P=0 (0 db gauge pressure)
% 
% AUTHOR:  Phil Morgan 92-11-05  (morgan@ml.csiro.au)
%
% DISCLAIMER:
%   This software is provided "as is" without warranty of any kind.  
%   See the file sw_copy.m for conditions of use and licence.
%
% REFERENCES:
%     Unesco 1983. Algorithms for computation of fundamental properties of 
%     seawater, 1983. _Unesco Tech. Pap. in Mar. Sci._, No. 44, 53 pp.
%
%     Millero, F.J. and  Poisson, A.
%     International one-atmosphere equation of state of seawater.
%     Deep-Sea Res. 1981. Vol28A(6) pp625-629.
%=========================================================================

% CALLER: general purpose, sw_dens.m
% CALLEE: sw_smow.m

%----------------------
% CHECK INPUT ARGUMENTS
%----------------------
if nargin ~=2
   error('sw_dens0.m: Must pass 2 parameters')
end %if

[mS,nS] = size(S);
[mT,nT] = size(T);

if (mS~=mT) | (nS~=nT)
   error('sw_dens0.m: S,T inputs must have the same dimensions')
end %if

Transpose = 0;
if mS == 1  % a row vector
  S = S(:);
  T = T(:);
  Transpose = 1;
end %if

%----------------------
% DEFINE CONSTANTS
%----------------------
%     UNESCO 1983 eqn(13) p17.

b0 =  8.24493e-1;
b1 = -4.0899e-3;
b2 =  7.6438e-5;
b3 = -8.2467e-7;
b4 =  5.3875e-9;

c0 = -5.72466e-3;
c1 = +1.0227e-4;
c2 = -1.6546e-6;

d0 = 4.8314e-4;

%$$$ dens = sw_smow(T) + (b0 + b1*T + b2*T.^2 + b3*T.^3 + b4*T.^4).*S  ...
%$$$                    + (c0 + c1*T + c2*T.^2).*S.*sqrt(S) + d0*S.^2;

dens = sw_smow(T) + (b0 + (b1 + (b2 + (b3 + b4*T).*T).*T).*T).*S  ...
                   + (c0 + (c1 + c2*T).*T).*S.*sqrt(S) + d0*S.^2;	       

if Transpose
  dens = dens';
end %if

return
%--------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function K = sw_seck(S,T,P)

% SW_SECK    Secant bulk modulus (K) of sea water
%=========================================================================
% SW_SECK  $Revision$  $Date$
%          Copyright (C) CSIRO, Phil Morgan 1992.
%
% USAGE:  dens = sw_seck(S,T,P)
%
% DESCRIPTION:
%    Secant Bulk Modulus (K) of Sea Water using Equation of state 1980. 
%    UNESCO polynomial implementation.
%
% INPUT:  (all must have same dimensions)
%   S = salinity    [psu      (PSS-78) ]
%   T = temperature [degree C (IPTS-68)]
%   P = pressure    [db]
%       (alternatively, may have dimensions 1*1 or 1*n where n is columns in S)
%
% OUTPUT:
%   K = Secant Bulk Modulus  [bars]
% 
% AUTHOR:  Phil Morgan 92-11-05  (morgan@ml.csiro.au)
%
% DISCLAIMER:
%   This software is provided "as is" without warranty of any kind.  
%   See the file sw_copy.m for conditions of use and licence.
%
% REFERENCES:
%    Fofonoff, P. and Millard, R.C. Jr
%    Unesco 1983. Algorithms for computation of fundamental properties of 
%    seawater, 1983. _Unesco Tech. Pap. in Mar. Sci._, No. 44, 53 pp.
%    Eqn.(15) p.18
%
%    Millero, F.J. and  Poisson, A.
%    International one-atmosphere equation of state of seawater.
%    Deep-Sea Res. 1981. Vol28A(6) pp625-629.
%=========================================================================

% CALLER: sw_dens.m
% CALLEE: none

%----------------------
% CHECK INPUT ARGUMENTS
%----------------------
if nargin ~=3
   error('sw_seck.m: Must pass 3 parameters')
end %if

% CHECK S,T,P dimensions and verify consistent
[ms,ns] = size(S);
[mt,nt] = size(T);
[mp,np] = size(P);

  
% CHECK THAT S & T HAVE SAME SHAPE
if (ms~=mt) | (ns~=nt)
   error('check_stp: S & T must have same dimensions')
end %if

% CHECK OPTIONAL SHAPES FOR P
if     mp==1  & np==1      % P is a scalar.  Fill to size of S
   P = P(1)*ones(ms,ns);
elseif np==ns & mp==1      % P is row vector with same cols as S
   P = P( ones(1,ms), : ); %   Copy down each column.
elseif mp==ms & np==1      % P is column vector
   P = P( :, ones(1,ns) ); %   Copy across each row
elseif mp==ms & np==ns     % PR is a matrix size(S)
   % shape ok 
else
   error('check_stp: P has wrong dimensions')
end %if
[mp,np] = size(P);
 

  
% IF ALL ROW VECTORS ARE PASSED THEN LET US PRESERVE SHAPE ON RETURN.
Transpose = 0;
if mp == 1  % row vector
   P       =  P(:);
   T       =  T(:);
   S       =  S(:);   

   Transpose = 1;
end %if
%***check_stp

%--------------------------------------------------------------------
% COMPUTE COMPRESSION TERMS
%--------------------------------------------------------------------
P = P/10;  %convert from db to atmospheric pressure units

% Pure water terms of the secant bulk modulus at atmos pressure.
% UNESCO eqn 19 p 18

h3 = -5.77905E-7;
h2 = +1.16092E-4;
h1 = +1.43713E-3;
h0 = +3.239908;   %[-0.1194975];

%AW = h0 + h1*T + h2*T.^2 + h3*T.^3;
AW  = h0 + (h1 + (h2 + h3.*T).*T).*T;

k2 =  5.2787E-8;
k1 = -6.12293E-6;
k0 =  +8.50935E-5;   %[+3.47718E-5];

BW  = k0 + (k1 + k2*T).*T;
%BW = k0 + k1*T + k2*T.^2;

e4 = -5.155288E-5;
e3 = +1.360477E-2;
e2 = -2.327105;
e1 = +148.4206;
e0 = 19652.21;    %[-1930.06];

KW  = e0 + (e1 + (e2 + (e3 + e4*T).*T).*T).*T;   % eqn 19
%KW = e0 + e1*T + e2*T.^2 + e3*T.^3 + e4*T.^4;

%--------------------------------------------------------------------
% SEA WATER TERMS OF SECANT BULK MODULUS AT ATMOS PRESSURE.
%--------------------------------------------------------------------
j0 = 1.91075E-4;
       
i2 = -1.6078E-6;
i1 = -1.0981E-5;
i0 =  2.2838E-3;

SR = sqrt(S);

A  = AW + (i0 + (i1 + i2*T).*T + j0*SR).*S; 
%A = AW + (i0 + i1*T + i2*T.^2 + j0*SR).*S;  % eqn 17
  

m2 =  9.1697E-10;
m1 = +2.0816E-8;
m0 = -9.9348E-7;

B = BW + (m0 + (m1 + m2*T).*T).*S;   % eqn 18
%B  = BW + (m0 + m1*T + m2*T.^2).*S;   % eqn 18

    
f3 =  -6.1670E-5;
f2 =  +1.09987E-2;
f1 =  -0.603459;
f0 = +54.6746;

g2 = -5.3009E-4;
g1 = +1.6483E-2;
g0 = +7.944E-2;

K0 = KW + (  f0 + (f1 + (f2 + f3*T).*T).*T ...
        +   (g0 + (g1 + g2*T).*T).*SR         ).*S;      % eqn 16

%K0  = KW + (f0 + f1*T + f2*T.^2 + f3*T.^3).*S ...
%         + (g0 + g1*T + g2*T.^2).*SR.*S;             % eqn 16

K = K0 + (A + B.*P).*P;  % eqn 15

if Transpose
   K = K';
end %if

return
%----------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function dens = sw_smow(T)

% SW_SMOW    Denisty of standard mean ocean water (pure water)
%=========================================================================
% SW_SMOW  $Revision$  $Date$
%          Copyright (C) CSIRO, Phil Morgan 1992.
%
% USAGE:  dens = sw_smow(T)
%
% DESCRIPTION:
%    Denisty of Standard Mean Ocean Water (Pure Water) using EOS 1980. 
%
% INPUT: 
%   T = temperature [degree C (IPTS-68)]
%
% OUTPUT:
%   dens = density  [kg/m^3] 
% 
% AUTHOR:  Phil Morgan 92-11-05  (morgan@ml.csiro.au)
%
% DISCLAIMER:
%   This software is provided "as is" without warranty of any kind.  
%   See the file sw_copy.m for conditions of use and licence.
%
% REFERENCES:
%     Unesco 1983. Algorithms for computation of fundamental properties of 
%     seawater, 1983. _Unesco Tech. Pap. in Mar. Sci._, No. 44, 53 pp.
%     UNESCO 1983 p17  Eqn(14)
%
%     Millero, F.J & Poisson, A.
%     INternational one-atmosphere equation of state for seawater.
%     Deep-Sea Research Vol28A No.6. 1981 625-629.    Eqn (6)
%=========================================================================

%----------------------
% CHECK INPUT ARGUMENTS
%----------------------
% TEST INPUTS
if nargin ~= 1
   error('sw_smow.m: Only one input argument allowed')
end %if

Transpose = 0;
[mT,nT] = size(T);
if mT == 1 % a row vector
   T = T(:);
   Tranpose = 1;
end %if

%----------------------
% DEFINE CONSTANTS
%----------------------
a0 = 999.842594;
a1 =   6.793952e-2;
a2 =  -9.095290e-3;
a3 =   1.001685e-4;
a4 =  -1.120083e-6;
a5 =   6.536332e-9;

dens = a0 + (a1 + (a2 + (a3 + (a4 + a5*T).*T).*T).*T).*T;

if Transpose
  dens = dens';
end %if

return
%--------------------------------------------------------------------

