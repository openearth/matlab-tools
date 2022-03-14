%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17773 $
%$Date: 2022-02-18 07:02:30 +0100 (Fri, 18 Feb 2022) $
%$Author: chavarri $
%$Id: D3D_dep_s.m 17773 2022-02-18 06:02:30Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_dep_s.m $
%
%generate depths in rectangular grid 

function D3D_fini_u(simdef)

%%

D3D_ext(simdef);

%% XYcen
fpath_netmap=fullfile(pwd,'tmpgrd_net.nc');
D3D_grd2map(simdef.file.grd,'fpath_map',fpath_netmap);
gridInfo=EHY_getGridInfo(fpath_netmap,{'XYcen','XYcor'});
delete(fpath_netmap);

Xtot=[gridInfo.Xcen;gridInfo.Xcor];
Ytot=[gridInfo.Ycen;gridInfo.Ycor];

%% 

file_name=simdef.file.ini_vx;
matwrite=[Xtot,Ytot,simdef.ini.u.*ones(size(Xtot))];
write_2DMatrix(file_name,matwrite,'check_existing',false);

file_name=simdef.file.ini_vy;
matwrite=[Xtot,Ytot,simdef.ini.v.*ones(size(Xtot))];
write_2DMatrix(file_name,matwrite,'check_existing',false);
  


end %function