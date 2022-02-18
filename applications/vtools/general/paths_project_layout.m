%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17637 $
%$Date: 2021-12-08 22:21:26 +0100 (Wed, 08 Dec 2021) $
%$Author: chavarri $
%$Id: script_layout.m 17637 2021-12-08 21:21:26Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/script_layout.m $
%
%Creates paths pf the project directory

function fpaths=paths_project(fpath_project)

fpaths.fdir_data=fullfile(fpath_project,'05_data');
    fpaths.fdir_water_balance=fullfile(fpath_project,'01_water_balance');

end %function