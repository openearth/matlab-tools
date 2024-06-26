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

function D3D_create_simulation_all(flg,input_m,fcn_adapt,fcn_input_D3D)

%% get only all variations component

if isfield(input_m,'sim')
    input_m_s=input_m.sim;
else
    input_m_s=input_m;
end

%% get main simulation folder

%We assume that all simulationa re in the same folder
fdir_sim_runs=fileparts(input_m_s(1).D3D__dire_sim);

%% save input matrix

mkdir_check(fdir_sim_runs);
fpath_input=fullfile(fdir_sim_runs,'readme.mat');
save(fpath_input,'input_m_s');
D3D_write_readme(input_m_s,'fpath_out',fullfile(fdir_sim_runs,'readme.txt'));

%% run files

[fid_lin,fid_win]=D3D_create_run_batch('open',fdir_sim_runs);

%% loop on simulations

nsim=numel(input_m_s);
for ksim=1:nsim
    
    if input_m_s(ksim).dorun==0; continue; end
    
    %% adapt input
    
%     simdef=fcn_adapt(input_m_s(ksim)); %old
    simdef=D3D_adapt_input(input_m_s(ksim),fcn_adapt,fcn_input_D3D);

    %% create one run

    simdef=D3D_create_simulation(simdef,'only_run_script',flg.only_run_script,'overwrite',flg.overwrite);

    %% run script

    [strsoft_lin,strsoft_win]=D3D_bat(simdef,simdef.file.software,'check_existing',false);    
    D3D_create_run_batch('add',fdir_sim_runs,fid_lin,fid_win,simdef.runid.name,strsoft_lin,strsoft_win);
    
    %% erase run in p and move new
%     fpath_c=input_m.sim(ksim).path_sim;
%     fpath_p=strrep(fpath_c,fdir_project,fdir_project_p);
%     fpath_p_old=strrep(fpath_p,'02_runs','02_runs\00_old');
% %     copyfile_check(fpath_p,fpath_p_old);
%     erase_directory(fpath_p);
%     copyfile_check(fpath_c,fpath_p);
    
end

D3D_create_run_batch('close',fdir_sim_runs,fid_lin,fid_win);

end %function