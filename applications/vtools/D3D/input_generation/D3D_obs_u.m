%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%obs file creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_obs(simdef)
%% RENAME

dire_sim=simdef.D3D.dire_sim;

obs_cord=simdef.mdf.obs_cord;
obs_name=simdef.mdf.obs_name;

np=size(simdef.mdf.obs_cord,1); %number of observation points

%% FILE

for kp=1:np
data{kp, 1}=sprintf('%0.7E  %0.7E ''%s''',obs_cord(kp,1),obs_cord(kp,2),obs_name{kp});
end

%% WRITE

file_name=fullfile(dire_sim,'obs.xyn');
writetxt(file_name,data)

