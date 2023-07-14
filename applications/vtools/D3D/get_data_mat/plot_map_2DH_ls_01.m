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

function plot_map_2DH_ls_01(fid_log,flg_loc,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% PARSE

if isfield(flg_loc,'fig_print')==0
    flg_loc.fig_print=1;
end
if isfield(flg_loc,'do_staircase')==0
    flg_loc.do_staircase=0;
end
if isfield(flg_loc,'do_all_t')==0
    flg_loc.do_all_t=0;
end
if isfield(flg_loc,'do_all_s')==0
    flg_loc.do_all_s=0;
end

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag,'do_p'); if ret; return; end

%% PATHS

nS=numel(simdef);
fdir_mat=simdef(1).file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fdir_fig=fullfile(simdef(1).file.fig.dir,tag_fig,tag_serie);
mkdir_check(fdir_fig);
runid=simdef(1).file.runid;
% simdef(1).file.mat.map_ls_01=fullfile(fdir_mat,'map_ls_01.mat');
% simdef(1).file.mat.map_ls_01_tim=fullfile(fdir_mat,'map_ls_01_tim.mat');

% simdef(1).file.fig.map_ls_01=fullfile(fdir_fig,'map_ls_01');

%% PARSE

if isfield(flg_loc,'do_rkm')==0
    if isfield(flg_loc,'fpath_rkm')
        flg_loc.do_rkm=1;
    else
        flg_loc.do_rkm=0;
    end
end

if isfield(flg_loc,'ylims')==0
    flg_loc.ylims=[NaN,NaN];
    flg_loc.ylims_diff_t=[NaN,NaN];
end
if isfield(flg_loc,'ylims_diff_t')==0
    flg_loc.ylims_diff_t=flg_loc.ylims;
end

if isfield(flg_loc,'do_diff')==0
    flg_loc.do_diff=1;
end

if isfield(flg_loc,'tim_type')==0
    flg_loc.tim_type=1;
end

if isfield(flg_loc,'tol')==0
    flg_loc.tol=30;
end

%% TIME

load(fpath_mat_time,'tim');
v2struct(tim); %time_dnum, time_dtime

%% DIMENSIONS

nt=numel(time_dnum);
nvar=numel(flg_loc.var);
npli=numel(flg_loc.pli);
nylims=size(flg_loc.ylims,1);

if flg_loc.do_diff==0
    ndiff=1;
else 
    ndiff=2;
end

%% figure
in_p=flg_loc; %attention with unexpected input
in_p.fig_visible=0;

fext=ext_of_fig(in_p.fig_print);

%% LOOP 

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

ktc=0; kpli=0; kvar=0;
messageOut(fid_log,sprintf('Reading %s kt %4.2f %% kpli %4.2f %% kvar %4.2f %%',tag,ktc/nt*100,kpli/npli*100,kvar/nvar*100));
fpath_file=cell(nt,nylims,npli,nvar,ndiff);

for kpli=1:npli %variable
    fpath_pli=flg_loc.pli{kpli,1};
    [~,pliname,~]=fileparts(fpath_pli);
    pliname=strrep(pliname,' ','_');
    for kvar=1:nvar %variable

        varname=flg_loc.var{kvar};
        [var_str_read,~,var_str_save]=D3D_var_num2str_structure(varname,simdef(1));
        
        %time 1 for reference
        if flg_loc.do_diff %difference in time
            fdir_mat=simdef(1).file.mat.dir; %1 used for reference for all. Should be the same. 
            fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(1),'var',var_str_read,'pli',pliname);
            data_ref=load(fpath_mat_tmp,'data');                
        end

        %preallocate for plotting all times togehter
        if flg_loc.do_all_t
            if flg_loc.do_staircase
                data_all=NaN(nt,numel(data_ref.data.val_staircase));
            else
                data_all=NaN(nt,numel(data_ref.data.val));
            end
        end
        
        ktc=0; 
        for kt=kt_v %time
            ktc=ktc+1;

            switch flg_loc.tim_type
                case 1
                    in_p.tim=time_dnum(kt);
                case 2
                    in_p.tim=time_mor_dnum(kt);
            end
   
            for kS=1:nS
                fdir_mat=simdef(kS).file.mat.dir; %1 used for reference for all. Should be the same. 
                fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'var',var_str_read,'pli',pliname);
                load(fpath_mat_tmp,'data');
            
                %save data for plotting all times togehter. Better not to do it if you don't need it for memory reasons.
                if flg_loc.do_all_t || flg_loc.do_all_s 
                    if flg_loc.do_staircase
                        data_all(kt,:,kS)=data.val_staircase;
                    else
                        data_all(kt,:,kS)=data.val;
                    end
                end

            end
            
            %measurements                        
            in_p.plot_mea=false;
            if isfield(flg_loc,'measurements') && ~isempty(flg_loc.measurements) 
                tim_search_in_mea=gdm_time_dnum_flow_mor(flg_loc,time_dnum(kt),time_mor_dnum(kt));
                data_mea=gdm_load_measurements(fid_log,flg_loc.measurements{kpli,1},'tim',tim_search_in_mea,'var',var_str_save,'stat','val_mean','tol',flg_loc.tol);
                if isstruct(data_mea) %there is data
                    in_p.plot_mea=true;
                    in_p.s_mea=data_mea.x;
                end
            end
                        
            for kylim=1:nylims %ylim
                
                if isfield(flg_loc,'xlims')
                    in_p.xlims=flg_loc.xlims(kylim,:);
                else
                    in_p.xlims=[NaN,NaN];
                end
                
                for kdiff=1:ndiff %diff
                    
                    switch kdiff
                        case 1
                            if flg_loc.do_staircase
                                data_val_p=data.val_staircase;
                            else
                                data_val_p=data.val;
                            end
                            in_p.ylims=flg_loc.ylims(kylim,:);
                            in_p.is_diff=0;
                            tag_ref='val';
                        case 2
                            if flg_loc.do_staircase
                                data_val_p=data.val_staircase;
                            else
                                data_val_p=data.val-data_ref.data.val;
                            end
                            in_p.ylims=flg_loc.ylims_diff_t(kylim,:);
                            in_p.is_diff=1;
                            tag_ref='diff';
                    end
                    
                    fdir_fig_loc=fullfile(fdir_fig,pliname,var_str_read,tag_ref);
                    mkdir_check(fdir_fig_loc,NaN,1,0);

                    fname_noext=fig_name(fdir_fig_loc,tag,runid,time_dnum(kt),var_str_read,pliname,kdiff,kylim);
                    fpath_file{kt,kylim,kpli,kvar,kdiff}=sprintf('%s%s',fname_noext,fext); %for movie 

                    in_p.fname=fname_noext;

                    %measurements
                    if in_p.plot_mea
                        if kdiff==1
                            in_p.val_mea=data_mea.y;
                        elseif kdiff==2
                            tim_search_in_mea=gdm_time_dnum_flow_mor(flg_loc,time_dnum(1),time_mor_dnum(1));
                            data_mea_0=gdm_load_measurements(fid_log,flg_loc.measurements{ksb,1},'tim',tim_search_in_mea,'var',var_str_save,'stat',statis);
                            in_p.val_mea=data_mea.y-data_mea_0.y;
                        end
                    end
                    
                    if size(data.val,3)>1 %several vertical layers (patch plot)
                          %why?  
