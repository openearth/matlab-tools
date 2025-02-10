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
%This function stems from script `main04_derive_boundary_files.m` in
%<28_get_partition_pli_grave_lith>.

function write_subdomain_bc_dir(fdir_hydro_sim,fname_h,fname_q,fname_ext,fpath_crs,fpath_obs,fdir_out_BC,fpathrel_bc,fpathrel_pli,time_start,boundaries,fpath_enc_crs)

ncases=numel(fdir_hydro_sim);

is_internal=0;

for kcase = 1:ncases

    simdef=D3D_simpath(fdir_hydro_sim{kcase});
    fpath_ext=simdef.file.extforcefilenew;
    fpath_map=simdef.file.map;

    write_subdomain_bc(fpath_map,fpath_crs,fpath_obs,fpath_ext,fdir_out_BC,fpathrel_bc,fpathrel_pli,fname_h{kcase},fname_q{kcase},fname_ext{kcase},time_start,is_internal,boundaries,fpath_enc_crs);
end

end %function