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
%based on an existing simulation, adds a cross section at each node.
%
%NOTES:
%   -cross-sections are uniform (same properties except for bed level). 

%% PREAMBLE

clear
clc
fclose all;

%% ADD OET

path_add_fcn='c:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\general\';
addpath(path_add_fcn)
addOET

%% INPUT

    %% paths

path_mdu_ori='c:\Users\chavarri\temporal\210409_webinar_1D\01_simulations\r003\dflowfm\FlowFM.mdu';

% path_map_ori=  'c:\Users\chavarri\temporal\210215_testbench_update\01_simulations\c32_shoal_ds_IBedCond0_us_IBedCond1_toe\002\c32_shoal_ds_IBedCond0_us_IBedCond1_toe\dflowfmoutput\c32_map.nc';

path_sim_upd='C:\Users\chavarri\temporal\210215_testbench_update\01_simulations\c32_shoal_ds_IBedCond0_us_IBedCond1_toe\003\c32_shoal_ds_IBedCond0_us_IBedCond1_toe\';

%% CALC

simdef=D3D_simpath_mdu(path_mdu_ori);

path_csdef_ori=simdef.file.csdef;
path_csloc_ori=simdef.file.csloc;
path_map_ori=simdef.file.map;

[csdef_in,cs_def_ori]=S3_read_crosssectiondefinitions(path_csdef_ori,'file_type',2);
[csloc_in,cs_loc_ori]=S3_read_crosssectiondefinitions(path_csloc_ori,'file_type',3);

% nc_info=ncinfo(path_map_ori);
mesh1d_node_offset=ncread(path_map_ori,'mesh1d_node_offset');
mesh1d_node_branch=ncread(path_map_ori,'mesh1d_node_branch');
mesh1d_flowelem_bl=ncread(path_map_ori,'mesh1d_flowelem_bl');

idx=find_str_in_cell(var_names,{'network1d_geom_x'});
if isnan(idx)
    old_style=1;
    str_network='network';
else
    old_style=0;
    str_network='network1d';
end
network1d_branch_id=ncread(path_map_ori,sprintf('%s_branch_id',str_network))';

nn=numel(mesh1d_node_branch);

%copy original structure
cs_def_upd=cs_def_ori(1); 
cs_loc_upd=cs_loc_ori(1); 

%reference value
cs_def_ref=cs_def_ori(1); %save it to 
relative_levels=[0,diff(cs_def_ref.levels)];

%interpolation objects minimum elevation for all branches


%interpolation objects maximum elevation for all branches

%interpolation objects x-z-w for all branches


for kn=1:nn
    
    %local names
    br_l=network1d_branch_id(mesh1d_node_branch(kn)+1);
    ch_l=mesh1d_node_offset(kn);
    cs_id_l=sprintf('br_%s_ch_%7.7f',br_l,ch_l);
    
    %interpolate minimum elevation

    %interpolate maximum elevation

    %interpolate x-z-w

    %definition
    cs_def_upd(kn)=cs_def_ref; %copy original
    cs_def_upd(kn).id=cs_id_l; %modify name    
    cs_def_upd(kn).levels=mesh1d_flowelem_bl(kn)+relative_levels; %modify levels
    
    %location
    cs_loc_upd(kn).id=cs_id_l;
    cs_loc_upd(kn).branchId=br_l;
    cs_loc_upd(kn).chainage=ch_l;
    cs_loc_upd(kn).shift=0;
    cs_loc_upd(kn).definitionId=cs_id_l;
       
end

%% write

simdef.D3D.dire_sim=path_sim_upd;
simdef.csd=cs_def_upd;
simdef.csl=cs_loc_upd;

D3D_crosssectiondefinitions(simdef,'check_existing',false);
D3D_crosssectionlocation(simdef,'check_existing',false);

