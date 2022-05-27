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
fpath_rkm=flg_loc.fpath_rkm;

%% MEASUREMENTS

% %measured bed elevation
% if flg_loc.plot_mea
%     mea_etab=load(fpath_data);
% end
        
%% OVERWRITE

ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% LOAD TIME
if simdef.D3D.structure==4
    fpath_pass=simdef.D3D.dire_sim;
else
    fpath_pass=fpath_map;
end
[nt,time_dnum,~,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time(fid_log,flg_loc,fpath_mat_time,fpath_pass);

%% CONSTANT IN TIME

% gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);

%% DIMENSION

kt_v=gdm_kt_v(flg_loc,nt); %time index vector
nvar=numel(flg_loc.var);
nrkmv=numel(flg_loc.rkm_name);
nsb=numel(flg_loc.sb_pol);

        
%% LOOP


ktc=0;
krkmv=0;
kvar=0;
ksb=0;
messageOut(fid_log,sprintf('Reading %s sb poly %4.2f %% rkm poly %4.2f %% time %4.2f %% variable %4.2f %%',tag,ksb/nsb*100,krkmv/nrkmv*100,ktc/nt*100,kvar/nvar*100));

for ksb=1:nsb

    %summerbed
    fpath_sb_pol=flg_loc.sb_pol{ksb};
    [~,sb_pol,~]=fileparts(fpath_sb_pol);
    sb_def=gdm_read_summerbed(fid_log,fdir_mat,fpath_sb_pol,fpath_map);

    for krkmv=1:nrkmv %rkm polygons

        rkm_name=flg_loc.rkm_name{krkmv};
        rkm_cen=flg_loc.rkm{krkmv}';
        rkm_cen_br=flg_loc.rkm_br{krkmv,1};

        rkmv=gdm_load_rkm_polygons(fid_log,tag,fdir_mat,fpath_map,fpath_rkm,rkm_cen,rkm_cen_br,rkm_name);
        npol=numel(rkmv.rkm_cen);
        pol_name=flg_loc.rkm_name{krkmv};

        ktc=0;
        for kt=kt_v %time
            ktc=ktc+1;
                 
            for kvar=1:nvar %variable
                varname=flg_loc.var{kvar};
                var_str=D3D_var_num2str(varname);

                fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pol',pol_name,'var',var_str,'sb',sb_pol);
                if exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite ; continue; end

                %% read data
                if simdef.D3D.structure==4
                    %this may not be strong enough. It will fail if the run is in path with <\0\> in the name. 
                    fpath_map_loc=strrep(fpath_map,[filesep,'0',filesep],[filesep,num2str(sim_idx(kt)),filesep]); 
                else
                    fpath_map_loc=fpath_map;
                end
                data_var=gdm_read_data_map(fdir_mat,fpath_map_loc,varname,'tim',time_dnum(kt));

                %% calc
                bol_nan=isnan(data_var.val)';

                val_mean=NaN(npol,1);
                val_std=NaN(npol,1);
                val_max=NaN(npol,1);
                val_min=NaN(npol,1);
                val_num=NaN(npol,1);
                for kpol=1:npol
                    bol_get=rkmv.bol_pol_loc{kpol} & sb_def.bol_sb & ~bol_nan;
                    if any(bol_get)
                        val_mean(kpol,1)=mean(data_var.val(bol_get));
                        val_std(kpol,1)=std(data_var.val(bol_get));
                        val_max(kpol,1)=max(data_var.val(bol_get));
                        val_min(kpol,1)=min(data_var.val(bol_get));
                        val_num(kpol,1)=numel(data_var.val(bol_get));
                    end
    %                 messageOut(NaN,sprintf('Finding mean in polygon %4.2f %%',kpol/npol*100));
    %                 %% BEGIN DEBUG
    %                  figure
    %                  hold on
    %                  scatter(gridInfo.Xcen(bol_sb),gridInfo.Ycen(bol_sb),10,data.val(bol_sb))
    %                  axis equal
    %                 %END DEBUG
                end

                %data
                data=v2struct(val_mean,val_std,val_max,val_min,val_num); %#ok

                %% save and disp
                save_check(fpath_mat_tmp,'data');
                messageOut(fid_log,sprintf('Reading %s sb poly %4.2f %% rkm poly %4.2f %% time %4.2f %% variable %4.2f %%',tag,ksb/nsb*100,krkmv/nrkmv*100,ktc/nt*100,kvar/nvar*100));

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
end %ksb

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
