%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 137 $
%$Date: 2017-07-20 09:50:06 +0200 (Thu, 20 Jul 2017) $
%$Author: V $
%$Id: analytical_cubic_root.m 137 2017-07-20 07:50:06Z V $
%$HeadURL: https://repos.deltares.nl/repos/ELV/trunk/main/analytical_cubic_root.m $
%
%analytical_cubic_root returns the three roots of a cubic polynomial, provided they are real. The polynomial is ax^3+bx^2+cx+d=0.
%
%\texttt{root=analytical_cubic_root(a_coeff, b_coeff, c_coeff, d_coeff)}
%
%INPUT:
%   -\texttt{a_coeff} = a coefficient of the polynomial
%   -\texttt{b_coeff} = b coefficient of the polynomial
%   -\texttt{c_coeff} = c coefficient of the polynomial
%   -\texttt{d_coeff} = d coefficient of the polynomial
%
%OUTPUT:
%   -\texttt{root} = three roots
%
%HISTORY:
%

function root=analytical_cubic_root(a_coeff, b_coeff, c_coeff, d_coeff)

pp = -(b_coeff/a_coeff)^2/3 + (c_coeff/a_coeff);
qq = 2*(b_coeff/a_coeff)^3/27 - (b_coeff/a_coeff)/3 * (c_coeff/a_coeff) + (d_coeff/a_coeff);

%discriminant
Delta_discr=0.25*qq^2+pp^3/27;

if Delta_discr>0
	error('No solution of the backwater equation is found. Your CFL may be too large (check time step). You can also try again and again with the same input until automagically the problem is solved! :D')
end

theta_angle = atan2( sqrt(-Delta_discr), -0.5*qq  );

root=(2*sqrt(-pp/3)*cos(theta_angle/3+[0;2./3*3.141592653589793;4./3*3.141592653589793]))-(b_coeff/a_coeff)/3;


