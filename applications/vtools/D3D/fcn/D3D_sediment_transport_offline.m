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
%Rather than one SMT simulation with several discharges, the input can also be
%several SMT simulations with one single discharge. In this case, an 
%intermediate step is done in which one single SMT simulation with the last
%discharge folder is created.
%
%INPUT
%   -fpath_hydro  = full path to hydrodynamic SMT simulation [char] or to each hydrodynamic SMT with a constant discharge [cell]
%   -fpath_morpho = full path to morphodynamic SMT simulation [char]  
%   -fpath_out    = full path to output folder [char]
%   -in_plot_sedtrans = structure with input for sediment transport (see `D3D_gdm`) [struct]
%   -Qseries      = matrix with input hydrograph [double(nh,2)]:
%       - (:,1)  = discharge (needs to match `MorFac`)
%       - (:,2)  = time [s]
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

function D3D_sediment_transport_offline(fpath_hydro,fpath_morpho,fpath_out,in_plot_sedtrans,Qseries,MorFac,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'overwrite',0)
addOptional(parin,'time0',datetime(2000,01,01,0,0,0,'timezone','+00:00'))

parse(parin,varargin{:})

overwrite=parin.Results.overwrite;
tim_dtime0=parin.Results.time0;

%% CALC

%% output folder for sediment transport offline

messageOut(NaN,'Start creating output directory',1)

%subfolder <output>
if strcmp(fpath_out(end),filesep)
    fpath_out(end)='';
end
mkdir_check(fpath_out);
fdir_out=fullfile(fpath_out,'output');
mkdir_check(fdir_out);

%dummy <smt.yml> for being identified as SMT
fpath_file=fullfile(fpath_out,'smt.yml');
fid=fopen(fpath_file,'w');
fclose(fid);

%% copy hydrodynamic simulation results

messageOut(NaN,'Start copying hydro simulations',1)

if iscell(fpath_hydro)
    %Rather than one SMT simulation with several discharges, there are several SMT with a single discharge.
    fpath_hydro=create_single_hydro_SMT(fpath_hydro,fpath_out,overwrite);
end

tim_dtime=copy_all_hydro_simulations(fpath_hydro,fpath_out,Qseries,MorFac,overwrite,tim_dtime0);

%%

% figure
% plot(tim_dtime,'-*')

%% create morphodynamic mat-files

messageOut(NaN,'Start creating morpho files',1)

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

%% copy moprhodymamic mat-files

copy_morpho_files(in_plot_hydro_var,tag,fpath_morpho,fpath_out,tim_dtime,overwrite);

%% compute sediment transport offline

messageOut(NaN,'Start sediment transport offline computation',1)

ks=0;

ks=ks+1;
in_plot_sedtrans.fdir_sim{ks}=fpath_out; 
in_plot_sedtrans.str_sim{ks}='reference';

tag='fig_map_sedtransoff_01';
in_plot_sedtrans.(tag).tim=tim_dtime;

D3D_gdm(in_plot_sedtrans)

end %function

%%
%% FUNCTIONS
%%

%%
function copy_hydro_simulation(fpath_hydro,fpath_out,idx_c,idx_save,overwrite)

fpaths_i=fullfile(fpath_hydro,'output',sprintf('%d',idx_c));
fpaths_o=fullfile(fpath_out,'output',sprintf('%d',idx_save));
if isfolder(fpaths_o)==0 || overwrite==1
    copyfile_check(fpaths_i,fpaths_o,1);
else
    messageOut(NaN,sprintf('Folder with hydro output exists, not copying: %s',fpaths_o))
end

end %function 

%%

%Read file <Qseries.csv> and output in [Q,time] format
function Qseries_input=read_Qseries(fpath_hydro)

fpath_Qseries=find_Qseries(fpath_hydro);
Qseries_input=readmatrix(fpath_Qseries,'FileType','text');

%reverse if necessary
fid=fopen(fpath_Qseries);
lin=fgetl(fid);
fclose(fid);
lin_split=deblank(strsplit(lin,','));
if numel(lin_split)~=2
    error('The header of the file has more than 2 items: %s',fpath_Qseries)
end
bol=strcmp(lin_split,{'Discharge','TimeDuration'});
if all(bol==[1,1]) %correct order, nothing to be done

else
    bol=strcmp(lin_split,{'TimeDuration','Discharge'});
    if all(bol==[1,1]) %reversed order, change
        Qseries_input=fliplr(Qseries_input);
    else
        error('Unclear what happens.')
    end
end

end %function

%%

function fpath_out_hydro=create_single_hydro_SMT(fpath_hydro,fpath_out,overwrite)

messageOut(NaN,'A set of hydrodynamic SMT simulations have been identified. Copying to single simulation.')
%create folder to copy the end result of each hydro simulation
fpath_out_hydro=strcat(fpath_out,'_hydro');
mkdir_check(fpath_out_hydro);
fdir_out=fullfile(fpath_out_hydro,'output');

%Qseries of new SMT folder with all hydro results
fpath_Qseries=fullfile(fpath_out_hydro,'Qseries.csv');
fid=fopen(fpath_Qseries,'w');
fprintf(fid,'Discharge,TimeDuration \r\n');

