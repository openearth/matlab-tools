%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18780 $
%$Date: 2023-03-09 15:28:47 +0100 (do, 09 mrt 2023) $
%$Author: chavarri $
%$Id: D3D_adapt_time.m 18780 2023-03-09 14:28:47Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_adapt_time.m $
%
%Starting from a hydrodynamic SMT simulation with output and a morphodynamic
% SMT simulation with input, analyzes sediment transport offline. 
%
% %hydrograph to analyze
% Qseries=...
% [65,120*2 ;...
% 314,720*2 ;...
% 465,720*2 ;...
% 614,720*2 ;...
% 702,360*2 ;...
% 766,360*2 ;...
% 855,360*2 ;...
% 964,360*2 ;...
% 1139,720;...
% ];
% 
% %morfac to apply to each hydrograph
% MorFac=[...
% 65, 1440;...
% 194, 40 ;...
% 314, 40 ;...
% 465, 40 ;...
% 614, 20 ;...
% 702, 20 ;...
% 766, 10 ;...
% 855, 10 ;...
% 964, 5  ;...
% 1139, 5 ;...
% 1400, 1 ;...
% 1500, 1 ;...
% 1600, 1 ;...
% 1700, 1 ;...
% 1900, 1 ;...
% 2100, 1 ;...
% 2200, 1 ;...
% 2300, 1 ;...
% 2400, 1 ;...
% 2500, 1 ;...
% 2700, 1 ];

function D3D_sediment_transport_offline(fpath_hydro,fpath_morpho,fpath_out,in_plot_sedtrans,Qseries,MorFac)

%% CALC

Qseries_input=readmatrix(fullfile(fpath_hydro,'Qseries.csv'),'FileType','text');

nsim=size(Qseries,1);

tim=NaN(1,nsim);
tim_dtime=NaT(1,nsim+1);
tim_dtime.TimeZone='+00:00';
tim_dtime(1)=datetime(2000,01,01,0,0,0,'timezone','+00:00');
for ksim=1:nsim
    idx_save=ksim-1;
    Q=Qseries(ksim,1);
    idx_c=find(Qseries_input(:,1)==Q)-1;
    
    fpaths_i=fullfile(fpath_hydro,'output',sprintf('%d',idx_c));
    fpaths_o=fullfile(fpath_out,'output',sprintf('%d',idx_save));
    if isfolder(fpaths_o)==0
        % fprintf('%s -> %s \n',fpaths_i,fpaths_o)
        copyfile(fpaths_i,fpaths_o);
    else
        messageOut(NaN,sprintf('Folder with hydro output exists, not copying: %s',fpaths_o))
    end

    %find MorFac
    idx_m=find(MorFac(:,1)==Q);
    tim(ksim)=Qseries(ksim,2).*MorFac(idx_m,2);
    tim_s=tim(ksim)*60;
    tim_dtime(ksim+1)=tim_dtime(ksim)+seconds(tim_s);
end

%Copy last simulation once more. It is not used, but it is needed. 
%See `plot_1D_01`:
%val_tim=data_xvt.(statis)(:,:,1:end-1,:).*repmat(reshape(diff_tim,1,1,[]),nx,nS,1,nD); %we do not use the last value. Block approach with variables 1:end-1 with time 1:end
ksim=nsim+1;
idx_save=ksim-1;
fpaths_i=fullfile(fpath_hydro,'output',sprintf('%d',idx_c)); %last one
fpaths_o=fullfile(fpath_out,'output',sprintf('%d',idx_save));
if isfolder(fpaths_o)==0
    % fprintf('%s -> %s \n',fpaths_i,fpaths_o)
    copyfile(fpaths_i,fpaths_o);
else
    messageOut(NaN,sprintf('Folder with hydro output exists, not copying: %s',fpaths_o))
end

fpath_tim_mat=fullfile(fpath_out,'tim.mat');
if isfile(fpath_tim_mat)==0
    save(fpath_tim_mat,'tim_dtime')
else
    messageOut(NaN,sprintf('File with time exists: %s',fpath_tim_mat));
end

%%

% figure
% plot(tim_dtime,'-*')

%% COPY MORPHO FILES

%% create files

ks=0;

ks=ks+1;
in_plot_hydro_var.fdir_sim{ks}=fpath_morpho; 
in_plot_hydro_var.str_sim{ks}='reference';

in_plot_hydro_var.sim_ref=1;
in_plot_hydro_var.lan='en';
in_plot_hydro_var.tag_serie='01';

tag='fig_map_2DH_01';
in_plot_hydro_var.(tag).do=1;
in_plot_hydro_var.(tag).do_p=0; %regular plot
in_plot_hydro_var.(tag).var={'Ltot','lyrfrac'}; %open D3D_list_of_variables
in_plot_hydro_var.(tag).tim=1;
in_plot_hydro_var.(tag).overwrite=0; %overwrite mat-files

D3D_gdm(in_plot_hydro_var)

%% copy

nvar=numel(in_plot_hydro_var.(tag).var);
fdir_mat=fullfile(fpath_morpho,'mat');
in_plot_fig=gmd_tag(in_plot_hydro_var,tag);
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',in_plot_fig.tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
load(fpath_mat_time,'tim');
tim_hydro=tim.time_dnum(1);

for ksim=1:nsim+1 %this is the number of times in the SMT hydrograph +1, because of the block approach. 

    for kvar=1:nvar
        varname=in_plot_hydro_var.(tag).var{kvar};
        
        fdir_mat=fullfile(fpath_morpho,'mat');
        fpath_mat_tmp_in=mat_tmp_name(fdir_mat,'map_2DH_01','tim',tim_hydro,'var',varname);

        fdir_mat=fullfile(fpath_out,'mat');
        fpath_mat_tmp_out=mat_tmp_name(fdir_mat,'map_2DH_01','tim',datenum(tim_dtime(ksim)),'var',varname);

        if isfile(fpath_mat_tmp_out)==0
            copyfile_check(fpath_mat_tmp_in,fpath_mat_tmp_out,1);
        else
            messageOut(NaN,sprintf('File exists, not copying: %s',fpath_mat_tmp_out));
        end
    end

end

%% CALL SEDIMENT TRANSPORT

%% simulation

ks=0;

ks=ks+1;
in_plot_sedtrans.fdir_sim{ks}=fpath_out; 
in_plot_sedtrans.str_sim{ks}='reference';

tag='fig_map_sedtransoff_01';
in_plot_sedtrans.(tag).tim=tim_dtime;

%%

D3D_gdm(in_plot_sedtrans)

