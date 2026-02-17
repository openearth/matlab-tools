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

function [out,idx]=D3D_observation_stations_find(fpath_his,str,varargin)

parin=inputParser;

addOptional(parin,'sta','obs');

parse(parin,varargin{:});

sta=parin.Results.sta;

%%

if isstruct(fpath_his)
    fpath_his=fpath_his.file.his;
end

obs=D3D_observation_stations(fpath_his,'sta',sta);
idx=find(contains(lower({obs.name}),lower(str)));
nidx=numel(idx);
for kidx=1:nidx
    fprintf('%s, idx=%d\n',obs(idx(kidx)).name, idx(kidx));
end
out={obs(idx).name};

end %function