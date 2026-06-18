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

function create_mat_CRS(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

flg_loc=isfield_default(flg_loc,'overwrite',false);

%% PATHS

fdir_mat=simdef.file.fdir_mat;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fpath_map=gdm_fpathmap(simdef,0);

%% DIMENSIONS

% ncrs=numel(flg_loc.crs_name);
% crs_names=ncread(fpath_map,'mesh1d_mor_crs_name'); %all cross-section names in the map file. We will use this to find the index of the cross-sections we want to load in the loop below.

%% LOAD TIME

[nt,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef);

%% LOOP

kt_v=gdm_kt_v(flg_loc,nt); %time index vector
ktc=0;

for kt=kt_v 
    ktc=ktc+1;

    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt));

    do_read=1;
    if exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite 
        do_read=0;
    end

    %% read data
    if do_read
        data_n=EHY_getMapModelData(fpath_map,'varName','mesh1d_mor_crs_n','t0',time_dnum(kt),'tend',time_dnum(kt));
        data_z=EHY_getMapModelData(fpath_map,'varName','mesh1d_mor_crs_z','t0',time_dnum(kt),'tend',time_dnum(kt));
        data=cat(1,data_n.val,data_z.val);
        data(data>-999.1 & data<-998.9)=NaN;
        save_check(fpath_mat_tmp,'data'); 
    end                
            
    %% disp
    messageOut(fid_log,sprintf('Reading %s time %4.2f %% variable %4.2f %%',tag,ktc/nt*100));

end



% kbr=0;
% ktc=0;
% kvar=0;
% messageOut(fid_log,sprintf('Reading %s branch %4.2f time %4.2f %% variable %4.2f %%',tag,kbr/nbr*100,ktc/nt*100,kvar/nvar*100));

% for kcrs=1:ncrs
    

%     crs_name=flg_loc.crs_name{kcrs};
%     idx_crs=find(strcmp(crs_name,crs_names));

    
% end

end %function

%%
%% FUNCTIONS
%%

% function idx=find_index_crs_name(crs_name,fpath_map)
    
%     idx=find(strcmp(crs_name,crs_names));
% end