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
%E.G.:
%
% fdir_in='p:\11210364-003-maas-mor\C_Work\01_Model_40m\dflowfm2d-maas-j21_6-v1a\computations\test\S1500_clean'; 
% fdir_name_1dt='Lixhe-Roermond_crs_to_shp';
% 
% fdir_out_BC=fullfile(fpaths.fdir_work,'05_subdomain_BC'); 
% fpath_enc=fullfile(fpaths.fdir_work,'03_LixheRoermond','geometry','lr7_enc.pol'); 
% fpath_bc_crs=fullfile(fpaths.fdir_work,'03_LixheRoermond','geometry','crs_bc_all_03.pli'); 
% bc_type={'h','q'}; %in fpath_bc_crs there are N cross-section. You need to specify if you want it to be a q or an h BC 
% 
% time_start=datetime(2035,01,01,0,0,0,'TimeZone','+01:00');
% 
% fpathrel_bc=sprintf('bc/');
% fpathrel_pli=sprintf('pli/');
% 
% fdir_hydro_sim_all='p:/11210364-003-maas-mor/C_Work/01_Model_40m/dflowfm2d-maas-j21_6-v1a/computations/test/';
% cases={'S_500', 'S_125', 'S_250', 'S_750', 'S1000', 'S1300', 'S1500', 'S1700', 'S2100',  'S2500', 'S2800', 'S3200'}; % }; % } %, 'S_250', 'S2500', 'S_125', 'S_500', 'S_750', 'S1300', 'S1700', 'S2100', 'S2800', 'S1500', 'S3200'}; % 'S1500_rtcw06'
% ncases=numel(cases);
% fdir_hydro_sim=cell(ncases,1);
% fname_h=cell(ncases,1);
% fname_q=cell(ncases,1);
% fname_ext=cell(ncases,1);
% 
% for kcase=1:ncases
%     model_case=cases{kcase};
% 
%     fdir_hydro_sim{kcase}=fullfile(fdir_hydro_sim_all,sprintf('%s',model_case));
%     fname_h{kcase}=sprintf('h_%s',model_case);
%     fname_q{kcase}=sprintf('q_%s',model_case);
%     fname_ext{kcase}=sprintf('ext_%s',model_case);
% end

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


