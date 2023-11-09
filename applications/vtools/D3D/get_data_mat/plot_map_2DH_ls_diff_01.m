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

function plot_map_2DH_ls_diff_01(fid_log,flg_loc,simdef_ref,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

if contains(tag_fig,'all')
    tag_do='do_s_all';
else
    tag_do='do_s';
end
ret=gdm_do_mat(fid_log,flg_loc,tag,tag_do); if ret; return; end

%% PARSE

% tol_tim=1; %tolerance to match objective day with available day
% if isfield(flg_loc,'tol_tim')
%     tol_tim=flg_loc.tol_tim;
% end

if isfield(flg_loc,'tol')==0
    flg_loc.tol=30;
end

if isfield(flg_loc,'fig_print')==0
    flg_loc.fig_print=1;
end

if isfield(flg_loc,'plot_val0')==0
    flg_loc.plot_val0=0;
end

if isfield(flg_loc,'do_rkm')==0
    if isfield(flg_loc,'fpath_rkm')
        flg_loc.do_rkm=1;
    else
        flg_loc.do_rkm=0;
    end
end

if isfield(flg_loc,'do_staircase')==0
    flg_loc.do_staircase=0;
end

flg_loc=gdm_parse_diff_input(flg_loc);

%% PATHS

nS=numel(simdef);
fdir_mat_ref=simdef_ref.file.mat.dir;
fpath_mat_ref=fullfile(fdir_mat_ref,sprintf('%s.mat',tag));
fpath_mat_time_ref=strrep(fpath_mat_ref,'.mat','_tim.mat'); 

if nS==1
    fdir_fig=fullfile(simdef.file.fig.dir,tag_fig,tag_serie);
    runid=sprintf('%s-%s',simdef.file.runid,simdef_ref.file.runid);
else
    fdir_fig=fullfile(simdef_ref.file.fig.dir,tag_fig,tag_serie);
    runid=sprintf('ref_%s',simdef_ref.file.runid);
end
mkdir_check(fdir_fig);
% fpath_map_ref=simdef_ref.file.map;
% fpath_map=simdef_ref.file.map;
% runid_ref=simdef_ref.file.runid;

%% TIME

tim_ref=load(fpath_mat_time_ref,'tim');
time_dnum_ref=tim_ref.tim.time_dnum;
time_ref_v=gdm_time_dnum_flow_mor(flg_loc,tim_ref.tim.time_dnum,tim_ref.tim.time_mor_dnum); %[nt_ref,1] 

%% DIMENSIONS

nt=numel(time_dnum_ref); %we loop over reference time and match each simulation
nvar=numel(flg_loc.var);
npli=numel(flg_loc.pli);
if isfield(flg_loc,'ylims')==0
    flg_loc.ylims=[NaN,NaN];
end
nylims=size(flg_loc.ylims,1);

%% figure

in_p=flg_loc; %attention with unexpected input
in_p.fig_visible=0;
in_p.is_diff=1;

fext=ext_of_fig(in_p.fig_print);

%% LOOP TIME

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

ktc=0; kpli=0;
messageOut(fid_log,sprintf('Reading %s pli %4.2f %% kt %4.2f %%',tag,kpli/npli*100,ktc/nt*100));
fpath_file=cell(nt,nylims,npli,nvar);
for kt=kt_v %time
    
    ktc=ktc+1;
    time_ref=time_ref_v(kt);
    in_p.tim=time_ref;
                
    for kpli=1:npli %pli
        
        fpath_pli=flg_loc.pli{kpli,1};
        [~,pliname,~]=fileparts(fpath_pli);
        pliname=strrep(pliname,' ','_');
        for kvar=1:nvar %variable
           
            varname=flg_loc.var{kvar};
            var_str=D3D_var_num2str_structure(varname,simdef_ref);
            
            fdir_fig_loc=fullfile(fdir_fig,pliname,var_str);
            mkdir_check(fdir_fig_loc,NaN,1,0);
            
            fpath_mat_tmp=mat_tmp_name(fdir_mat_ref,tag,'tim',time_dnum_ref(kt),'var',var_str,'pli',pliname);
            data_ref=load(fpath_mat_tmp,'data');
            
            if size(data_ref.data.val,3)>1
                messageOut(fid_log,sprintf('Cannot do differences of 2DV plot for variable %s',var_str));
                continue
            end
            
            nx=numel(data_ref.data.val);
            val=NaN(nx,nS);
            for kS=1:nS %simulations
                
                fdir_mat=simdef(kS).file.mat.dir;
                fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
                fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat'); 
                
                tim=load(fpath_mat_time,'tim');
                time_dnum=tim.tim.time_dnum; %time_dnum is the local one
                time_mor_dnum=tim.tim.time_mor_dnum;
                
                %match times
                val(:,kS)=gdm_match_times_diff_val(flg_loc,time_dnum,time_mor_dnum,time_ref,data_ref,fdir_mat,tag,var_str,pliname,simdef_ref);
                
            end %kS
            
            %initial condition
                %reference situation
            fpath_mat_tmp=mat_tmp_name(fdir_mat_ref,tag,'tim',time_dnum_ref(1),'var',var_str,'pli',pliname);
            data_ref_t0=load(fpath_mat_tmp,'data');
            
                %we are taking the last simulation (last loaded time). They should all be the same.
            val0=gdm_match_times_diff_val(flg_loc,time_dnum,time_mor_dnum,time_ref_v(1),data_ref_t0,fdir_mat,tag,var_str,pliname,simdef_ref);
            
            in_p=gdm_s_rkm_cen(in_p,flg_loc,data_ref.data);
            in_p.val=val;
            in_p.val0=val0;
            in_p.lab_str=var_str;
            
            %measurements                        
            in_p.plot_mea=false;
            if isfield(flg_loc,'measurements') && ~isempty(flg_loc.measurements) 
%                 tim_search_in_mea=gdm_time_dnum_flow_mor(flg_loc,time_dnum(kt),time_mor_dnum(kt));
                [tim_dnum_p,~]=gdm_time_flow_mor(flg_loc,simdef_ref,tim_ref.tim.time_dnum(kt),tim_ref.tim.time_dtime(kt),tim_ref.tim.time_mor_dnum(kt),tim_ref.tim.time_mor_dtime(kt));
                data_mea=gdm_load_measurements(fid_log,flg_loc.measurements{kpli,1},'tim',tim_dnum_p,'var',var_str,'stat','val_mean','tol',flg_loc.tol);
                if isstruct(data_mea) %there is data
                    in_p.plot_mea=true;
                    in_p.s_mea=data_ref.data.Scen;
                    in_p.val_mea=D3D_diff_val(data_mea.y,data_ref.data.val,data_mea.x,data_ref.data.Scen);
                end
            end

            for kylim=1:nylims
                in_p.ylims=flg_loc.ylims(kylim,:);

                fname_noext=fig_name(fdir_fig_loc,tag,time_ref,var_str,pliname,kylim,runid);
                fpath_file{kt,kylim,kpli,kvar}=sprintf('%s%s',fname_noext,fext); %for movie 

                in_p.fname=fname_noext;

                fig_1D_01(in_p)
            end
            
            messageOut(fid_log,sprintf('Reading %s kt %4.2f %% kpli %4.2f %% kvar %4.2f %%',tag,ktc/nt*100,kpli/npli*100,kvar/nvar*100));
        end %kvar
    end %kpli
end %kt

%% movies

if isfield(flg_loc,'do_movie')==0
    flg_loc.do_movie=0;
end

if flg_loc.do_movie
    dt_aux=diff(time_dnum);
    dt=dt_aux(1)*24*3600; %[s] we have 1 frame every <dt> seconds 
    rat=flg_loc.rat; %[s] we want <rat> model seconds in each movie second
    for kpli=1:npli
        for kylim=1:nylims
           make_video(fpath_file(:,kylim,kpli),'frame_rate',1/dt*rat,'overwrite',flg_loc.fig_overwrite);
        end
    end
end



end %function

%%
%% FUNCTIONS
%%

%%

function fpath_fig=fig_name(fdir_fig,tag,time_dnum,var_str,pliname,kylim,runid)

fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s_%s_%s_ylim_%02d',tag,runid,datestr(time_dnum,'yyyymmddHHMM'),var_str,pliname,kylim));

end %function

%% 

function val=gdm_match_times_diff_val(flg_loc,time_dnum,time_mor_dnum,time_ref,data_ref,fdir_mat,tag,var_str,pliname,simdef)

%% PARSE

tol_tim=1; %tolerance to match objective day with available day
if isfield(flg_loc,'tol_tim')
    tol_tim=flg_loc.tol_tim;
end

fid_log=NaN;

%% CALC

nx=numel(data_ref.data.val);

% time_loc_v=gdm_time_dnum_flow_mor(flg_loc,time_dnum,time_mor_dnum); %[nt_loc,1]
[tim_dnum_p,~]=gdm_time_flow_mor(flg_loc,simdef,time_dnum,NaT,time_mor_dnum,NaT);

[kt_loc,min_v,flg_found]=absmintol(tim_dnum_p,time_ref,'tol',tol_tim,'do_break',0,'do_disp_list',0,'dnum',1);
if ~flg_found
    messageOut(fid_log,'No available reference data:');
    messageOut(fid_log,sprintf('     reference time   : %s',datestr(time_ref      ,'yyyy-mm-dd HH:MM:SS')));
    messageOut(fid_log,sprintf('     closest   time   : %s',datestr(tim_dnum_p(kt_loc),'yyyy-mm-dd HH:MM:SS')));

    val=NaN(nx,1);
else
    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt_loc),'var',var_str,'pli',pliname);
    data=load(fpath_mat_tmp,'data');

    val=D3D_diff_val(data.data.val,data_ref.data.val,data.data.Scen,data_ref.data.Scen);
    
    %% DEBUG
%     figure
%     hold on
%     plot(data_ref.data.Scen,data_ref.data.val)
%     s=abs((data.data.val(1)-data.data.val(2))/(data.data.Scen(1)-data.data.Scen(2)));
%     etab_ref=data.data.val(end)+s*(data.data.Scen(end)-data.data.Scen');
%     plot(data.data.Scen,data.data.val-etab_ref)
%     plot(data_ref.data.Scen,val)
%     plot(data.data.Scen,data.data.val-data_ref.data.val)
end    

end %function
