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
%Convert Floris to Delft3D FM model. 

function floris=floris_to_fm(fpath_cfg)

%% PARSE

fid_log=NaN; %file identifier of log. NaN -> screen

%% CALC

%% cfg

[floris.cfg,floris.file]=floris_to_fm_read_cfg(fpath_cfg,'fid_log',fid_log);

%% funin

[floris.csd,floris.csd_add]=floris_to_fm_read_funin(floris.file.funin,'fid_log',fid_log);

%% floin

[floris.csl,floris.network.network_node_id,floris.network.network_node_x,floris.network.network_node_y,floris.network.network_branch_id,floris.network.network_edge_nodes]=floris_to_fm_read_floin(floris.file.floin,floris.csd,floris.csd_add,'fid_log',fid_log);

%% create grid

end %function
