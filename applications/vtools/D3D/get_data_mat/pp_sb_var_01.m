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
%Postprocessing of summerbed analysis data for each time.

function pp_sb_var_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

flg_loc=gdm_parse_summerbed(flg_loc,simdef);

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fpath_map=simdef.file.map;

%% LOAD TIME

[nt,time_dnum,~,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef);

%% DIMENSION

kt_v=gdm_kt_v(flg_loc,nt); %time index vector
nvar=numel(flg_loc.var);
nrkmv=numel(flg_loc.rkm_name);
nsb=size(flg_loc.sb_pol,1);

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
    sb_pol_loc=flg_loc.sb_pol(ksb,:);
    ispol=cellfun(@(X)~isempty(X),sb_pol_loc);
    npol=sum(ispol);
    if npol>1
        %We rely on being processed first independently.
        continue
    end
    fpath_sb_pol=flg_loc.sb_pol{ksb};
    [~,sb_pol,~]=fileparts(fpath_sb_pol);
    
    for krkmv=1:nrkmv %rkm polygons

        rkm_cen=flg_loc.rkm{krkmv}';
        pol_name=flg_loc.rkm_name{krkmv};

        ktc=0;
        for kt=kt_v %time
            ktc=ktc+1;
                 
            for kvar=1:nvar %variable

                [fpath_mat,fpath_mat_postprocess]=gdm_map_summerbed_mat_name_build(flg_loc,kvar,simdef,fdir_mat,tag,pol_name,time_dnum(kt),sb_pol,gridInfo);

                if exist(fpath_mat_postprocess,'file')==2 && ~flg_loc.overwrite ; continue; end
                
                switch flg_loc.var{kvar}
                    case 'detab_ds'
                        data_raw=load(fpath_mat,'data');
                        val=data_raw.data.val_mean;

                        dx=diff(rkm_cen*1000);
                        detab_dx=NaN(size(val));
                        detab_dx(2:end-1)=(val(3:end)-val(1:end-2))./(dx(1:end-1)+dx(2:end));
                        
                        val_mean=detab_dx; 
                    otherwise
                        if flg_loc.do_val_B_mor(kvar) %multiply value by morphodynamic width
                            data_raw=load(fpath_mat,'data');
                            val=data_raw.data.val_mean;

                            fpath_mat=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pol',pol_name,'var','ba_mor','sb',sb_pol);
                            data_ba_mor=load(fpath_mat,'data');
                            val_mean=val.*data_ba_mor.data.val_sum_length;
                        elseif flg_loc.do_val_B(kvar) %multiply value per width
                            data_raw=load(fpath_mat,'data');
                            val=data_raw.data.val_mean;
                            
                            fpath_mat=gdm_map_summerbed_mat_name('ba',fdir_mat,tag,pol_name,time_dnum(kt),sb_pol);
                            data_ba=load(fpath_mat,'data');
                            val_mean=val.*data_ba.data.val_sum_length;
                        else
                            continue
                        end
                end
                
                %% data
                data=v2struct(val_mean); %#ok

                %% save and disp
                save_check(fpath_mat_postprocess,'data');
                messageOut(fid_log,sprintf('Reading %s sb poly %4.2f %% rkm poly %4.2f %% time %4.2f %% variable %4.2f %%',tag,ksb/nsb*100,krkmv/nrkmv*100,ktc/nt*100,kvar/nvar*100));

            %% BEGIN DEBUG
%             figure
%             hold on
% %             plot(rkm_cen,val)
%             plot(rkm_cen,val_mean)
            %END DEBUG

            end %kvar
        end %kt    
    end %nrkmv
end %ksb

%% SAVE

%only dummy for preventing passing through the function if not overwriting
% data=NaN;
% save(fpath_mat,'data')

end %function

%% 
%% FUNCTION
%%
