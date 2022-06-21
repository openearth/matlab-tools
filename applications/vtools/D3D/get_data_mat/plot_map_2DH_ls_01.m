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

if isfield(flg_loc,'do_rkm')==0
    if isfield(flg_loc,'fpath_rkm')
        flg_loc.do_rkm=1;
    else
        flg_loc.do_rkm=0;
    end
end

%% TIME

load(fpath_mat_time,'tim');
v2struct(tim); %time_dnum, time_dtime

%% DIMENSIONS

nt=numel(time_dnum);
nvar=numel(flg_loc.var);
npli=numel(flg_loc.pli);
nylims=size(flg_loc.ylims,1);

%% figure
in_p=flg_loc; %attention with unexpected input
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;

fext=ext_of_fig(in_p.fig_print);

%% LOOP TIME

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

ktc=0; kpli=0;
messageOut(fid_log,sprintf('Reading %s pli %4.2f %% kt %4.2f %%',tag,kpli/npli*100,ktc/nt*100));
fpath_file=cell(nt,nylims,npli,nvar);
for kt=kt_v
    ktc=ktc+1;
    
    in_p.tim=time_dnum(kt);
    for kpli=1:npli
        fpath_pli=flg_loc.pli{kpli,1};
        [~,pliname,~]=fileparts(fpath_pli);
        pliname=strrep(pliname,' ','_');
        for kvar=1:nvar %variable
           
            varname=flg_loc.var{kvar};
            var_str=D3D_var_num2str_structure(varname,simdef);
            
            fdir_fig_loc=fullfile(fdir_fig,pliname,var_str);
            mkdir_check(fdir_fig_loc);
            
            fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'var',var_str,'pli',pliname);
            load(fpath_mat_tmp,'data');
            

            
            
            for kylim=1:nylims
                in_p.ylims=flg_loc.ylims(kylim,:);
                if isfield(flg_loc,'xlims')
                    in_p.xlims=flg_loc.xlims(kylim,:);
                else
                    in_p.xlims=[NaN,NaN];
                end
                
                fname_noext=fig_name(fdir_fig_loc,tag,runid,time_dnum(kt),var_str,pliname);
                fpath_file{kt,kylim,kpli,kvar}=sprintf('%s%s',fname_noext,fext); %for movie 

                in_p.fname=fname_noext;
                
                if size(data.val,3)>1
                    in_p.data_ls.sal=data.val;
                    in_p.data_ls.grid=data.gridInfo;
                    in_p.unit=var_str;
                    in_p.clims=[NaN,NaN];
                    if flg_loc.do_rkm
                        in_p.data_ls.grid.Xcor=data.rkm_cor;
                    end
                    
                    fig_map_ls_01(in_p)
                else
                    in_p.lab_str=var_str;
                    if flg_loc.do_rkm
                        in_p.s=data.rkm_cen;
                    else
                        in_p.s=data.Scen;
                    end
                    in_p.val=data.val';
                    
                    fig_1D_01(in_p)
                end
            end
            
            messageOut(fid_log,sprintf('Reading %s kt %4.2f %% kpli %4.2f %% kvar %4.2f %%',tag,ktc/nt*100,kpli/npli*100,kvar/nvar*100));
        end
        


    end
end %kt

%% movies

if isfield(flg_loc,'do_movie')==0
    flg_loc.do_movie=1;
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

function fpath_fig=fig_name(fdir_fig,tag,runid,time_dnum,var_str,pliname)

fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s_%s_%s',tag,runid,datestr(time_dnum,'yyyymmddHHMM'),var_str,pliname));

end