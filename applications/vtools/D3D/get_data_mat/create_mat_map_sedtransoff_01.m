%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18344 $
%$Date: 2022-08-31 16:59:35 +0200 (Wed, 31 Aug 2022) $
%$Author: chavarri $
%$Id: create_mat_map_2DH_01.m 18344 2022-08-31 14:59:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_map_2DH_01.m $
%
%

function create_mat_map_sedtransoff_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

g=9.81; %make input? read from mdu?

if isfield(flg_loc,'do_sb')==0
    flg_loc.do_sb=0;
end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fpath_map=gdm_fpathmap(simdef,0);

%% OVERWRITE

ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% GRID

% gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);

%% GET RAW VARIABLES

var_raw={'mesh2d_umod','mesh2d_czs','h','Ltot','Fak'}; %do not change order, we use it for loading in loop
tag_2DH='fig_map_2DH_01';
in_plot.(tag_2DH).do=1;
in_plot.(tag_2DH).do_p=0; %regular plot
in_plot.(tag_2DH).do_diff=0; %difference initial time
in_plot.(tag_2DH).do_s=0; %difference with reference
in_plot.(tag_2DH).do_s_diff=0; %difference with reference and initial time
in_plot.(tag_2DH).var=var_raw; %open D3D_list_of_variables
in_plot.(tag_2DH).tim=flg_loc.tim; %all times
in_plot.(tag_2DH).order_anl=2; %1=normal; 2=random

D3D_gdm(in_plot)

%% LOAD TIME

[nt,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef);

%% SED MOR

dk=D3D_read_sed(simdef.file.sed);
        
mor=D3D_io_input('read',simdef.file.mor);
Thresh=mor.Morphology0.Thresh;

%% DIMENSIONS

nvar=numel(flg_loc.var);
nst=numel(flg_loc.sedtrans); 
nf=numel(dk);

%% CREATE <qbk>

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

ktc=0;
messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,ktc/nt*100));
for kst=1:nst
    for kt=kt_v
        ktc=ktc+1;
        
        fpath_mat_st=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'var',flg_loc.sedtrans_name{kst});
        
        if exist(fpath_mat_st,'file')==2 && ~flg_loc.overwrite
            continue
        end
        
        for kvar=1:nvar %variable
            varname=var_raw{kvar};
            var_str=D3D_var_num2str_structure(varname,simdef);
            fpath_mat_tmp=mat_tmp_name(fdir_mat,'map_2DH_01','tim',time_dnum(kt),'var',var_str);
            data.(var_raw{kvar})=load(fpath_mat_tmp,'data');
        end
        
        u=data.mesh2d_umod;
        h=data.h;
        C=data.mesh2d_czs;
        Fak=data.Fak; %[nF,nf]
        
        q=u.*h;
        cf=g./C.^2;
        La=ones(size(u));
        Mak=Fak(:,1:end-1);

        [qbk,Qbk,thetak,qbk_st,Wk_st,u_st,xik,Qbk_st,Ek,Ek_st,Ek_g,Dk,Dk_st,Dk_g,vpk,vpk_st,Gammak_eq,Dm]=sediment_transport(flg,cnt,h,q,cf,La,Mak,dk,sed_trans_param,hiding_param,mor_fac,E_param,vp_param,Gammak,fid_log,kt);

        L_all=min(Ltot/Thresh,1);
        data=L_all.*qbk;
        
        save_check(fpath_mat_st,'data')
        
        %% disp
        messageOut(fid_log,sprintf('Reading %s kt %4.2f %% kvar %4.2f %%',tag,ktc/nt*100,kvar/nvar*100));
    end %kt
end %kst

%% SUMMERBED

if flg_loc.do_sb
    
tag_sb='fig_map_summerbed_01';
in_plot_sb.(tag_sb)=flg_loc;
in_plot_sb.(tag_sb).do=1;
in_plot_sb.(tag_sb).do_p=flg_loc.do_sb_p; %regular plot
in_plot_sb.(tag_sb).do_diff=0; %difference initial time
in_plot_sb.(tag_sb).do_s=0; %difference with reference
in_plot_sb.(tag_sb).do_s_diff=0; %difference with reference and initial time
in_plot_sb.(tag_sb).var=flg_loc.sedtrans_name; %open D3D_list_of_variables
in_plot_sb.(tag_sb).tim=flg_loc.tim; %all times
in_plot_sb.(tag_sb).order_anl=2; %1=normal; 2=random
in_plot_sb.(tag_sb).tim_ave=NaN; 

D3D_gdm(in_plot_sb)

end


end %function

%% 
%% FUNCTION
%%
