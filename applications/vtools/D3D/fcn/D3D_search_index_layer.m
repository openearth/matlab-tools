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