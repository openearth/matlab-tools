%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17522 $
%$Date: 2021-10-18 07:45:10 +0200 (Mon, 18 Oct 2021) $
%$Author: chavarri $
%$Id: D3D_results_time.m 17522 2021-10-18 05:45:10Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_results_time.m $
%
%Analysis of fixed weir
%

% fpath_map='c:\Users\chavarri\checkouts\riverlab\schematic\02_bend_morphodynamics_effect parameters\01_simulations\r003\DFM_OUTPUT_struiksma83\struiksma83_map.nc';
% fpath_dep='c:\Users\chavarri\checkouts\riverlab\schematic\02_bend_morphodynamics_effect parameters\01_simulations\r009\dep.xyz';

function D3D_write_dep_from_map(fpath_map,fpath_dep)

[time_r,time_mor_r,time_dnum,time_dtime]=D3D_results_time(fpath_map,1,NaN);
gridInfo=EHY_getGridInfo(fpath_map,'XYcen');
data_map_etab=EHY_getMapModelData(fpath_map,'varName','mesh2d_mor_bl','t0',time_dnum,'tend',time_dnum,'disp',0);
dep=[gridInfo.Xcen,gridInfo.Ycen,data_map_etab.val'];
D3D_io_input('write',fpath_dep,dep);


