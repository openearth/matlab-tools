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
%
%INPUT:
%   - 
%
%OUTPUT:
%
%OPTIONAL PAIR INPUT:
%   - 
%
%HISTORY:
%
%This function contains all steps stems from script `main04_derive_boundary_files.m` in
%<28_get_partition_pli_grave_lith>.

function create_subdomain_BC(fdir_in,fdir_out,fpath_crs)

%%

create_mdf_with_crs(fdir_in,fdir_out_1dt,fpath_enc_crs)

%%

run_simulation_get_shp(fdir_out_1dt)

%%

create_observation_locations(fdir_out_1dt,fpath_obs,fpath_crs,fpath_enc_crs);

%%

write_subdomain_bc_dir(fdir_hydro_sim,fname_h,fname_q,fname_ext)

end %function