%                         if kdiff==2
%                             error('not ready')
%                         end
                        in_p.data_ls.sal=data_val_p;
                        in_p.data_ls.grid=data.gridInfo;
                        in_p.unit=var_str_read;
                        in_p.clims=[NaN,NaN];
                        if flg_loc.do_rkm
                            in_p.data_ls.grid.Xcor=data.rkm_cor;
                        end

                        fig_map_ls_01(in_p)
                    else %single layer (line plot)

                        in_p.lab_str=var_str_read;
                        in_p=gdm_s_rkm_cen(in_p,flg_loc,data);
                        in_p.val=data_val_p'; 

                        fig_1D_01(in_p)

                        %all simulations together
                        if flg_loc.do_all_s && nS>1

                            tag_fig=sprintf('%s_%s',flg_loc.tag,'all'); 
                            fdir_fig=fullfile(simdef(1).file.fig.dir,tag_fig,tag_serie);
                            fdir_fig_loc=fullfile(fdir_fig,pliname,var_str_read,tag_ref);
                            mkdir_check(fdir_fig_loc,NaN,1,0);
        
                            fname_noext=fig_name(fdir_fig_loc,tag,runid,time_dnum(kt),var_str_read,pliname,kdiff,kylim);

                            in_p.fname=fname_noext;
                            switch kdiff
                                case 1
                                    in_p.val=squeeze(data_all(kt,:,:));
                                case 2
                                    in_p.val=squeeze(data_all(kt,:,:))-squeeze(data_all(1,:,:));
                            end

                            fig_1D_01(in_p)
                        end
                    end
                end %kdiff
            end %kylim
            
            messageOut(fid_log,sprintf('Reading %s kt %4.2f %% kpli %4.2f %% kvar %4.2f %%',tag,ktc/nt*100,kpli/npli*100,kvar/nvar*100));
        end %kt
        
        %% all times together
        
        if flg_loc.do_all_t
            in_p_all=in_p;
            
            for kylim=1:nylims %ylim
                
                for kdiff=1:ndiff %diff
                    
                    switch kdiff
                        case 1
                            if flg_loc.do_staircase
                                data_val_p=data.val_staircase;
                            else
                                data_val_p=data.val;
                            end
                            in_p_all.ylims=flg_loc.ylims(kylim,:);
                            in_p_all.is_diff=0;
                            tag_ref='val';
                        case 2
                            if flg_loc.do_staircase
                                data_val_p=data.val_staircase;
                            else
                                data_val_p=data.val_staircase-data_ref.data.val_staircase;
                            end
                            in_p_all.ylims=flg_loc.ylims_diff_t(kylim,:);
                            in_p_all.is_diff=1;
                            tag_ref='diff';
                    end

                    fdir_fig_loc=fullfile(fdir_fig,pliname,var_str_read,tag_ref);
                    fname_noext=fig_name(fdir_fig_loc,sprintf('%s_all_t',tag),runid,time_dnum(kt),var_str_read,pliname,kdiff,kylim);

                    in_p_all.fname=fname_noext;
                    in_p_all.val=data_all';
                    in_p_all.clims=[0,days(time_dtime(end)-time_dtime(1))];
                    in_p_all.do_time=1;

                    fig_1D_01(in_p_all)
                end %kdiff
            end %kylim
        end %do_all_t
        
    end %kvar
end %kpli

%% movies

for kvar=1:nvar
    for kpli=1:npli
        for kylim=1:nylims
            for kdiff=1:ndiff
                fpath_mov=fpath_file(:,kylim,kpli,kvar,kdiff);
                gdm_movie(fid_log,flg_loc,fpath_mov,time_dnum);   
            end
        end
    end
end


end %function

%%
%% FUNCTIONS
%%

function fpath_fig=fig_name(fdir_fig,tag,runid,time_dnum,var_str,pliname,kdiff,kylim)

fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s_%s_%s_ref_%02d_ylim_%02d',tag,runid,datestr(time_dnum,'yyyymmddHHMMSS'),var_str,pliname,kdiff,kylim));

end