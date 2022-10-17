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
%

function data=gdm_read_data_map_Ltot(fdir_mat,fpath_map,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'idx_branch',[]);

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
idx_branch=parin.Results.idx_branch;

%% CALC

[ismor,is1d,str_network1d,issus]=D3D_is(fpath_map);
if is1d
    error('make it 1D proof')
end

data=gdm_read_data_map(fdir_mat,fpath_map,'mesh2d_thlyr','tim',time_dnum,'idx_branch',idx_branch); 
data.val=sum(data.val,3);

end %function