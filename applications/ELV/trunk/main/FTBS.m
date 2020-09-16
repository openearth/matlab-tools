%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 246 $
%$Date: 2020-07-08 10:57:48 +0200 (Wed, 08 Jul 2020) $
%$Author: chavarri $
%$Id: FTBS.m 246 2020-07-08 08:57:48Z chavarri $
%$HeadURL: https://repos.deltares.nl/repos/ELV/branches/V0171/main/FTBS.m $
%
%forward in time backward in space numerical scheme to solve dc/dt+v*dc/dx=S1+S2*c
%
%\texttt{C_new=FTBS(C_old,v,S1,S2,input,fid_log)}
%
%INPUT:
%   -\texttt{Mak} = effective volume of sediment per unit of bed area in the active layer [m]; [(nf-1)x(nx) double]
%
%OUTPUT:
%   -\texttt{Mak_new} = new effective volume of sediment per unit of bed area in the active layer [m]; [(nf-1)x(nx) double]
%
%HISTORY:
%180511
%   -V. Created it for the first time

function C_new=FTBS(C_old,v,S1,S2,input,fid_log)

%%
%% RENAME
%%

dt=input.mdv.dt;
dx=input.grd.dx;
nx=input.mdv.nx; 

%outcome have size [nx,1]
alpha=v'*dt/dx;
gamma=dt*S1';
delta=dt*S2';
C_old=C_old';

%% COMPUTE
C_new=NaN(nx,1);
C_new(2:end)=(1-alpha(2:end)+delta(2:end)).*C_old(2:end)+alpha(2:end).*C_old(1:end-1)+gamma(2:end);

%boundary condition
C_new(1)=C_old(1);
