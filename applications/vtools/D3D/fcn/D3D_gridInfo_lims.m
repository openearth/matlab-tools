%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18016 $
%$Date: 2022-05-03 16:22:21 +0200 (Tue, 03 May 2022) $
%$Author: chavarri $
%$Id: fig_map_sal_01.m 18016 2022-05-03 14:22:21Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/fig_map_sal_01.m $
%

function [xlims,ylims]=D3D_gridInfo_lims(gridInfo)

if isfield(gridInfo,'face_nodes_x')
    xlims=[min(gridInfo.face_nodes_x(:)),max(gridInfo.face_nodes_x(:))];
    ylims=[min(gridInfo.face_nodes_y(:)),max(gridInfo.face_nodes_y(:))];
else
    xlims=[min(gridInfo.Xcor(:)),max(gridInfo.Ycor(:))];
    ylims=[min(gridInfo.Xcor(:)),max(gridInfo.Ycor(:))];
end
