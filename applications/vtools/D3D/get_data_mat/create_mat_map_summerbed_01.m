%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18020 $
%$Date: 2022-05-05 08:45:01 +0200 (Thu, 05 May 2022) $
%$Author: chavarri $
%$Id: create_mat_map_q_01.m 18020 2022-05-05 06:45:01Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_map_q_01.m $
%
%

function create_mat_map_summerbed_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fpath_map=simdef.file.map;

%% MEASUREMENTS

% %measured bed elevation
% if flg_loc.plot_mea
%     mea_etab=load(fpath_data);
% end
        
%% OVERWRITE

ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% LOAD TIME

[nt,time_dnum,~,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time(fid_log,flg_loc,fpath_mat_time,fpath_map);

%% CONSTANT IN TIME

%load grid for number of layers
gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);

%summerbed
sb_def=gdm_read_summerbed(fid_log,flg_loc,simdef);
        
%% LOOP

kt_v=gdm_kt_v(flg_loc,nt); %time index vector
nvar=numel(flg_loc.var);
nrkmv=numel(flg_loc.rkm_name);

ktc=0;
messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,ktc/nt*100));
for krkmv=1:nrkmv %rkm polygons
    
    rkm_name=flg_loc.rkm_name{krkmv};
    rkm_cen=flg_loc.rkm{krkmv}';
    rkm_cen_br=flg_loc.rkm_br{krkmv,1};
    
    rkmv=gdm_load_rkm_polygons(fid_log,tag,fdir_mat,fpath_map,fpath_rkm,rkm_cen,rkm_cen_br,rkm_name);
    npol=numel(rkmv.rkm_cen);
    
    for kt=kt_v %time
        ktc=ktc+1;

        for kvar=1:nvar %variable
    %         var_num=flg_loc.var(kvar);
    %         [var_str,lab_str,ylims]=var_num2str(var_num);
            var_str=flg_loc.var{kvar};
            pol_name=flg_loc.rkm_name{krkmv};

            fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pol',pol_name,'var',var_str);
            if exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite ; continue; end

            %% read data
            %fpath_map change to right folder SMT
            data_var=gdm_read_data_map(fdir_mat,fpath_map,var_str,'tim',time_dnum(kt));

            %% calc

            val=NaN(npol,1);
            for kpol=1:npol
                bol_get=rkmv.bol_pol_loc{kpol} & sb_def.bol_sb;
                val(kpol,1)=mean(data_var.val(bol_get),'omitnan');

                messageOut(NaN,sprintf('Finding mean in polygon %4.2f %%',kpol/npol*100));
%                 %% BEGIN DEBUG
%                  figure
%                  hold on
%                  scatter(gridInfo.Xcen(bol_sb),gridInfo.Ycen(bol_sb),10,data.val(bol_sb))
%                  axis equal
%                 %END DEBUG
            end

            %data
            data=v2struct(val); %#ok

            %% save and disp
            save_check(fpath_mat_tmp,'data');
            messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,ktc/nt*100));

        %% BEGIN DEBUG
    %     figure
    %     hold on
    %     plot(thk)
    %     plot(q)
    % plot(raw_ba.val)
    % plot(mass,'-*')
        %END DEBUG

        end %kvar
    end %kt    
end %nrkmv

%% JOIN

%if creating files in parallel, another instance may have already created it.
%
%Not a good idea because of the overwriting flag. Maybe best to join it several times.
%
% if exist(fpath_mat,'file')==2
%     messageOut(fid_log,'Finished looping and mat-file already exist, not joining.')
%     return
% end

% data=struct();

%% first time for allocating

% kt=1;
% fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt));
% tmp=load(fpath_mat_tmp,'data');
% 
% %constant
% 
% %time varying
% nF=size(tmp.data.q_mag,2);
% 
% q_mag=NaN(nt,nF);
% q_x=NaN(nt,nF);
% q_y=NaN(nt,nF);
% 
% %% loop 
% 
% for kt=1:nt
%     fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt));
%     tmp=load(fpath_mat_tmp,'data');
% 
%     q_mag(kt,:)=tmp.data.q_mag;
%     q_x(kt,:)=tmp.data.q_x;
%     q_y(kt,:)=tmp.data.q_y;
% 
% end
% 
% data=v2struct(q_mag,q_x,q_y); %#ok
% save_check(fpath_mat,'data');

end %function

%% 
%% FUNCTION
%%
