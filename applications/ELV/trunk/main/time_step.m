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

%dt=NaN occurs when the celerities are NaN, which happen when morpho changes
%have not started but flow is steadt
if isnan(dt) 
    dt=input.mdv.dt;
else
    input.mdv.dt=dt;
end

time_l=time_l+dt;

end %function time_step
