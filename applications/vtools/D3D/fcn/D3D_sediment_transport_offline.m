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
%Starting from a hydrodynamic SMT simulation with output and a morphodynamic
%SMT simulation with input, analyzes sediment transport offline for a given
%hydrograph and sediment transport parameters. 
%
%The hydrodynamic SMT simulation may have results for a number of discharges
%different than the desired hydrograph for computing sediment transport 
%offline. The right hydrodynamic output is copied to the output folder. 
%The match is done by comparing the input `Qseries` with file <Qseries.csv>
%in the SMT hydrodynamic input simulation. 
%
%INPUT
%   -fpath_hydro  = full path to hydrodynamic SMT simulation [char]
%   -fpath_morpho = full path to morphodynamic SMT simulation [char]  
%   -fpath_out    = full path to output folder [char]
%   -in_plot_sedtrans = structure with input for sediment transport (see `D3D_gdm`) [struct]
%   -Qseries      = matrix with input hydrograph [double(nh,2)]:
%       - (:,1)  = discharge (needs to match `MorFac`)
%       - (:,2)  = time [min]
%   -MorFac      = morphodynamic accelerator factor to apply to the time associated to a discharge [double(nmf,2)] (if NaN, not applied):
%       - (:,1)  = discharge (needs to match `Qseries`)
%       - (:,2)  = MorFac [-]
%
%E.G.:
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

%% OUTPUT FOLDER

messageOut(NaN,'-------')
messageOut(NaN,'Start creating output directory')
messageOut(NaN,'-------')

%subfolder <output>
mkdir_check(fpath_out);
fdir_out=fullfile(fpath_out,'output');
mkdir_check(fdir_out);

%dummy <smt.yml> for being identified as SMT
fpath_file=fullfile(fpath_out,'smt.yml');
fid=fopen(fpath_file,'w');
fclose(fid);

%% COPY HYDRO SIMULATIONS 

messageOut(NaN,'-------')
messageOut(NaN,'Start copying hydro simulations')
messageOut(NaN,'-------')

%read <Qseries>
fpath_Qseries=fullfile(fpath_hydro,'Qseries.csv');
if ~exist(fpath_Qseries,'file')
    error('File Qseries does not exist: %s',fpath_Qseries);
end
Qseries_input=readmatrix(fpath_Qseries,'FileType','text');

%preallocate time vector
nsim=size(Qseries,1);
tim=NaN(1,nsim);
tim_dtime=NaT(1,nsim+1);
tim_dtime.TimeZone='+00:00';
tim_dtime(1)=datetime(2000,01,01,0,0,0,'timezone','+00:00');

%loop in Qseries input
for ksim=1:nsim
    %find index of hydro simulation to copy
    idx_save=ksim-1;
    Q=Qseries(ksim,1);
    idx_c=find(Qseries_input(:,1)==Q)-1;
    
    %copy hydro simulation
    copy_hydro_simulation(fpath_hydro,fpath_out,idx_c,idx_save);

    %find MorFac
    if ~isnan(MorFac)
        idx_m=find(MorFac(:,1)==Q);
        MorFac_val=MorFac(idx_m,2);
    else
        MorFac_val=1;
    end

    %add time to time-vector
    tim(ksim)=Qseries(ksim,2).*MorFac_val;
    tim_s=tim(ksim)*60; %conversion to seconds (input is in minutes)
    tim_dtime(ksim+1)=tim_dtime(ksim)+seconds(tim_s);

    %disp
    messageOut(NaN,sprintf('Copied %4.1f %%',ksim/(nsim+1)*100))
end

%Copy last simulation once more. It is not used, but it is needed. 
%See `plot_1D_01`:
%```
%val_tim=data_xvt.(statis)(:,:,1:end-1,:).*repmat(reshape(diff_tim,1,1,[]),nx,nS,1,nD); %we do not use the last value. Block approach with variables 1:end-1 with time 1:end
%```
ksim=nsim+1;
idx_save=ksim-1;
copy_hydro_simulation(fpath_hydro,fpath_out,idx_c,idx_save); %using `idx_c` we use the last one

%disp
messageOut(NaN,sprintf('Copied %4.1f %%',ksim/(nsim+1)*100))

%save time result
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

messageOut(NaN,'-------')
messageOut(NaN,'Start creating morpho files')
messageOut(NaN,'-------')

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

messageOut(NaN,'-------')
messageOut(NaN,'Start copying morpho files')
messageOut(NaN,'-------')

nvar=numel(in_plot_hydro_var.(tag).var);
fdir_mat=fullfile(fpath_morpho,'mat');
in_plot_fig=gmd_tag(in_plot_hydro_var,tag);
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',in_plot_fig.tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
load(fpath_mat_time,'tim');
tim_hydro=tim.time_dnum(1);

%create <mat> directory in output folder
fdir_mat=fullfile(fpath_out,'mat');
mkdir_check(fdir_mat);

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

%copy folder with sediment input
%
%slightly add-hoc. The sediment input may be referring to a file
%in the <sed> folder. Technically, it could have any name and
%it could not be used although exists. 
%
fdir_sed_in=fullfile(fpath_morpho,'sed');
fdir_sed_out=fullfile(fpath_out,'sed');
if isfolder(fdir_sed_in)
    copyfile_check(fdir_sed_in,fdir_sed_out);
end

%% CALL SEDIMENT TRANSPORT

messageOut(NaN,'-------')
messageOut(NaN,'Start sediment transport offline computation')
messageOut(NaN,'-------')

%% simulation

ks=0;

ks=ks+1;
in_plot_sedtrans.fdir_sim{ks}=fpath_out; 
in_plot_sedtrans.str_sim{ks}='reference';

tag='fig_map_sedtransoff_01';
in_plot_sedtrans.(tag).tim=tim_dtime;

%%

D3D_gdm(in_plot_sedtrans)

end %function

%%
%% FUNCTIONS
%%

%%
function copy_hydro_simulation(fpath_hydro,fpath_out,idx_c,idx_save)

fpaths_i=fullfile(fpath_hydro,'output',sprintf('%d',idx_c));
fpaths_o=fullfile(fpath_out,'output',sprintf('%d',idx_save));
if isfolder(fpaths_o)==0
    % fprintf('%s -> %s \n',fpaths_i,fpaths_o)
    copyfile(fpaths_i,fpaths_o);
else
    messageOut(NaN,sprintf('Folder with hydro output exists, not copying: %s',fpaths_o))
end

end %function 