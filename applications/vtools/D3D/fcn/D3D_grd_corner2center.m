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