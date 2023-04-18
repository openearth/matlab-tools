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

function plot_map_fraction_cs_01(fid_log,flg_loc,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% PARSE

if isfield(flg_loc,'fig_print')==0
    flg_loc.fig_print=1;
end

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag,'do_p'); if ret; return; end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fdir_fig=fullfile(simdef.file.fig.dir,tag_fig,tag_serie);
mkdir_check(fdir_fig);
runid=simdef.file.runid;
% simdef.file.mat.map_ls_01=fullfile(fdir_mat,'map_ls_01.mat');
% simdef.file.mat.map_ls_01_tim=fullfile(fdir_mat,'map_ls_01_tim.mat');

% simdef.file.fig.map_ls_01=fullfile(fdir_fig,'map_ls_01');

%% PARSE

if isfield(flg_loc,'ylims')==0
    flg_loc.ylims=[NaN,NaN];
    flg_loc.ylims_diff_t=[NaN,NaN];
end

%% TIME

load(fpath_mat_time,'tim');
v2struct(tim); %time_dnum, time_dtime

%% DIMENSIONS

nt=numel(time_dnum);
nvar=numel(flg_loc.var);
nrkm=numel(flg_loc.rkm);
nylims=size(flg_loc.ylims,1);

%% figure

in_p=flg_loc; %attention with unexpected input
in_p.fig_visible=0;

% fext=ext_of_fig(in_p.fig_print);

%% LOOP 

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

% ktc=0; kpli=0; kvar=0;
% messageOut(fid_log,sprintf('Reading %s kt %4.2f %% kpli %4.2f %% kvar %4.2f %%',tag,ktc/nt*100,kpli/npli*100,kvar/nvar*100));

ktc=0;
for kt=kt_v
    ktc=ktc+1;
    for kvar=1:nvar %variable
        
        varname=flg_loc.var{kvar};
        [var_str_read,var_id,var_str_save]=D3D_var_num2str_structure(varname,simdef);

        val_tot=NaN(nrkm,3); %left centre right
        for krkm=1:nrkm
            for kpli=1:3 %left centre right
    
                pliname=sprintf('%04d_%1d',krkm,kpli);
                fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'var',var_str_read,'pli',pliname);
                load(fpath_mat_tmp,'data');

                val_tot(krkm,kpli)=sum(data.val,'omitnan');
            end %kpli
        end %rkm

        fdir_fig_loc=fullfile(fdir_fig,var_str_read);
        mkdir_check(fdir_fig_loc);
        
        in_p.rkm=flg_loc.rkm;
        in_p.val=val_tot;
        in_p.variable=varname;

        %total    
        in_p.is_rel=0;
        fname_noext=fig_name(fdir_fig_loc,tag,varname,runid,time_dnum(kt),var_str_read);
        in_p.fname=fname_noext;  

        fig_map_fraction_cs_01(in_p)

        %relative
        in_p.is_rel=1;
        fname_noext=fig_name(fdir_fig_loc,tag,sprintf('%s_rel',varname),runid,time_dnum(kt),var_str_read);
        in_p.fname=fname_noext;  

        fig_map_fraction_cs_01(in_p)

        %write output adhoc
%         writematrix([flg_loc.rkm',val_tot],'rkm-Q.csv')
%         writematrix([flg_loc.rkm',val_tot./sum(val_tot,2)],'rkm-Qrel.csv')
    end %kvar
end %kt

for kpli=1:npli %variable

end 

end %function

%%
%% FUNCTIONS
%%

function fpath_fig=fig_name(fdir_fig,tag,varname,runid,time_dnum,var_str)

fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s_%s_%s',tag,varname,runid,datestr(time_dnum,'yyyymmddHHMMSS'),var_str));

end