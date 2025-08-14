%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20235 $
%$Date: 2025-07-07 14:32:25 +0200 (Mon, 07 Jul 2025) $
%$Author: chavarri $
%$Id: D3D_gdm.m 20235 2025-07-07 12:32:25Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
%
%After creating the grid based on the cross-section information, the offset
%of the computational flow nodes changes, as a link is added upstream to
%link branches. Here the offset is corrected. 

function csl=floris_to_fm_adapt_offset(network,csl,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fid_log',NaN)

parse(parin,varargin{:})

fid_log=parin.Results.fid_log; 

%% UNPACK

mesh1d_node_offset=network.mesh1d_node_offset;

%% CALC

csl=struct_assign_val(csl,'chainage',mesh1d_node_offset);

end %function