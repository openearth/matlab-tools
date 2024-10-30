%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19791 $
%$Date: 2024-09-23 06:11:48 +0200 (Mon, 23 Sep 2024) $
%$Author: chavarri $
%$Id: plot_map_2DH_diff_01.m 19791 2024-09-23 04:11:48Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_map_2DH_diff_01.m $
%

function [flg_loc,simdef]=gdm_parse_map_2DH(fid_log,flg_loc,simdef)

flg_loc=gdm_default_flags(flg_loc);

flg_loc=isfield_default(flg_loc,'do_p_single',1);
flg_loc=isfield_default(flg_loc,'do_diff_t',0);
flg_loc=isfield_default(flg_loc,'do_diff_s',0);
flg_loc=isfield_default(flg_loc,'do_diff_s_t',0);
flg_loc=isfield_default(flg_loc,'do_diff_s_perc',0);
flg_loc=isfield_default(flg_loc,'do_2D',1);
flg_loc=isfield_default(flg_loc,'do_3D',0);
flg_loc=isfield_default(flg_loc,'plot_tiles',0);
flg_loc=isfield_default(flg_loc,'fpath_tiles',fullfile(pwd,'tiles.mat'));
flg_loc=isfield_default(flg_loc,'do_movie',0);
flg_loc=isfield_default(flg_loc,'do_fxw',0);
flg_loc=isfield_default(flg_loc,'tim_type',1);
flg_loc=isfield_default(flg_loc,'var_idx',cell(1,numel(flg_loc.var)));
flg_loc=isfield_default(flg_loc,'sim_ref',1);
flg_loc=isfield_default(flg_loc,'xlims',[NaN,NaN]);
flg_loc=isfield_default(flg_loc,'ylims',[NaN,NaN]);

flg_loc=isfield_default(flg_loc,'write_shp',0);
if flg_loc.write_shp==1
    messageOut(fid_log,'You want to write shp files. Be aware it is quite expensive.')
end

%% clims

flg_loc=isfield_default(flg_loc,'clims_type',1);
flg_loc=isfield_default(flg_loc,'clims',[NaN,NaN]);
flg_loc=isfield_default(flg_loc,'clims_diff_t',[NaN,NaN]);
flg_loc=isfield_default(flg_loc,'clims_diff_s',[NaN,NaN]);
flg_loc=isfield_default(flg_loc,'clims_diff_s_t',[NaN,NaN]);
flg_loc=isfield_default(flg_loc,'clims_diff_s_perc',[NaN,NaN]);

if isfield(flg_loc,'filter_lim')==0
    flg_loc.filter_lim.clims=[inf,-inf];
    flg_loc.filter_lim.clims_diff_t=[inf,-inf];
    flg_loc.filter_lim.clims_diff_s=[inf,-inf];
    flg_loc.filter_lim.clims_diff_s_t=[inf,-inf];
    flg_loc.filter_lim.clims_diff_s_perc=[inf,-inf];
else
    flg_loc.filter_lim=isfield_default(flg_loc.filter_lim,'clims',[inf,-inf]);
    flg_loc.filter_lim=isfield_default(flg_loc.filter_lim,'clims_diff_t',[inf,-inf]);
    flg_loc.filter_lim=isfield_default(flg_loc.filter_lim,'clims_diff_s',[inf,-inf]);
    flg_loc.filter_lim=isfield_default(flg_loc.filter_lim,'clims_diff_s_t',[inf,-inf]);
    flg_loc.filter_lim=isfield_default(flg_loc.filter_lim,'clims_diff_s_perc',[inf,-inf]);
end

%%

flg_loc=gdm_parse_plot_along_rkm(flg_loc);

%% dimensions

flg_loc.nclim_max=max([size(flg_loc.clims,1),size(flg_loc.clims_diff_t,1),size(flg_loc.clims_diff_s,1),size(flg_loc.clims_diff_s_t,1),size(flg_loc.clims_diff_s_perc,1)]);
flg_loc.nsim=numel(simdef);
flg_loc.nxlim=size(flg_loc.xlims,1);
flg_loc.nvar=numel(flg_loc.var);

%% 

flg_loc.do_ref=0;
if flg_loc.nsim>1 && (flg_loc.do_diff_s || flg_loc.do_diff_s_t || flg_loc.do_diff_s_perc)
    flg_loc.do_ref=1;
end

%%
 %In 1D-2D simulations, the simulations is identified as 1D because it has 1D data. We have to force to
 %plot the 2D data if we are in `map_2DH`.
 if simdef(1).D3D.is1d
     messageOut(fid_log,'This seems a 1D-2D simulation, as you want to plot 2D data but there is 1D data in the results. Plotting 2D.')
     simdef(1).D3D.is1d=false;
 end

end %function