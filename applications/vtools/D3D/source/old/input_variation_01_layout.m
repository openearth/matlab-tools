%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%This function has the input of the variation

function [input_m,vari_tag]=input_variation_01(path_runs_folder,paths_input_folder,path_input_folder_refmdf)%,path_ref_mor,path_ref_sed)

path_input_folder_refmdf=strrep(path_input_folder_refmdf,'\','/');
if ~isempty(path_input_folder_refmdf) && path_input_folder_refmdf(end)~='/'
    path_input_folder_refmdf(end+1)='/';
end

%%

input_m=struct();

%% colums

%same name as in <simdef> (with '__' where there is substructure). 
%Same order as in <allvari_add>.
fn={'ini__noise_seed','mdf__Tstop','mor__MorFac','mdf__CFL','mor__AShld','mor__AlfaBs','mor__SedThr'}; 

%% initialize

allvari=[];

%% 

variation_c{1}=[0,1]; %ini__noise_seed
variation_c{2}=60*24*3600; %mdf__Tstop
variation_c{3}=10; %mor__MorFac
variation_c{4}=5; %mdf__CFL
variation_c{5}=1; %mor__AShld
variation_c{6}=0; %mor__AlfaBs
variation_c{7}=0; %mor__SedThr

allvari=D3D_apply_variation(allvari,variation_c);

%%

variation_c{1}=[0,1]; %ini__noise_seed
variation_c{2}=365*2*24*3600; %mdf__Tstop
variation_c{3}=10; %mor__MorFac
variation_c{4}=5; %mdf__CFL
variation_c{5}=1; %mor__AShld
variation_c{6}=0; %mor__AlfaBs
variation_c{7}=0; %mor__SedThr

allvari=D3D_apply_variation(allvari,variation_c);

%%

variation_c{1}=[0,1]; %ini__noise_seed
variation_c{2}=365*2*24*3600; %mdf__Tstop
variation_c{3}=1; %mor__MorFac
variation_c{4}=5; %mdf__CFL
variation_c{5}=1; %mor__AShld
variation_c{6}=0; %mor__AlfaBs
variation_c{7}=0; %mor__SedThr

allvari=D3D_apply_variation(allvari,variation_c);

%%

variation_c{1}=[0,1]; %ini__noise_seed
variation_c{2}=365*10*24*3600; %mdf__Tstop
variation_c{3}=1; %mor__MorFac
variation_c{4}=1; %mdf__CFL
variation_c{5}=1; %mor__AShld
variation_c{6}=0; %mor__AlfaBs
variation_c{7}=2e-2; %mor__SedThr

allvari=D3D_apply_variation(allvari,variation_c);

%%

variation_c{1}=[0,1]; %ini__noise_seed
variation_c{2}=365*10*24*3600; %mdf__Tstop
variation_c{3}=10; %mor__MorFac
variation_c{4}=5; %mdf__CFL
variation_c{5}=1/3; %mor__AShld
variation_c{6}=3; %mor__AlfaBs
variation_c{7}=0.15; %mor__SedThr

allvari=D3D_apply_variation(allvari,variation_c);

%% ADD TO MATRIX

nsim=size(allvari,1);
nf=numel(fn);
sim_0=1;

for ksim=1:nsim
    
    for kf=1:nf
        input_m(ksim).(fn{kf})=allvari(ksim,kf);
    end
    
    %% RUN INFO
    
    %adhoc which to run
    dorun=1;
%     if bol_get(ksim)==0
%         dorun=0;
%     end
%     if input_m.sim(ksim).MorFac<2
%         dorun=0;
%     end
    
    sim_num=sim_0+ksim-1;
    
    input_m(ksim).dorun=dorun;
    
    sim_id=sprintf('r%03d',sim_num);
    
    input_m(ksim).runid__num=sim_num;
    input_m(ksim).runid__name=sim_id;
    
    input_m(ksim).D3D__dire_sim=fullfile(path_runs_folder,sim_id);
    
end

end %function 
