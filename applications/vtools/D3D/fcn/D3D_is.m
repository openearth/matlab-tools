%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17180 $
%$Date: 2021-04-12 14:58:48 +0200 (Mon, 12 Apr 2021) $
%$Author: chavarri $
%$Id: NC_read_map.m 17180 2021-04-12 12:58:48Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/NC_read_map.m $
%
%

function [ismor,is1d,str_network1d]=D3D_is(nc_map)

nci=ncinfo(nc_map);

%ismor
idx=find_str_in_cell({nci.Variables.Name},{'mesh2d_mor_bl','mesh1d_mor_bl'});
ismor=1;
if any(isnan(idx))
    ismor=0;
end

%is 1D simulation
idx=find_str_in_cell({nci.Variables.Name},{'mesh2d_node_x'});
is1d=0;
if any(isnan(idx))
    is1d=1;
end
idx=find_str_in_cell({nci.Variables.Name},{'network1d_geom_x'});
if isnan(idx)
    str_network1d='network';
else
    str_network1d='network1d';
end
