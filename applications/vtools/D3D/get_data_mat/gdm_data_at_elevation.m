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
%

function data=gdm_data_at_elevation(data,data_z,elev)

%   -t_sim: simulation time [nT,1]
%   -z_sim: simulation elevation [nT,nl]
%   -v_sim: simulation values [nT,nl]
%   -t_mea: measurements time [nt,1]
%   -z_mea: measurements elevation [nt,1]

t_sim=data.times;
z_sim=squeeze(data_z.val);
v_sim=squeeze(data.val);
t_mea=data.times;
z_mea=repmat(elev,numel(t_mea),1);

v_sim_atmea=interpolate_xy_structured(t_sim,z_sim,v_sim,t_mea,z_mea);

data.val=v_sim_atmea;

end %function