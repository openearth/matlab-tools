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

function create_mat_map_sal_mass_cum_01(fid_log,flg_loc,simdef,var_str)

tag=flg_loc.tag;
tag_loc=strcat(tag,'_cum');

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag_loc); if ret; return; end

%% PARSE

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_loc=fullfile(fdir_mat,sprintf('%s_%s.mat',tag_loc,var_str));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fpath_map=simdef.file.map;

%% OVERWRITE

% [ret,flg_loc]=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat_loc); if ret; return; end
warning('tricky thing. We would like to overwrite if the time of analysis has changed')

%% LOAD TIME

[nt,time_dnum,~]=gdm_load_time(fid_log,flg_loc,fpath_mat_time,fpath_map,fdir_mat);

%% CONSTANT IN TIME

data_ba=gdm_read_data_map(fdir_mat,fpath_map,'mesh2d_flowelem_ba');

%% LOOP

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

ktc=0;
messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,ktc/nt*100));
mass_cum=NaN(nt,1);
for kt=kt_v
    ktc=ktc+1;
%     fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt));
    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'var',var_str);
    data_loc=load(fpath_mat_tmp,'data');
    
    mass_cum(kt,1)=sum(data_loc.data'.*data_ba.val,'omitnan');
    messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,ktc/nt*100));
end    

data.val=mass_cum;
data.unit='sal_mass'; %#ok

save_check(fpath_mat_loc,'data','-v7.3');

end %function

%% 
%% FUNCTION
%%

% function fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,kt)
% 
% fpath_mat_tmp=fullfile(fdir_mat,sprintf('%s_tmp_kt_%04d.mat',tag,kt));
% 
% end %function