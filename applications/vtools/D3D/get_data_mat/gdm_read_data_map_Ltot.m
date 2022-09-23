%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18282 $
%$Date: 2022-08-05 16:25:39 +0200 (Fri, 05 Aug 2022) $
%$Author: chavarri $
%$Id: gdm_read_data_map.m 18282 2022-08-05 14:25:39Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_data_map.m $
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