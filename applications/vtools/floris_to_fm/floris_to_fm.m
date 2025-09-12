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
%Convert Floris to Delft3D FM model. 

function floris=floris_to_fm(fpath_cfg,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fid_log',NaN)
addOptional(parin,'fdir_out',pwd)
addOptional(parin,'write',true)
addOptional(parin,'fname_bc_pump','bc_pump.bc')
addOptional(parin,'fname_bc','bc.bc')
addOptional(parin,'fname_structures','structures.ini')
addOptional(parin,'fname_extn','extn.ext')
addOptional(parin,'fname_csl','csl.ini')
addOptional(parin,'fname_csd','csd.ini')
addOptional(parin,'fname_FrictFile_Channels','roughness-Channels.ini')
addOptional(parin,'fname_FrictFile_Main','roughness-Main.ini')
addOptional(parin,'fname_FrictFile_Sewer','roughness-Sewer.ini')
addOptional(parin,'fname_ini','initialFields.ini')

addOptional(parin,'time_unit','hours')

parse(parin,varargin{:})

fid_log=parin.Results.fid_log; 
fdir_out=parin.Results.fdir_out;
do_write=parin.Results.write;
fname_bc_pump=parin.Results.fname_bc_pump;
fname_bc=parin.Results.fname_bc;
fname_structures=parin.Results.fname_structures;
fname_extn=parin.Results.fname_extn;
fname_csl=parin.Results.fname_csl;
fname_csd=parin.Results.fname_csd;
fname_FrictFile_Channels=parin.Results.fname_FrictFile_Channels;
fname_FrictFile_Main=parin.Results.fname_FrictFile_Main;
fname_FrictFile_Sewer=parin.Results.fname_FrictFile_Sewer;
fname_ini=parin.Results.fname_ini;

time_unit=parin.Results.time_unit; %time unit in BC timeseries
if ~any(strcmpi({'seconds','minutes','hours'},time_unit))
    error('Unknown time unit: %s',time_unit)
end

%% CALC

messageOut(fid_log,'Start conversion',3)

%% cfg

[floris.cfg,floris.file]=floris_to_fm_read_cfg(fpath_cfg,'fid_log',fid_log);

%% funin

[floris.csd,floris.csd_add]=floris_to_fm_read_funin(floris.file.funin,'fid_log',fid_log);

%% floin

[floris.csl,floris.bc,floris.network.network_node_id,floris.network.network_node_x,floris.network.network_node_y,floris.network.network_branch_id,floris.network.network_edge_nodes,floris.structures_at_node,floris.mdf]=floris_to_fm_read_floin(floris.file.floin,floris.csd,floris.csd_add,time_unit,'fid_log',fid_log);

%% create grid

floris.network=floris_to_fm_create_grid(floris.network,floris.csl,floris.csd_add,'fid_log',fid_log);

%% adapt offset of cross-section

floris.csl=floris_to_fm_adapt_offset(floris.network,floris.csl,'fid_log',fid_log);

%% external forcing 

floris.bc=struct_assign_val(floris.bc,'forcingfile',fname_bc); %specify the file in which the BC will be written to refer in the external-forcing file
floris.bc=struct_assign_val(floris.bc,'at_node',1); %as it is a 1D model, the BC is specified at a node and node a pli-file. The trailing `_0001` should not be added. 
floris.ext=D3D_bc_to_ext(floris.bc);

%% structures

floris.structures=floris_to_fm_structures(floris.structures_at_node,floris.network,fname_bc_pump);
[floris.bc_pump,floris.structures]=floris_to_fm_bc_pump(floris.structures,time_unit); %time series of pumps

%% mdu

[floris.mdf,floris.file]=floris_to_fm_mdu(floris.mdf,floris.file,fdir_out,time_unit,fname_structures,fname_extn,fname_csl,fname_csd,fname_FrictFile_Channels,fname_FrictFile_Main,fname_FrictFile_Sewer,fname_ini);

%% friction

%% initial condition

%% write files

if do_write

mkdir_check(fdir_out,NaN,1,0); %create output folder if it does not exist

%cross-section location
D3D_io_input('write',fullfile(fdir_out,fname_csl),floris.csl,'check_existing',false); 

%cross-section definition
D3D_io_input('write',fullfile(fdir_out,fname_csd),floris.csd,'check_existing',false); 

%boundary conditions
D3D_io_input('write',fullfile(fdir_out,fname_bc),floris.bc,'check_existing',false); 

%boundary conditions of pumps
D3D_io_input('write',fullfile(fdir_out,fname_bc_pump),floris.bc_pump,'check_existing',false); 

%external forcing
D3D_io_input('write',fullfile(fdir_out,fname_extn),floris.ext,'check_existing',false); 

%structures
D3D_io_input('write',fullfile(fdir_out,fname_structures),floris.structures,'check_existing',false); 

%friction

%initial condition

%mdu
D3D_mdu(floris);

%grid
filename=fullfile(fdir_out,'grd_net.nc'); 
NC_create_1D_grid(filename,floris.network,'fid_log',fid_log);

end

%% END

messageOut(fid_log,'Finished conversion',3)
end %function
