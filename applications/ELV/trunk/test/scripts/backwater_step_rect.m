%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%

function H = backwater_step_rect(h,ib,Cf,Q,B,dBdx,input)
% Computes just one step of the solver
% u,h,etab,Cf should be single values;

b1 = 0;
b2 = dBdx;
alpha_b = 1;
a1 = 0;
a2 = 0;
R = h;
Af = B*h;

%H = h - input.grd.dx*(b2*alpha_b*Q^2/Af^2-a2*Q^2/Af+input.mdv.g*Af*ib-Cf*abs(Q)*Q/(R*Af))/(-b1*alpha_b*Q^2/Af^2+a1*Q^2/Af +input.mdv.g*Af);
H = h - input.grd.dx*(ib - Cf.*Q.^2./(B.^2.*input.mdv.g.*h.^3)+Q.^2./(input.mdv.g*B^3.*h.^2).*dBdx)./(1-Cf.*Q.^2./(B.^2.*input.mdv.g.*h.^3));
end
