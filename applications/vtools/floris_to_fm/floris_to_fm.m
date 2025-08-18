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

function floris=floris_to_fm(fpath_cfg,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fid_log',NaN)
addOptional(parin,'fdir_out',pwd)

parse(parin,varargin{:})

fid_log=parin.Results.fid_log; 
fdir_out=parin.Results.fdir_out;

%% CALC

%% cfg

[floris.cfg,floris.file]=floris_to_fm_read_cfg(fpath_cfg,'fid_log',fid_log);

%% funin

[floris.csd,floris.csd_add]=floris_to_fm_read_funin(floris.file.funin,'fid_log',fid_log);

%% floin

[floris.csl,floris.network.network_node_id,floris.network.network_node_x,floris.network.network_node_y,floris.network.network_branch_id,floris.network.network_edge_nodes]=floris_to_fm_read_floin(floris.file.floin,floris.csd,floris.csd_add,'fid_log',fid_log);

%% create grid

floris.network=floris_to_fm_create_grid(floris.network,floris.csl,floris.csd_add,'fid_log',fid_log);

%% adapt offset of cross-section

floris.csl=floris_to_fm_adapt_offset(floris.network,floris.csl,'fid_log',fid_log);

%% write files

mkdir_check(fdir_out,NaN,1,0); %create output folder if it does not exist

%cross-section location
D3D_io_input('write',fullfile(fdir_out,'csl.ini'),floris.csl,'check_existing',false); 

%cross-section definition
D3D_io_input('write',fullfile(fdir_out,'csd.ini'),floris.csd,'check_existing',false); 

%grid
filename=fullfile(fdir_out,'grd_net.nc'); 
NC_create_1D_grid(filename,floris.network,'fid_log',fid_log);

end %function
