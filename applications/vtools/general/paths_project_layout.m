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

fpaths.fdir_data=fullfile(fpath_project,'05_data');
    fpaths.fdir_water_balance=fullfile(fpath_project,'01_water_balance');

end %function