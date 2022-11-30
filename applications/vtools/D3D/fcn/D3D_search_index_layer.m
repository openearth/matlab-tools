%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18556 $
%$Date: 2022-11-17 14:41:22 +0100 (Thu, 17 Nov 2022) $
%$Author: chavarri $
%$Id: gdm_read_data_map.m 18556 2022-11-17 13:41:22Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_data_map.m $
%
%

function idx_f=D3D_search_index_layer(data)

idx_f=D3D_search_index_in_dimension(data,'layer');
if isnan(idx_f)
    idx_f=D3D_search_index_in_dimension(data,'bed_layers');
end
if isnan(idx_f)
    idx_f=D3D_search_index_in_dimension(data,'mesh2d_nLayers');
end
if isnan(idx_f)
    error('do not know where to get the layers index');
end

end %function