%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 231 $
%$Date: 2020-04-06 16:00:58 +0200 (Mon, 06 Apr 2020) $
%$Author: chavarri $
%$Id: time_step.m 231 2020-04-06 14:00:58Z chavarri $
%$HeadURL: https://repos.deltares.nl/repos/ELV/trunk/main/time_step.m $
%
%time_step computes the time_step
%
%input_out=time_step(input,fid_log)
%
%INPUT:
%   -
%
%OUTPUT:
%   -
%
%HISTORY:
%181102
%   -V. Created for the first time.

function [input,time_l]=time_step(u,h,celerities,pmm,vpk,input,fid_log,kt,time_l)

%%
%% RENAME
%%

dx=input.grd.dx;
cfl=input.mdv.cfl;

%% 
%% COMPUTE
%%

c=celerities4CFL(u,h,celerities,pmm,vpk,input,fid_log,kt); %double[1,nx]
c_max=max(c);
dt=cfl/c_max*dx;

%% 
%% OUT
%%

input.mdv.dt=dt;
time_l=time_l+dt;

end %function time_step
