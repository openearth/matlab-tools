%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17345 $
%$Date: 2021-06-11 11:16:16 +0200 (Fri, 11 Jun 2021) $
%$Author: chavarri $
%$Id: input_variation_01_runs_01.m 17345 2021-06-11 09:16:16Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/source/input_variation_01_runs_01.m $
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