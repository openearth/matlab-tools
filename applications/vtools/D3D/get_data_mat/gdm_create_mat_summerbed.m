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

function gdm_create_mat_summerbed(fid_log,flg_loc,simdef)

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
fpath_rkm=flg_loc.fpath_rkm;

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
    sb_def=gdm_read_summerbed(flg_loc,fid_log,fdir_mat,fpath_sb_pol,fpath_map);

    for krkmv=1:nrkmv %rkm polygons
        
        rkm_name=flg_loc.rkm_name{krkmv};
        rkm_cen=flg_loc.rkm{krkmv}';
        rkm_cen_br=flg_loc.rkm_br{krkmv,1};
        rkm_track=flg_loc.rkm_track{krkmv,1};

        rkmv=gdm_load_rkm_polygons(fid_log,tag,fdir_mat,fpath_map,fpath_rkm,rkm_cen,rkm_cen_br,rkm_name,rkm_track);
        npol=numel(rkmv.rkm_cen);
        pol_name=flg_loc.rkm_name{krkmv};

        ktc=0;
        for kt=kt_v %time
            ktc=ktc+1;
                 
            for kvar=1:nvar %variable

                [fpath_mat,~,varname_read_variable,layer,var_idx,sum_var_idx]=gdm_map_summerbed_mat_name_build(flg_loc,kvar,simdef,fdir_mat,tag,pol_name,time_dnum(kt),sb_pol,gridInfo);
                        
                if exist(fpath_mat,'file')==2 && ~flg_loc.overwrite ; continue; end

                %% read data
                data_var=gdm_read_data_map_simdef(fdir_mat,simdef,varname_read_variable,'tim',time_dnum(kt),'sim_idx',sim_idx(kt),'layer',layer,'var_idx',var_idx,'sum_var_idx',sum_var_idx,'sediment_transport',flg_loc.sediment_transport(kvar));      

                %% calc
                data_var=gdm_order_dimensions(fid_log,data_var,'structure',simdef.D3D.structure);

                ndim_2=size(data_var.val);
                ndim_2=ndim_2(2:end); %vector with dimensions which are not faces
                v_nan=(1:1:numel(ndim_2))+1; %we check the NaN in all dimensions except the first one
                bol_nan=any(isnan(data_var.val),v_nan); %necessary for multidimensional 
                bol_inf=any(isinf(data_var.val),v_nan); %necessary for multidimensional. For sediment transport, a 0 Chezy leads to inf Cf. 

                sval=[npol,ndim_2];
                val_mean=NaN(sval);
                val_std=NaN(sval);
                val_max=NaN(sval);
                val_min=NaN(sval);
                val_num=NaN(sval);
                val_sum=NaN(sval);
                val_sum_length=NaN(sval);
%                 val_width=NaN(npol,ndim_2);
                for kpol=1:npol
                    bol_get=rkmv.bol_pol_loc{kpol} & sb_def.bol_sb & ~bol_nan & ~bol_inf;
                    if any(bol_get)
                        val_mean(kpol,:)=mean(data_var.val(bol_get,:),'omitnan');
                        val_std(kpol,:)=std(data_var.val(bol_get,:),'omitnan');
                        val_max(kpol,:)=max(data_var.val(bol_get,:));
                        val_min(kpol,:)=min(data_var.val(bol_get,:));
                        val_num(kpol,:)=numel(data_var.val(bol_get,:));
                        val_sum(kpol,:)=sum(data_var.val(bol_get,:),1,'omitnan');
                        val_sum_length(kpol,:)=val_sum(kpol,:)./(rkmv.rkm_dx(kpol)*1000);
                        
                        %If you want the flow width, ask for the area (or morpho area) and the width is in <val_sum_length>
                        %this is variable independent. It could be done within an outside loop and saved apart.  
                        %Problem is that it is not a property of the rkmv alone or the sb_def alone. 
%                         val_width(kpol,:)=sum(data_ba.val(bol_get),1,'omitnan')/(rkmv.rkm_dx(kpol)*1000); 
                    end
                    plot_bol_in(flg_loc,simdef,bol_get,gridInfo,rkmv,kpol,sb_pol,pol_name,sb_def);
                    %display
%                     messageOut(NaN,sprintf('Finding mean in polygon %4.2f %%',kpol/npol*100));

%                     %% BEGIN DEBUG
%                     gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);
%                     %%
%                      figure
%                      hold on
%                      scatter(gridInfo.Xcen(:),gridInfo.Ycen(:),10,'b')
% %                      scatter(gridInfo.Xcen,gridInfo.Ycen,10,data_var.val)
% %                      scatter(gridInfo.Xcen(bol_get),gridInfo.Ycen(bol_get),10,'r','filled')   
%                      scatter(gridInfo.Xcen(sb_def.bol_sb),gridInfo.Ycen(sb_def.bol_sb),10,'r','filled')   
%                      axis equal
%                      colorbar
%                     %END DEBUG
                end
                
                %% process

                %% data
                data=v2struct(val_mean,val_std,val_max,val_min,val_num,val_sum,val_sum_length); %#ok

                %% save and disp
                save_check(fpath_mat,'data');
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

%% SAVE

%only dummy for preventing passing through the function if not overwriting
%this is not nice though, because a change in time analysis will not be checked. 
% data=NaN;
% save(fpath_mat,'data')

end %function

%% 
%% FUNCTION
%%

function plot_bol_in(flg_loc,simdef,bol_get,gridInfo,rkmv,kpol,sb_pol,pol_name,sb_def)

%% PARSE

if isfield(flg_loc,'do_plot_inpoly')==0
    flg_loc.do_plot_inpoly=0;
end

if ~flg_loc.do_plot_inpoly
    return
end

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);
% tag_fig=flg_loc.tag;
fdir_fig=fullfile(simdef(1).file.fig.dir,tag_fig,tag_serie); 
fdir_fig_loc=fullfile(fdir_fig,sb_pol,pol_name,'inpoly');
mkdir_check(fdir_fig_loc,NaN,1,0);

%% CALC

in_p=flg_loc;
in_p.bol_get=bol_get;
in_p.gridInfo=gridInfo;
in_p.sb=sb_def.sb;
in_p.tit=sprintf('rkm = %f ',rkmv.rkm_cen(kpol));
in_p.fname=fullfile(fdir_fig_loc,sprintf('%03d',kpol));

fig_inpoly(in_p)

end %function