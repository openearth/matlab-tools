%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18780 $
%$Date: 2023-03-09 15:28:47 +0100 (do, 09 mrt 2023) $
%$Author: chavarri $
%$Id: D3D_adapt_time.m 18780 2023-03-09 14:28:47Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_adapt_time.m $
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
[~,idxmax]=max(data.val);
[~,idxmin]=min(data.val);
xm=gridInfo.Xcen([idxmax,idxmin]);
ym=gridInfo.Ycen([idxmax,idxmin]);
fprintf('MAX \n')
fprintf('x = %f \n',xm(1))
fprintf('y = %f \n',ym(1))
fprintf('MIN \n')
fprintf('x = %f \n',xm(2))
fprintf('y = %f \n',ym(2))

end