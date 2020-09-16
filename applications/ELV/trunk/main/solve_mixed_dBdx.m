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
function obj = solve_mixed_dBdx(X,input,Fak_old, Qbk, dQbkdu, h_old, Fr_old, u_old, pq, K, AL, dxi, dq,Bloc, dBdxloc)
%solve_mixed computes an update of the space marching algorithm
% VERSION 3

%INPUT:
%   -input
%
%OUTPUT:
%   -

%HISTORY:
%

ib = X(1,1);
dFak = X(2:end,:);

c_f = input.frc.Cf;
nf = input.mdv.nf; 

% flow variables
htemp = h_old - (ib - c_f.*Fr_old.^2 + Fr_old.^2.*h_old./Bloc.*dBdxloc)./(1-Fr_old.^2)*dxi;
     
% check total load
Fak_new = Fak_old + dFak'*dxi;
Mak_new = repmat(Fak_new.*input.mor.La,K,1);
%Mak_new = Fak_new;
Cf = input.frc.Cf.*ones(1,K);
La = ones(1,K);
qbk_new = sediment_transport(input.aux.flg,input.aux.cnt,htemp,dq,Cf,La,Mak_new,input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,NaN(1,2),NaN(1,2),NaN,NaN,NaN);                    
CL = sum(repmat(pq,1,nf).*qbk_new,1);

% objective
obj = AL-CL;
end

