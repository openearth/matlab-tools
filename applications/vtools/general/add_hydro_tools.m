%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17432 $
%$Date: 2021-07-28 05:37:56 +0200 (Wed, 28 Jul 2021) $
%$Author: chavarri $
%$Id: bring_data_back_from_cartesius.m 17432 2021-07-28 03:37:56Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/cartesius/matlab/bring_data_back_from_cartesius.m $
%
%Add paths of hydro tools

function add_hydro_tools(path_hyd)

fid_log=NaN;
if exist('update_hydro_tools','file')~=2
    messageOut(fid_log,sprintf('Start adding repository '));
    addpath(genpath(path_hyd)); 
else
    messageOut(fid_log,sprintf('Repository already exists'));
end