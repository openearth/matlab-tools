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
%Find name of observation stations that contains a string.

function out=D3D_observation_stations_find(fpath_his,str)

if isstruct(fpath_his)
    fpath_his=fpath_his.file.his;
end

obs=D3D_observation_stations(fpath_his);
idx=find(contains(lower(obs.name),lower(str)));
nidx=numel(idx);
for kidx=1:nidx
    fprintf('%s\n',obs.name{idx(kidx)});
end
out=obs.name(idx);

end %function