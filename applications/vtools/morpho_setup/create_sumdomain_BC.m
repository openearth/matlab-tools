%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20049 $
%$Date: 2025-02-15 17:44:52 +0100 (Sat, 15 Feb 2025) $
%$Author: chavarri $
%$Id: write_subdomain_bc_dir.m 20049 2025-02-15 16:44:52Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/morpho_setup/write_subdomain_bc_dir.m $
%
%
%
%INPUT:
%   - 
%
%OUTPUT:
%

function create_sumdomain_BC(fdir_in,fdir_name_1dt,fpath_bc_crs,fdir_out_BC,fpath_enc,bc_type,fdir_hydro_sim,fname_h,fname_q,fname_ext,fpathrel_bc,fpathrel_pli,time_start)

%%

messageOut(NaN,'Start creating mdf-file with additional cross-section.',2)
fdir_out_1dt=create_mdf_with_crs(fdir_in,fdir_name_1dt,fpath_bc_crs);

%%

messageOut(NaN,'Start running 1 timestep simulation.',2)
run_simulation_get_shp(fdir_out_1dt)

%%

messageOut(NaN,'Start getting observations stations and cross-sections.',2)

mkdir_check(fdir_out_BC);
fpath_obs=fullfile(fdir_out_BC,'obs.xyn');
fpath_crs_h=fullfile(fdir_out_BC,'crs_h.pli');
fpath_crs_q=fullfile(fdir_out_BC,'crs_q.pli');

boundaries=create_observation_locations(fdir_out_1dt,fpath_obs,fpath_crs_h,fpath_crs_q,fpath_enc,bc_type);

%%

messageOut(NaN,'Start getting observations stations and cross-sections.',2)
write_subdomain_bc_dir(fdir_hydro_sim,fname_h,fname_q,fname_ext,fpath_crs_h,fpath_crs_q,fpath_obs,fdir_out_BC,fpathrel_bc,fpathrel_pli,time_start,boundaries,fpath_enc);

end %function