nh=numel(fpath_hydro);
for kh=1:nh
    fpath_hydro_single=fpath_hydro{kh};
    Qseries_input=read_Qseries(fpath_hydro_single);
    nd=size(Qseries_input,1); %number of discharges
    copy_hydro_simulation(fpath_hydro_single,fpath_out_hydro,nd-1,kh-1,overwrite);
    fprintf(fid,'%f,%f \r\n',Qseries_input(end,:));
end %kh

fclose(fid);

end %function

%%

function tim_dtime=copy_all_hydro_simulations(fpath_hydro,fpath_out,Qseries,MorFac,overwrite,tim_dtime0)

%read <Qseries> (Q,time)
Qseries_input=read_Qseries(fpath_hydro);

%preallocate time vector
nsim=size(Qseries,1);
tim=NaN(1,nsim);
tim_dtime=NaT(1,nsim+1);
tim_dtime.TimeZone=tim_dtime0.TimeZone;
tim_dtime(1)=tim_dtime0;

%loop in Qseries input
for ksim=1:nsim
    %find index of hydro simulation to copy
    idx_save=ksim-1;
    Q=Qseries(ksim,1);
    idx_c=find(Qseries_input(:,1)==Q)-1;
    
    if isempty(idx_c)
        error('There is no match for the desired discharge %f',Q)
    end

    if numel(idx_c)>1
        error('There is more than 1 discharge in `QSeries` (%s) that matches the desired discharge %f',fpath_hydro,Q)
    end

    %copy hydro simulation
    copy_hydro_simulation(fpath_hydro,fpath_out,idx_c,idx_save,overwrite);

    %find MorFac
    if ~isnan(MorFac)
        idx_m=find(MorFac(:,1)==Q);
        if isempty(idx_m)
            error('There is no MorFac defined for discharge %f m^3/s',Q)
        end
        MorFac_val=MorFac(idx_m,2);
    else
        MorFac_val=1;
    end

    %add time to time-vector
    tim(ksim)=Qseries(ksim,2).*MorFac_val;
    tim_dtime(ksim+1)=tim_dtime(ksim)+seconds(tim(ksim));

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
%for the case in which we manually create the SMT-like simulation, there
%may not be a correct <Qseries.csv> file. In this case, we either manually
%copy the last simulation or we copy a specific one.
if isempty(idx_c)
    idx_c=idx_def;
    messageOut(NaN,sprintf('There is no index for copying. Copying simulation: %d from %s',idx_c,fpath_hydro));
end
copy_hydro_simulation(fpath_hydro,fpath_out,idx_c,idx_save,overwrite); %using `idx_c` we use the last one

%disp
messageOut(NaN,sprintf('Copied %4.1f %%',ksim/(nsim+1)*100))

%save time result
fpath_tim_mat=fullfile(fpath_out,'tim.mat');
if isfile(fpath_tim_mat)==0
    save(fpath_tim_mat,'tim_dtime')
else
    messageOut(NaN,sprintf('File with time exists: %s',fpath_tim_mat));
end

end %function

%%

function copy_morpho_files(in_plot_hydro_var,tag,fpath_morpho,fpath_out,tim_dtime,overwrite)

messageOut(NaN,'Start copying morpho files',1)

nsim=numel(tim_dtime)-1;
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

    varname_v=in_plot_hydro_var.(tag).var;

    nvar=numel(varname_v);
    for kvar=1:nvar

        varname=varname_v{kvar};
        [~,varname_read_variable,~,~]=D3D_var_num2str(varname); %This is the name used for saving the raw output

        %But for `Ltot`, the variable which is read in raw is different...
        %Not the nicest, but this is what it it. 
        switch varname_read_variable
            case 'Ltot'
                varname_read_variable='mesh2d_thlyr';
        end
        
        %raw
        fdir_mat=fullfile(fpath_morpho,'mat');
        fpath_mat_tmp_in=mat_tmp_name(fdir_mat,varname_read_variable,'tim',tim_hydro);        

        fdir_mat=fullfile(fpath_out,'mat');
        fpath_mat_tmp_out=mat_tmp_name(fdir_mat,varname_read_variable,'tim',datenum(tim_dtime(ksim)));        

        if isfile(fpath_mat_tmp_out)==0 || overwrite
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

end %function

%% 

function fpath_Qseries=find_Qseries(fpath_hydro)

dire=dir(fpath_hydro);
nf=numel(dire);
kf_csv=NaN;
for kf=1:nf
    [~,~,ext]=fileparts(dire(kf).name);
    if strcmp(ext,'.csv')
        if isnan(kf_csv)
            kf_csv=kf;
        else
            error('There is more than one csv-file in folder. I do not know which one is for the Qseries: %s',fpath_hydro)
        end
    end
end
if isnan(kf_csv)
    error('There is no Qseries file in this folder: %s',fpath_hydro)
end
fpath_Qseries=fullfile(fpath_hydro,dire(kf_csv).name);

% fpath_Qseries=fullfile(fpath_hydro,'Qseries.csv');
% if ~exist(fpath_Qseries,'file')
%     error('File Qseries does not exist: %s',fpath_Qseries);
% end

end %function