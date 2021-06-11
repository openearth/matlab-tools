%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 24 $
%$Date: 2021-03-26 15:32:11 +0100 (Fri, 26 Mar 2021) $
%$Author: chavarri $
%$Id: main_create_etab_variation_files.m 24 2021-03-26 14:32:11Z chavarri $
%$HeadURL: file:///P:/dflowfm/projects/2020_d-morphology/modellen/3655-sequential-parallel/maas/01_scripts/svn/main_create_etab_variation_files.m $
%

function input_m=input_variation_01_runs_01(paths_input_folder,path_input_folder_refmdf,path_runs_folder)

%% input

sim_0=20; %first simulation to be created

input_m=input_variation_01(paths_input_folder,path_input_folder_refmdf);

%% add info

nsim=numel(input_m.sim);
for ksim=1:nsim
    sim_num=sim_0+ksim-1;
    sim_id=sprintf('r%03d',sim_num);
    
    input_m.sim(ksim).sim_num=sim_num;
    input_m.sim(ksim).sim_id=sim_id;
    input_m.sim(ksim).path_sim=fullfile(path_runs_folder,sim_id);
end

end %function