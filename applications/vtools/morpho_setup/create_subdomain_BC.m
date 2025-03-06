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

function create_subdomain_BC(fdir_in,fdir_name_1dt,fpath_bc_crs,fdir_out_BC,fpath_enc,bc_type,fdir_hydro_sim,fname_h,fname_q,fname_ext,fpathrel_bc,fpathrel_pli,time_start,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fpath_exe','c:\Program Files\Deltares\Delft3D FM Suite 2024.03 HMWQ\plugins\DeltaShell.Dimr\kernels\x64\bin\run_dimr.bat');

parse(parin,varargin{:});

fpath_exe=parin.Results.fpath_exe;

%%

messageOut(NaN,'Start creating mdf-file with additional cross-section.',2)
fdir_out_1dt=create_mdf_with_crs(fdir_in,fdir_name_1dt,fpath_bc_crs);

%%

messageOut(NaN,'Start running 1 timestep simulation.',2)
run_simulation_get_shp(fdir_out_1dt,'fpath_exe',fpath_exe)

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


