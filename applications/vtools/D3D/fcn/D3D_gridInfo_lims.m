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

function [xlims,ylims]=D3D_gridInfo_lims(gridInfo)

if isfield(gridInfo,'face_nodes_x')
    xlims=[min(gridInfo.face_nodes_x(:)),max(gridInfo.face_nodes_x(:))];
    ylims=[min(gridInfo.face_nodes_y(:)),max(gridInfo.face_nodes_y(:))];
else
    xlims=[min(gridInfo.Xcor(:)),max(gridInfo.Ycor(:))];
    ylims=[min(gridInfo.Xcor(:)),max(gridInfo.Ycor(:))];
end
