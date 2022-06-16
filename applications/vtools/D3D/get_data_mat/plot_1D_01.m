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

function plot_1D_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;
if isfield(flg_loc,'tag_fig')==0
    tag_fig=tag;
else
    tag_fig=flg_loc.tag_fig;
end

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE


%% PATHS

nS=numel(simdef);
fdir_mat=simdef(1).file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fdir_fig=fullfile(simdef(1).file.fig.dir,tag_fig);
mkdir_check(fdir_fig); %we create it in the loop
runid=simdef(1).file.runid;

%% LOAD

% create_mat_grd(fid_log,flg_loc,simdef)
load(fpath_mat_time,'tim');
v2struct(tim); %time_dnum, time_dtime

%% DIMENSION

nt=size(time_dnum,1);
nvar=numel(flg_loc.var);
nrkmv=numel(flg_loc.rkm_name);
nsb=numel(flg_loc.sb_pol);

%figures
in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;
% in_p.unit={'qsp','qxsp','qysp'};
%             in_p.gen_struct=gen_struct;
in_p.fig_size=[0,0,14.5,12];

% fext=ext_of_fig(in_p.fig_print);

if nS>1
    in_p.leg_str=flg_loc.leg_str;
end

%% LOOP
for ksb=1:nsb

    %summerbed
    fpath_sb_pol=flg_loc.sb_pol{ksb};
    [~,sb_pol,~]=fileparts(fpath_sb_pol);

    for krkmv=1:nrkmv %rkm polygons

        pol_name=flg_loc.rkm_name{krkmv};
        rkmv=gdm_load_rkm_polygons(fid_log,tag,fdir_mat,'','','','',pol_name);

        in_p.s=rkmv.rkm_cen;
        in_p.xlab_str='rkm';
        in_p.xlab_un=1/1000;

        kt_v=gdm_kt_v(flg_loc,nt); %time index vector
%         fpath_file=cell(nt,1); %movie

        for kvar=1:nvar %variable
            [var_str_read,var_id,var_str_save]=D3D_var_num2str_structure(flg_loc.var{kvar},simdef(1));
            
            %time 0
            kt=1;
                %model
            for kS=1:nS    
                fdir_mat=simdef(kS).file.mat.dir;
                fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pol',pol_name,'var',var_str_save,'sb',sb_pol);
                load(fpath_mat_tmp,'data');            
                data_0_loc(kS)=data;
            end
            data_0=data_0_loc;
            
            %skip if multidimentional
            fn_data=fieldnames(data_0(1));
            if size(data_0.(fn_data{1}),2)>1
                messageOut(fid_log,sprintf('Skipping variable with multiple dimensions: %s',var_str_save));
                continue
            end
                
            ktc=0;
            for kt=kt_v %time
                ktc=ktc+1;

                %% load
                for kS=1:nS
                    fdir_mat=simdef(kS).file.mat.dir;
                    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pol',pol_name,'var',var_str_save,'sb',sb_pol);
                    load(fpath_mat_tmp,'data');
                    data_loc(kS)=data;
                end
                data=data_loc;
                
                fn_data=fieldnames(data(1));
                nfn=numel(fn_data);
                
                if flg_loc.tim_type==1
                    in_p.tim=time_dnum(kt);
                elseif flg_loc.tim_type==2
                    in_p.tim=time_mor_dnum(kt);
                end
                
                in_p.lab_str=var_str_save;
                in_p.xlims=flg_loc.xlims;

                for kfn=1:nfn
                    statis=fn_data{kfn};
                    switch statis
                        case 'val_std'
                            in_p.is_std=true;
                        otherwise
                            in_p.is_std=false;
                    end
                    
                    for kref=1:2
                        
                        %measurements                        
                        in_p.plot_mea=false;
                        if isfield(flg_loc,'measurements') && ~isempty(flg_loc.measurements) 
                            tim_search_in_mea=gdm_time_dnum_flow_mor(flg_loc,time_dnum(kt),time_mor_dnum(kt));
                            data_mea=gdm_load_measurements(fid_log,flg_loc.measurements{ksb,1},'tim',tim_search_in_mea,'var',var_str_save,'stat',statis);
                            if isstruct(data_mea) %there is data
                                in_p.plot_mea=true;
                                in_p.s_mea=data_mea.x;
                                if kref==1
                                    in_p.val_mea=data_mea.y;
                                elseif kref==2
                                    tim_search_in_mea=gdm_time_dnum_flow_mor(flg_loc,time_dnum(1),time_mor_dnum(1));
                                    data_mea_0=gdm_load_measurements(fid_log,flg_loc.measurements{ksb,1},'tim',tim_search_in_mea,'var',var_str_save,'stat',statis);
                                    in_p.val_mea=data_mea.y-data_mea_0.y;
                                    %we are assuming <s_mea> is the same
                                end
                            end
                        end
                        
                        if kref==1
                            in_p.val=[data.(statis)];
                            in_p.is_diff=0;
                            str_dir='val';
                        elseif kref==2
                            in_p.val=[data.(statis)]-[data_0.(statis)];
                            in_p.is_diff=1;
                            str_dir='diff';
                        end
                        
                        fdir_fig_loc=fullfile(fdir_fig,sb_pol,pol_name,var_str_save,statis,str_dir);
                        mkdir_check(fdir_fig_loc,fid_log,1,0);

                        fname_noext=fig_name(fdir_fig_loc,tag,runid,time_dnum(kt),var_str_save,statis,sb_pol,kref);
%                         fpath_file{kt}=sprintf('%s%s',fname_noext,fext); %for movie 
                        
                        in_p.fname=fname_noext;
                        
                        fig_1D_01(in_p);
                    end %kref
                    messageOut(fid_log,sprintf('Done plotting figure %s rkm poly %4.2f %% time %4.2f %% variable %4.2f %% statistic %4.2f %%',tag,krkmv/nrkmv*100,ktc/nt*100,kvar/nvar*100,kfn/nfn*100));
                end %kfn

                %BEGIN DEBUG

                %END DEBUG

                %% movie

%                 if isfield(flg_loc,'do_movie')==0
%                     flg_loc.do_movie=1;
%                 end
% 
%                 if flg_loc.do_movie
%                     dt_aux=diff(time_dnum);
%                     dt=dt_aux(1)*24*3600; %[s] we have 1 frame every <dt> seconds 
%                     rat=flg_loc.rat; %[s] we want <rat> model seconds in each movie second
%                     make_video(fpath_file,'frame_rate',1/dt*rat,'overwrite',flg_loc.fig_overwrite);
%                 end


            end %kt
        end %kvar    
    end %nrkmv
end %ksb

end %function

%% 
%% FUNCTION
%%

function fpath_fig=fig_name(fdir_fig,tag,runid,time_dnum,var_str,fn,sb_pol,kref)

% fprintf('fdir_fig: %s \n',fdir_fig);
% fprintf('tag: %s \n',tag);
% fprintf('runid: %s \n',runid);
% fprintf('time_dnum: %f \n',time_dnum);
% fprintf('iso: %s \n',iso);
                
fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s_%s_%s_%s_%02d',tag,runid,datestr(time_dnum,'yyyymmddHHMM'),var_str,fn,sb_pol,kref));

% fprintf('fpath_fig: %s \n',fpath_fig);
end %function

%%

function tim_search_in_mea=gdm_time_dnum_flow_mor(flg_loc,time_dnum,time_mor_dnum)

if flg_loc.tim_type==1
    tim_search_in_mea=time_dnum;
elseif flg_loc.tim_type==2
    tim_search_in_mea=time_mor_dnum;
end

end %function