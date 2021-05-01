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
%This does A and B
%
%INPUT:
%
%OUTPUT:
%

function [idx_s1,idx_s2,gridInfo]=D3D_reorder_grid(gridInfo_1,gridInfo_2)

[~,idx_s1]=unique([gridInfo_1.face_nodes_x;gridInfo_1.face_nodes_y]','rows');
[~,idx_s2]=unique([gridInfo_2.face_nodes_x;gridInfo_2.face_nodes_y]','rows');

gridInfo.face_nodes_x=gridInfo_1.face_nodes_x(:,idx_s1);
gridInfo.face_nodes_y=gridInfo_1.face_nodes_y(:,idx_s1);

% val_diff=val_1(idx_s1,:)-val_2(idx_s2,:);