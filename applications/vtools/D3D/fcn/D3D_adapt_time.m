%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18496 $
%$Date: 2022-10-28 18:21:27 +0200 (Fri, 28 Oct 2022) $
%$Author: chavarri $
%$Id: D3D_adapt_time.m 18496 2022-10-28 16:21:27Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/D3D_adapt_time.m $
%
%

function [dt,Tstop,Flmap_dt,MorStt_app]=D3D_adapt_time(dt_des,tim_hydro_des,MorStt_des,MorFac,nparts_res)

tim_morpho_des=tim_hydro_des/MorFac; %desired morpho time
Flmap_dt_des=tim_morpho_des/nparts_res; %desired results interval
% dt_des=round(dt_des,4);
dt=Flmap_dt_des/ceil(Flmap_dt_des/dt_des);
% dt=Flmap_dt_des/round(ceil(Flmap_dt_des/dt_des),4);
% dt=round(dt,4);

Flmap_dt_app=Flmap_dt_des;
% Flmap_dt_ceil=ceil(Flmap_dt_des/dt).*dt; %ceiled results interval -> NO! otherwise simulations with different dt_des have different results interval

% MorStt_app=MorStt_des;
MorStt_app=ceil(MorStt_des/dt)*dt; %start time ceiled with time step 
% Tstop=MorStt_app+Flmap_dt_app.*nparts_res;
Tstop=MorStt_app+Flmap_dt_app.*nparts_res;
Flmap_dt=[MorStt_app,Flmap_dt_app];

if rem(Flmap_dt(2),dt)+rem(Tstop,dt)+rem(MorStt_app,dt)~=0
    error('All of them should be 0')
end
