%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19877 $
%$Date: 2024-11-07 12:42:34 +0100 (Thu, 07 Nov 2024) $
%$Author: ottevan $
%$Id: write_subdomain_bc.m 19877 2024-11-07 11:42:34Z ottevan $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/morpho_setup/write_subdomain_bc.m $
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


