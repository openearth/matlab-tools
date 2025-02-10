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
%Given a simulation, the grid is modified to replace the bed level by fill
%values and it is executed.
%
%INPUT:
%   - fdir = full path to input simulation; [char]
%
%OUTPUT:
%
%OPTIONAL PAIR INPUT:
%   - 
%
%HISTORY:
%
%This function stems from `getshapefile`, which was a function within the
%script `main02_get_shape_dile.m` in
%<28_get_partition_pli_grave_lith>.

function run_simulation_get_shp(fdir)

simdef=D3D_simpath(fdir);

%overwrite bed level in net file with fill value to allow for maximum
%extent of the cross-section
NC_fillvalue(simdef.file.grd,'mesh2d_node_z');

fpath_xml=fullfile(fdir,'dimr.xml'); 
D3D_dimr_config(fpath_xml,simdef.file.mdfid,1)
D3D_run_dimr(fdir,'fpath_xml',fpath_xml)

end %function