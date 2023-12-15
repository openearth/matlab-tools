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
%Gives maxium and minimum of a variable in a NC map file

%E.G.:
%
% fpath_nc='p:\dflowfm\users\chavarri\D3DSUPDUSA_279\r002\output\FlowFM_map.nc';
% varname='mesh2d_mor_bl';
% kt=2091;

function D3D_map_max_min(fpath_nc,varname,kt)

gridInfo=EHY_getGridInfo(fpath_nc,'XYcen');
data=EHY_getMapModelData(fpath_nc,'varName',varname,'t',kt);
[max_v,idxmax]=max(data.val);
[min_v,idxmin]=min(data.val);
xm=gridInfo.Xcen([idxmax,idxmin]);
ym=gridInfo.Ycen([idxmax,idxmin]);
fprintf('MAX = %f \n',max_v)
fprintf('x = %f \n',xm(1))
fprintf('y = %f \n',ym(1))
fprintf('MIN = %f \n',min_v)
fprintf('x = %f \n',xm(2))
fprintf('y = %f \n',ym(2))

end