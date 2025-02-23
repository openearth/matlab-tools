%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20039 $
%$Date: 2025-02-07 16:34:32 +0100 (Fri, 07 Feb 2025) $
%$Author: chavarri $
%$Id: plot_map_2DH_ls_01.m 20039 2025-02-07 15:34:32Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_map_2DH_ls_01.m $
%
%

function flg_loc=gdm_parse_map_2DH_ls(flg_loc)

flg_loc=isfield_default(flg_loc,'do_p_single',1);
flg_loc=isfield_default(flg_loc,'do_all_t',0);
flg_loc=isfield_default(flg_loc,'do_all_t_xt',0);
flg_loc=isfield_default(flg_loc,'do_all_s',0);
flg_loc=isfield_default(flg_loc,'do_diff_t',0);
flg_loc=isfield_default(flg_loc,'do_diff_s',0);
flg_loc=isfield_default(flg_loc,'do_all_s_diff_t',0);
flg_loc=isfield_default(flg_loc,'do_all_t_diff_t',0);
flg_loc=isfield_default(flg_loc,'do_all_s_2diff',0); %plot all runs in same figure making the difference between each of 2 simulations

flg_loc=isfield_default(flg_loc,'use_local_time',0); %plot all runs in same figure making the difference between each of 2 simulations
flg_loc=isfield_default(flg_loc,'fig_print',1);
flg_loc=isfield_default(flg_loc,'do_staircase',0);
flg_loc=isfield_default(flg_loc,'do_movie',0);
flg_loc=isfield_default(flg_loc,'ylims',[NaN,NaN]);
flg_loc=isfield_default(flg_loc,'xlims',NaN(size(flg_loc.ylims,1),2));
flg_loc=isfield_default(flg_loc,'ylims_diff_t',flg_loc.ylims);
flg_loc=isfield_default(flg_loc,'ylims_diff_s',flg_loc.ylims);
flg_loc=isfield_default(flg_loc,'clims',[NaN,NaN]);
flg_loc=isfield_default(flg_loc,'clims_diff_t',flg_loc.clims);
flg_loc=isfield_default(flg_loc,'clims_diff_s',flg_loc.clims);
flg_loc=isfield_default(flg_loc,'do_diff',1);
flg_loc=isfield_default(flg_loc,'tim_type',1);
flg_loc=isfield_default(flg_loc,'plot_val0',0);
flg_loc=isfield_default(flg_loc,'TolMinDist',1000);
flg_loc=isfield_default(flg_loc,'tol_t',5/60/24);
flg_loc=isfield_default(flg_loc,'var_idx',cell(1,numel(flg_loc.var)));

if isfield(flg_loc,'do_rkm')==0
    if isfield(flg_loc,'fpath_rkm')
        flg_loc.do_rkm=1;
    else
        flg_loc.do_rkm=0;
    end
end
if flg_loc.do_rkm==1
    if ~isfield(flg_loc,'fpath_rkm')
        error('Provide rkm file')
    elseif exist(flg_loc.fpath_rkm,'file')~=2
        error('rkm file does not exist')
    end
end

if flg_loc.do_staircase
    flg_loc.str_val='val_staircase';
else
    flg_loc.str_val='val';
end

end %function