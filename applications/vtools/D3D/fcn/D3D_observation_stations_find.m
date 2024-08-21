%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19233 $
%$Date: 2023-11-09 10:23:03 +0100 (Thu, 09 Nov 2023) $
%$Author: chavarri $
%$Id: gdm_load_grid.m 19233 2023-11-09 09:23:03Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_load_grid.m $
%
%Find name of observation stations that contains a string.

function out=D3D_observation_stations_find(fpath_his,str)

if isstruct(fpath_his)
    fpath_his=fpath_his.file.his;
end

obs=D3D_observation_stations(fpath_his);
idx=find(contains(obs.name,str));
nidx=numel(idx);
for kidx=1:nidx
    fprintf('%s\n',obs.name{idx(kidx)});
end
out={obs.name(idx)};

end %function