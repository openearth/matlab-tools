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
