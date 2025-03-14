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

function create_mat_map_2DH_ls_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

flg_loc=gdm_parse_map_2DH_ls(flg_loc);

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
% fpath_map=simdef.file.map;

%% OVERWRITE

ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% DIMENSIONS

nvar=numel(flg_loc.var);
npli=numel(flg_loc.pli);

%% LOAD TIME

[nt,time_dnum,~,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef);
   
%% GRID

fpath_map=gdm_fpathmap(simdef,sim_idx(1));
gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);

%% LOOP TIME

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

ktc=0; kpli=0;
messageOut(fid_log,sprintf('Reading map_ls_01 pli %4.2f %% kt %4.2f %%',kpli/npli*100,ktc/nt*100));
for kt=kt_v
    ktc=ktc+1;
    for kpli=1:npli

        %pli name
        fpath_pli=flg_loc.pli{kpli,1};
        pliname=gdm_pli_name(fpath_pli);

        for kvar=1:nvar %variable
            if ~ischar(flg_loc.var{kvar})
                error('cannot read section along variables not from EHY')
            end
            varname=flg_loc.var{kvar};
            [varname_save_mat,varname_read_variable,~]=D3D_var_num2str_structure(varname,simdef);

            layer=gdm_layer(flg_loc,gridInfo.no_layers,varname_read_variable,kvar,flg_loc.var{kvar}); %we use <layer> for flow and sediment layers
            var_idx=flg_loc.var_idx{kvar};

            fpath_mat_tmp=gdm_map_2DH_ls_mat_name(fdir_mat,tag,time_dnum(kt),varname_save_mat,pliname,layer,var_idx);
            if exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite ; continue; end

            %% read data
            
            data=gdm_read_data_map_ls_simdef(fdir_mat,simdef,varname_read_variable,sim_idx(kt),layer,var_idx,'pli',fpath_pli,'tim',time_dnum(kt),'tol_t',flg_loc.tol_t,'overwrite',flg_loc.overwrite,'pliname',pliname); %this overwriting flag should be different than the previous one
            
            if flg_loc.do_rkm
                data.rkm_cor=convert2rkm(flg_loc.fpath_rkm,[data.Xcor,data.Ycor],'TolMinDist',flg_loc.TolMinDist);
                data.rkm_cen=convert2rkm(flg_loc.fpath_rkm,[data.Xcen,data.Ycen],'TolMinDist',flg_loc.TolMinDist);
            end
            
            save_check(fpath_mat_tmp,'data'); 
            messageOut(fid_log,sprintf('Reading %s kt %4.2f %% kpli %4.2f %% kvar %4.2f %%',tag,ktc/nt*100,kpli/npli*100,kvar/nvar*100));
        end
    end
end %kt

end %function

%% 
%% FUNCTION
%%
