%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18344 $
%$Date: 2022-08-31 16:59:35 +0200 (Wed, 31 Aug 2022) $
%$Author: chavarri $
%$Id: plot_map_2DH_01.m 18344 2022-08-31 14:59:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_map_2DH_01.m $
%
%

function plot_grid_01(fid_log,flg_loc,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

if isfield(flg_loc,'clims')==0
    flg_loc.clims=[NaN,NaN];
    flg_loc.clims_diff_t=[NaN,NaN];
end

if isfield(flg_loc,'xlims')==0
    flg_loc.xlims=[NaN,NaN];
    flg_loc.ylims=[NaN,NaN];
end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fdir_fig=fullfile(simdef.file.fig.dir,tag_fig,tag_serie);
mkdir_check(fdir_fig);
% fpath_map=simdef.file.map;
% fpath_grd=simdef.file.mat.grd;
fpath_grd=simdef.file.grd;
runid=simdef.file.runid;

%% LOAD

gridInfo=gdm_load_grid(fid_log,fdir_mat,'');
[ismor,is1d,str_network1d,issus]=D3D_is(fpath_grd);

%% DIMENSIONS

nclim=size(flg_loc.clims,1);
nxlim=size(flg_loc.xlims,1);
nvar=1; %for when we plot orthogonality

%%

[xlims_all,ylims_all]=D3D_gridInfo_lims(gridInfo);

%figures
in_p=flg_loc;
% in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
% in_p.fig_visible=0;
in_p.gridInfo=gridInfo;

fext=ext_of_fig(in_p.fig_print);

%ldb
if isfield(flg_loc,'fpath_ldb')
    in_p.ldb=D3D_read_ldb(flg_loc.fpath_ldb);
end

for kvar=1:nvar %variable
%     varname=flg_loc.var{kvar};
%     var_str=D3D_var_num2str_structure(varname,simdef);
      var_str='grid';
        
        for kclim=1:nclim
            for kxlim=1:nxlim

                %xlim
                xlims=flg_loc.xlims(kxlim,:);
                ylims=flg_loc.ylims(kxlim,:);
                if isnan(xlims(1))
                    xlims=xlims_all;
                    ylims=ylims_all;
                end
                in_p.xlims=xlims;
                in_p.ylims=ylims;

                fname_noext=fig_name(fdir_fig,tag,runid,kclim,var_str,kxlim);

                in_p.fname=fname_noext;
                
                switch simdef.D3D.structure
                    case 1
                        error('do. I think that reading with EHY should pass to the case of FM')
                    case 2
                        if is1d 
                            fig_grid_1D_01(in_p);
                        else
                            fig_grid_2D_01(in_p);
                        end
                end
                    
            end%kxlim
        end %kclim
        
end %kvar

end %function

%% 
%% FUNCTION
%%

function fpath_fig=fig_name(fdir_fig,tag,runid,kclim,var_str,kxlim)

fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s_clim_%02d_xlim_%02d',tag,runid,var_str,kclim,kxlim));

end %function