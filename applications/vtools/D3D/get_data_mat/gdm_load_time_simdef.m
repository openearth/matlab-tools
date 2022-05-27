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

function [nt,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef)

if simdef.D3D.structure==4
    fpath_pass=simdef.D3D.dire_sim;
else
    fpath_pass=fpath_map;
end

[nt,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time(fid_log,flg_loc,fpath_mat_time,fpath_pass);

end %function
