%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18209 $
%$Date: 2022-06-29 10:31:50 +0200 (Wed, 29 Jun 2022) $
%$Author: chavarri $
%$Id: mkdir_check.m 18209 2022-06-29 08:31:50Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/mkdir_check.m $
%

function gridInfo=gdm_load_grid_simdef(fid_log,simdef)

fdir_mat=simdef.file.mat.dir;
fpath_map=simdef.file.map;

if simdef.D3D.structure~=3
    gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);
else
    gridInfo=NaN;
end
