%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19692 $
%$Date: 2024-06-28 17:28:07 +0200 (Fri, 28 Jun 2024) $
%$Author: chavarri $
%$Id: gdm_create_mat_summerbed.m 19692 2024-06-28 15:28:07Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_create_mat_summerbed.m $
%
%Create a file and add a new polygon name with the difference that can be
%processed as all other polygons without any difference.

function create_mat_map_summerbed_diff(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

if isfield(flg_loc,'sb_pol')==0
    %2DO
    %if no input, all points taken.
    error('You need to specify the summerbed polygon')
end

flg_loc=gdm_parse_summerbed(flg_loc,simdef);

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fpath_map=simdef.file.map;
% fpath_rkm=flg_loc.fpath_rkm;

%% MEASUREMENTS

% %measured bed elevation
% if flg_loc.plot_mea
%     mea_etab=load(fpath_data);
% end
        
%% OVERWRITE

ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% LOAD TIME

[nt,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef);

%% CONSTANT IN TIME

% gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);
% data_ba=gdm_read_data_map(fdir_mat,fpath_map,'mesh2d_flowelem_ba');

%% DIMENSION

kt_v=gdm_kt_v(flg_loc,nt); %time index vector
nvar=numel(flg_loc.var);
nrkmv=numel(flg_loc.rkm_name);
nsb=numel(flg_loc.sb_pol_diff);

%% GRID

gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);

%% LOOP

ktc=0;
krkmv=0;
kvar=0;
ksb=0;
messageOut(fid_log,sprintf('Reading %s sb poly %4.2f %% rkm poly %4.2f %% time %4.2f %% variable %4.2f %%',tag,ksb/nsb*100,krkmv/nrkmv*100,ktc/nt*100,kvar/nvar*100));

for ksb=1:nsb

    %summerbed
    [sb_pol,sb_pol_1,sb_pol_2]=gdm_sb_pol_diff_name(flg_loc,ksb);

    for krkmv=1:nrkmv %rkm polygons
        
        % rkm_name=flg_loc.rkm_name{krkmv};
        % rkm_cen=flg_loc.rkm{krkmv}';
        % rkm_cen_br=flg_loc.rkm_br{krkmv,1};

        % rkmv=gdm_load_rkm_polygons(fid_log,tag,fdir_mat,fpath_map,fpath_rkm,rkm_cen,rkm_cen_br,rkm_name);
        % npol=numel(rkmv.rkm_cen);
        pol_name=flg_loc.rkm_name{krkmv};

        ktc=0;
        for kt=kt_v %time
            ktc=ktc+1;
                 
            for kvar=1:nvar %variable
                [varname_save_mat,varname_read_variable,varname_load_mat]=D3D_var_num2str_structure(flg_loc.var{kvar},simdef);
                
                layer=gdm_layer(flg_loc,gridInfo.no_layers,varname_save_mat,kvar,flg_loc.var{kvar}); 
                
                %name of file with new polygon
                fpath_mat_tmp=gdm_map_summerbed_mat_name(varname_load_mat,fdir_mat,tag,pol_name,time_dnum(kt),sb_pol,flg_loc.var_idx{kvar},layer);
                        
                %name of first polygon to make difference
                fpath_mat_1=gdm_map_summerbed_mat_name(varname_load_mat,fdir_mat,tag,pol_name,time_dnum(kt),sb_pol_1,flg_loc.var_idx{kvar},layer);

                %name of second polygon to make difference
                fpath_mat_2=gdm_map_summerbed_mat_name(varname_load_mat,fdir_mat,tag,pol_name,time_dnum(kt),sb_pol_2,flg_loc.var_idx{kvar},layer);

                if exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite ; continue; end

                data_1=load(fpath_mat_1,'data');
                data_2=load(fpath_mat_2,'data');
                
                data=struct();
                fn=fieldnames(data_1.data);
                nfn=numel(fn);
                for kfn=1:nfn
                    data.(fn{kfn})=data_1.data.(fn{kfn})-data_2.data.(fn{kfn});
                end

                %% save and disp
                save_check(fpath_mat_tmp,'data');
                messageOut(fid_log,sprintf('Reading %s sb poly %4.2f %% rkm poly %4.2f %% time %4.2f %% variable %4.2f %%',tag,ksb/nsb*100,krkmv/nrkmv*100,ktc/nt*100,kvar/nvar*100));

            end %kvar
        end %kt    
    end %nrkmv
end %ksb


end %function

%% 
%% FUNCTION
%%
