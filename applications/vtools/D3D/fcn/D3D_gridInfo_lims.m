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
elseif isfield(gridInfo,'Xcor')
    xlims=[min(gridInfo.Xcor(:)),max(gridInfo.Ycor(:))];
    ylims=[min(gridInfo.Xcor(:)),max(gridInfo.Ycor(:))];
elseif isfield(gridInfo,'offset')
%     error('what to do with rkm')
    xlims=[min(gridInfo.x_node(:)),max(gridInfo.x_node)];
    ylims=[min(gridInfo.y_node(:)),max(gridInfo.y_node)];
end

tol=0.05;
xlims=xlims+diff(xlims).*[-tol,tol]+10*[-eps,eps];
ylims=ylims+diff(ylims).*[-tol,tol]+10*[-eps,eps];

end %function
