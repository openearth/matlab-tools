%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Creates paths of the project directory

function fpaths=paths_project(fpath_project)

if isunix
    fpath_project=linuxify(fpath_project);
end

fpaths.fdir_doc=fullfile(fpath_project,'04_documents');
    fpaths.fdir_rep=fullfile(fpaths.fdir_doc,'02_report','co');

fpaths.fdir_data=fullfile(fpath_project,'05_data');

fpaths.fdir_sim=fullfile(fpath_project,'06_simulations');
    fpaths.fdir_sim_in=fullfile(fpaths.fdir_sim,'01_input');
    fpaths.fdir_sim_runs=fullfile(fpaths.fdir_sim,'02_runs');
    

    

end %function