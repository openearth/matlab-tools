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

function out=sed_trans_offline(fid_log,flg_loc,fpath_sim,sedTrans,Qseries,MorFac,B,Fak)
switch nargin
    case 7; 
        Fak = NaN; 
    otherwise
        %Fak passed as input
end
tag=flg_loc.tag;

%% PATHS

fdir_mat=fullfile(fpath_sim,'mat');
simdef.D3D.dire_sim=fpath_sim;
simdef=D3D_simpath(simdef);
simdef.file.mat.dir=fdir_mat;

fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');

%% TIME SERIES

[~,time_dnum,~,~,~,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef);

fpath_Qseries=fullfile(fpath_sim,'Qseries.csv');
Qseries_loc=readmatrix(fpath_Qseries);

ns=size(Qseries,1);
mor_tim=NaN(ns,1);
time_dnum_anl=NaN(ns,1);
for ks=1:ns
    idx_m=find(Qseries(ks,1)==MorFac(:,1));
    mor_tim(ks)=Qseries(ks,2)*60*MorFac(idx_m,2);
    
    idx_s=find(Qseries(ks,1)==Qseries_loc(:,1));
    idx_sim=idx_s-1; %starts at 0
    idx_tim=find(sim_idx==idx_sim,1,'last');
    time_dnum_anl(ks)=time_dnum(idx_tim);
    
end
fprintf('days = %f \n',sum(mor_tim)./3600/24);

time_dnum=time_dnum_anl;
nt=numel(time_dnum);

%% PARSE


%% MORPHO

dk=D3D_read_sed(simdef.file.sed);
        
mor=D3D_io_input('read',simdef.file.mor);
Thresh=mor.Morphology0.Thresh;

cnt.g=9.81;
cnt.rho_w=1000;
cnt.R=1.65;
cnt.p=0.4;

flg.vp=1;
flg.E=1;
flg.friction_closure=1;
flg.friction_input=1;

Gammak=NaN(size(dk));
E_param=[0.0199,1.5]; %FLvB
vp_param=[11.5,0.7]; %FLvB

%make the input with ELV style and pass the parsing function.
%input = add_sedflags(input,fid_log)

flg.mu=1;
flg.mu_param=sedTrans.ripple_factor;
flg.Dm=2;
flg.extra=0;
flg.particle_activity=0;
flg.sed_trans=sedTrans.sed_trans;
flg.hiding=sedTrans.hiding;
sed_trans_param=sedTrans.sed_trans_param;
hiding_param=sedTrans.hiding_param;
mor_fac=1;

%% OVERWRITE

% ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat,'overwrite_tim'); if ret; return; end


%% CONSTANT IN TIME

% gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);

%% DIMENSION

kt_v=gdm_kt_v(flg_loc,nt); %time index vector
nvar=numel(flg_loc.var);
nrkmv=numel(flg_loc.rkm_name);
nsb=numel(flg_loc.sb_pol);
nf=numel(dk);

%% LOOP

ktc=0;
krkmv=0;
kvar=0;
ksb=0;
% messageOut(fid_log,sprintf('Reading %s sb poly %4.2f %% rkm poly %4.2f %% time %4.2f %% variable %4.2f %%',tag,ksb/nsb*100,krkmv/nrkmv*100,ktc/nt*100,kvar/nvar*100));

for ksb=1:nsb

    %summerbed
    fpath_sb_pol=flg_loc.sb_pol{ksb};
    [~,sb_pol,~]=fileparts(fpath_sb_pol);

    for krkmv=1:nrkmv %rkm polygons

        rkm_name=flg_loc.rkm_name{krkmv};
        rkm_cen=flg_loc.rkm{krkmv}';
        rkm_cen_br=flg_loc.rkm_br{krkmv,1};

        pol_name=flg_loc.rkm_name{krkmv};
        nx=numel(rkm_cen);
        
        qbk_all=NaN(nx,nf,nt);
        for kt=kt_v %time
                 
            varname=10;
            var_str=D3D_var_num2str(varname);
            fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pol',pol_name,'var',var_str,'sb',sb_pol);
            load(fpath_mat_tmp,'data');
            u=data.val_mean;

            varname=2;
            var_str=D3D_var_num2str(varname);
            fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pol',pol_name,'var',var_str,'sb',sb_pol);
            load(fpath_mat_tmp,'data');
            h=data.val_mean;

            varname=27;
            var_str=D3D_var_num2str(varname);
            fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pol',pol_name,'var',var_str,'sb',sb_pol);
            load(fpath_mat_tmp,'data');
            Ltot=data.val_mean;

            varname=32;
            var_str=D3D_var_num2str(varname);
            fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pol',pol_name,'var',var_str,'sb',sb_pol);
            load(fpath_mat_tmp,'data');
            C=data.val_mean;

            if nargin == 7; 
                varname=8;
                var_str=D3D_var_num2str(varname);
                fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pol',pol_name,'var',var_str,'sb',sb_pol);
                load(fpath_mat_tmp,'data');
                Fak=data.val_mean;
            end
            
            
            q=u.*h;
            cf=cnt.g./C.^2;
            La=ones(size(u));
            Mak=Fak(:,1:end-1);
            
            [qbk,Qbk,thetak,qbk_st,Wk_st,u_st,xik,Qbk_st,Ek,Ek_st,Ek_g,Dk,Dk_st,Dk_g,vpk,vpk_st,Gammak_eq,Dm]=sediment_transport(flg,cnt,h,q,cf,La,Mak,dk,sed_trans_param,hiding_param,mor_fac,E_param,vp_param,Gammak,fid_log,kt);
            
            L_all=min(Ltot/Thresh,1);
            qbk_all(:,:,kt)=L_all.*qbk;
%             qbk_all(:,:,kt)=repmat(L_all,nf).*qbk;
            
        end %kt    
    end %nrkmv
end %ksb

qbk_t=qbk_all.*reshape(mor_tim,1,1,[]);

%%

str_Q=cellfun(@(X)sprintf('%4.0f m^3/s',X),num2cell(Qseries(:,1)),'UniformOutput',false);
str_F=cellfun(@(X)sprintf('%3.1f mm',X),num2cell(dk*1000),'UniformOutput',false);
str_F_sg = {'sand', 'gravel'} 
%%

out.tim=mor_tim;
out.str_Q=str_Q;
out.str_F=str_F;
out.str_F_sg=str_F_sg;
out.rkm=rkm_cen;
out.qbk=qbk_all;
out.qbk_t=qbk_t;
out.qb_t=squeeze(sum(qbk_t,2));
out.qb_f=squeeze(sum(qbk_t,3));
out.qb_f_sg = [sum(out.qb_f(:,dk<0.001),2),sum(out.qb_f(:,dk>=0.001),2)];
out.qb_tot=sum(B.*out.qb_f,2); %total transport including pores per rkm
out.Q=Qseries(:,1);

end %function

%% 
%% FUNCTION
%%
