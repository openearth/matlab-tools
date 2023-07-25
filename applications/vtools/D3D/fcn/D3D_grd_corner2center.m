%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18974 $
%$Date: 2023-05-31 14:56:04 +0200 (Wed, 31 May 2023) $
%$Author: chavarri $
%$Id: fig_1D_01.m 18974 2023-05-31 12:56:04Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/fig_1D_01.m $
%
%Based on cell-corner bed level, compute the cell-centre bed level.

function D3D_grd_corner2center(fpath_net,fpath_out)

%% READ

gridInfo=EHY_getGridInfo(fpath_net,{'XYcor','face_nodes_xy','Z','mesh2d_node_z','face_nodes','XYcen'});

%% CALC

nf=size(gridInfo.face_nodes_x,2);

Zcen=NaN(size(gridInfo.Xcen));
for kf=1:nf
    idx=gridInfo.face_nodes(:,kf);
    idx_nn=idx(~isnan(idx));
    Zcen(kf)=mean(gridInfo.Zcor(idx_nn));
end

%% FILTER

bol_n=isnan(Zcen);

%% WRITE

D3D_io_input('write',fpath_out,[gridInfo.Xcen(~bol_n),gridInfo.Ycen(~bol_n),Zcen(~bol_n)]);

%% PLOT

% figure
% hold on
% scatter(gridInfo.Xcen,gridInfo.Ycen,10,Zcen)
% colorbar

end %function