%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19229 $
%$Date: 2023-11-03 13:13:41 +0100 (Fri, 03 Nov 2023) $
%$Author: chavarri $
%$Id: gdm_read_data_his.m 19229 2023-11-03 12:13:41Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_data_his.m $
%
%

function data=gdm_data_at_elevation(data,data_z,elevation)

%   -t_sim: simulation time [nT,1]
%   -z_sim: simulation elevation [nT,nl]
%   -v_sim: simulation values [nT,nl]
%   -t_mea: measurements time [nt,1]
%   -z_mea: measurements elevation [nt,1]

t_sim=data.times;
z_sim=squeeze(data_z.val);
v_sim=squeeze(data.val);
t_mea=data.times;
z_mea=repmat(elevation,numel(t_mea),1);

v_sim_atmea=interpolate_xy_structured(t_sim,z_sim,v_sim,t_mea,z_mea);

data.val=v_sim_atmea;

end %function