%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16573 $
%$Date: 2020-09-08 16:03:40 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: aux_bfc.m 16573 2020-09-08 14:03:40Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/main/aux_bfc.m $
%
%aux_bfc is an auxiliary function of bed_form_corection to apply the correction from Smith and McLean (1977), Spatially Avergaed Flow over a wavy surface, JGR: ES, 82(12) 1735--1746
%
%\texttt{F=aux_swc(X,u,Sf,input)}
%
%INPUT:
%	-X = 
%	-u = 
%	-Sf =
%   -input = 
%
%OUTPUT:
%   -F = 
%
%HISTORY:
%170315
%   -V. Created for the first time.
%
function F=aux_bfc(X,u_st_b,input_i)

%% RENAME

u_st_ibl=X(1);
u_st_obl=X(2);

rho=input_i.mdv.rhow;
dk=input_i.sed.dk;
nk=input_i.frc.nk;
H=input_i.frc.H;
L=input_i.frc.L;

d=max(dk);
A=0.077;
tau_c=0.047;
a1=0.3;
Cd=0.212;
k=0.41;

%% OBJ

z0n=nk*d;
tau=rho*u_st_ibl^2;
tau_f=tau/tau_c;
z01=z0n;
z01(tau_f>1)=A*d*0.6*tau_f/(1+0.2*tau_f)+z01;

% F must be equal to 0
F(1)=u_st_b^2-u_st_ibl^2-u_st_obl^2;
F(2)=u_st_obl/u_st_ibl-sqrt(1+Cd/2/k^2*H/L*(log(a1*(L/z01)^0.8))^2); %Equation 11

