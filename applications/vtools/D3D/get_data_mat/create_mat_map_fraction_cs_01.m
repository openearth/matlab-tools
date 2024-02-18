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

function create_mat_map_fraction_cs_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

if isfield(flg_loc,'xy_input_type')==0
    flg_loc.xy_input_type=1; %1=rkm along Rijntakken
end

if isfield(flg_loc,'drkm')==0
    flg_loc.drkm=0.1; %distance along rkm-line to extend upstream and downstream for computing the angle [km]
end

% if isfield(flg_loc,'write_shp')==0
%     flg_loc.write_shp=0;
% end
% if flg_loc.write_shp==1
%     messageOut(fid_log,'You want to write shp files. Be aware it is quite expensive.')
% end

% %add velocity vector to variables if needed
% if isfield(flg_loc,'do_vector')==0
%     flg_loc.do_vector=zeros(1,numel(flg_loc.var));
% end
% 
% if isfield(flg_loc,'var_idx')==0
%     flg_loc.var_idx=cell(1,numel(flg_loc.var));
% end
% var_idx=flg_loc.var_idx;
% 
% if isfield(flg_loc,'tol')==0
%     flg_loc.tol=1.5e-7;
% end
% tol=flg_loc.tol;

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fpath_map=gdm_fpathmap(simdef,0);

%% DIMENSIONS

nvar=numel(flg_loc.var);

%% OVERWRITE

ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% GRIDS

% gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map_grd,'dim',1);

%% POLYGONS AND RKM

sb=D3D_io_input('read',flg_loc.fpath_sb,'xy_only',1);
if isfield(flg_loc,'fpath_wb')
    wb=D3D_io_input('read',flg_loc.fpath_wb,'xy_only',1);
elseif isfield(simdef.file,'enc')
    wb=D3D_io_input('read',simdef.file.enc,'ver',3); %result in array
else
    error('There is no definition of winter bed. Provide either an enclosure file or a file directly as input.')
end

%% LOAD TIME

[nt,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef);

%% LOOP

kt_v=gdm_kt_v(flg_loc,nt); %time index vector
nrkm=numel(flg_loc.rkm);

krkm=0; ktc=0; kvar=0;
messageOut(fid_log,sprintf('Reading %s krkm %4.2f %% kt %4.2f %% kvar %4.2f %%',tag,krkm/nrkm*100,ktc/nt*100,kvar/nvar*100));
for krkm=1:nrkm %rkm
    
    switch flg_loc.xy_input_type
        case {1,2}
            rkm_loc=flg_loc.rkm(krkm); %rkm to take a cross-section

            %branch of the rkm point
            switch flg_loc.xy_input_type
                case 1 
                    br_loc=branch_rijntakken(rkm_loc,flg_loc.br); 
                case 2 
                    br_loc=branch_maas(rkm_loc); 
            end

            xy_loc=convert2rkm(flg_loc.fpath_rkm,rkm_loc,br_loc); %x-y coordinates of the rkm point to take a cross-section
            xy_ds=convert2rkm(flg_loc.fpath_rkm,rkm_loc+flg_loc.drkm,br_loc); %x-y coordinates of a point slightly dowsntream of the rkm point
            xy_us=convert2rkm(flg_loc.fpath_rkm,rkm_loc-flg_loc.drkm,br_loc); %x-y coordinates of a point slightly upstream of the rkm point
            xy_ext=[xy_us;xy_loc;xy_ds]; %polyline along rkm 
        otherwise
            error('do')
    end
    
    %intersection left-right
    [xy_int_sb_L,xy_int_sb_R]=gdm_intersect_rkm_sb(flg_loc,xy_ext,xy_loc,sb);
    [xy_int_wb_L,xy_int_wb_R]=gdm_intersect_rkm_sb(flg_loc,xy_ext,xy_loc,wb);

    pli(:,:,1)=[xy_int_sb_L;xy_int_wb_L]; %left
    pli(:,:,2)=[xy_int_sb_R;xy_int_sb_L]; %centre
    pli(:,:,3)=[xy_int_wb_R;xy_int_sb_R]; %right
    
%     %% BEGIN DEBUG
% 
%     figure
%     hold on
%     axis equal
%     plot(sb(:,1),sb(:,2),'-k');
%     plot(xy_ext(:,1),xy_ext(:,2),'or-')
% 
%     plot(pli_L(:,1),pli_L(:,2),'b')
%     plot(pli_C(:,1),pli_C(:,2),'g')
%     plot(pli_R(:,1),pli_R(:,2),'c')
%     
%     %% END DEBUG
    
    ktc=0;
    for kt=kt_v
        ktc=ktc+1;
        for kvar=1:nvar %variable
            
            varname=flg_loc.var{kvar};
            [var_str_read,var_id,var_str_save]=D3D_var_num2str_structure(varname,simdef);
            
            for kpli=1:3 %left centre right
    
%                 pliname=sprintf('%7.3f_%1d',rkm_loc,kpli);
                pliname=sprintf('%04d_%1d',krkm,kpli);
                fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'var',var_str_read,'pli',pliname);
    
                do_read=1;
                if exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite 
                    do_read=0;
                end
        
                %% read data
                if do_read
                    data=gdm_read_data_map_ls_simdef(fdir_mat,simdef,varname,sim_idx(kt),'pli',pli(:,:,kpli),'pliname',pliname,'tim',time_dnum(kt));%,'tol_t',flg_loc.tol_t,'overwrite',flg_loc.overwrite); %this overwriting flag should be different than the previous
                    data.rkm=rkm_loc;
                    data.br=br_loc;
                    
                    switch var_str_read
                        case 'Q' 
                            data.val_plot=sum(data.val,'omitnan');
                        case 'qsp'
                            bol_in=~isnan(data.val) & abs(data.val)>1e-12;
                            data.val_plot=mean(data.val(bol_in));
                        otherwise
                            error('add')
                    end

                    save_check(fpath_mat_tmp,'data'); 
                end                

                %% disp
                messageOut(fid_log,sprintf('Reading %s krkm %4.2f %% kt %4.2f %% kvar %4.2f %%',tag,krkm/nrkm*100,ktc/nt*100,kvar/nvar*100));
            end %pli
        end %var
    end %kt
end %rkm

%% SAVE

% %only dummy for preventing passing through the function if not overwriting
% data=NaN;
% save(fpath_mat,'data')

end %function

%% 
%% FUNCTION
%%
