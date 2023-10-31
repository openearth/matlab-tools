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

function gridInfo=gdm_load_grid_simdef(fid_log,simdef,varargin)

fdir_mat=simdef.file.mat.dir;
fpath_map=simdef.file.map;

if simdef.D3D.structure~=3 && simdef.D3D.is1d~=2
    gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map,varargin{:});
else
    gridInfo.no_layers=NaN;
end


