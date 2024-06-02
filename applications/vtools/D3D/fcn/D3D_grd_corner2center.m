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

function D3D_grd_corner2center(fpath_net,varargin)

[fdir,fname,~]=fileparts(fpath_net);
addOptional(parin,'fpath_out',fullfile(fdir,sprintf('%s.xyz',fname)));
addOptional(parin,'add_header',0)

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
[~,fname_out,fext]=fileparts(fpath_out);
fpath_out_loc=fullfile(pwd,sprintf('%s%s',fname_out,fext));
write_2DMatrix(fpath_out_loc,[gridInfo.Xcen(~bol_n),gridInfo.Ycen(~bol_n),Zcen(~bol_n)],'add_header',add_header);
copyfile_check(fpath_out_loc,fpath_out);
delete(fpath_out_loc)

%% PLOT

% figure
% hold on
% scatter(gridInfo.Xcen,gridInfo.Ycen,10,Zcen)
% colorbar

end %function