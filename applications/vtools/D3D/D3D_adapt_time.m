%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18293 $
%$Date: 2022-08-10 18:25:55 +0200 (Wed, 10 Aug 2022) $
%$Author: chavarri $
%$Id: create_mat_map_2DH_ls_01.m 18293 2022-08-10 16:25:55Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_map_2DH_ls_01.m $
%
%

function [dt,Tstop,Flmap_dt,MorStt_app]=D3D_adapt_time(dt_des,tim_hydro_des,MorStt_des,MorFac,nparts_res)

tim_morpho_des=tim_hydro_des/MorFac; %desired morpho time
Flmap_dt_des=tim_morpho_des/nparts_res; %desired results interval
dt=Flmap_dt_des/ceil(Flmap_dt_des/dt_des);
Flmap_dt_app=Flmap_dt_des;
% Flmap_dt_ceil=ceil(Flmap_dt_des/dt).*dt; %ceiled results interval -> NO! otherwise simulations with different dt_des have different results interval!

% MorStt_app=MorStt_des;
MorStt_app=ceil(MorStt_des/dt)*dt; %start time ceiled with time step 
Tstop=MorStt_app+Flmap_dt_app.*nparts_res;
Flmap_dt=[MorStt_app,Flmap_dt_app];
