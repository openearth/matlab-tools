%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Creates paths pf the project directory

function fpaths=paths_project(fpath_project)

if isunix
    fpath_project=linuxify(fpath_project);
end

fpaths.fdir_sim=fullfile(fpath_project,'06_simulations');
    fpaths.fdir_sim_in=fullfile(fpaths.fdir_sim,'01_input');
    fpaths.fdir_sim_runs=fullfile(fpaths.fdir_sim,'02_runs');
    
fpaths.fdir_data=fullfile(fpath_project,'05_data');
    

end %function