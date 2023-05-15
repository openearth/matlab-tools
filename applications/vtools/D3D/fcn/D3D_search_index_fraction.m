%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18607 $
%$Date: 2022-12-08 08:02:01 +0100 (do, 08 dec 2022) $
%$Author: chavarri $
%$Id: D3D_search_index_layer.m 18607 2022-12-08 07:02:01Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_search_index_layer.m $
%
%

function idx_f=D3D_search_index_fraction(data)

idx_f=D3D_search_index_in_dimension(data,'sedimentFraction');
if isnan(idx_f)
    idx_f=D3D_search_index_in_dimension(data,'nSedTot');
end
if isnan(idx_f)
    error('do not know where to get the fraction index');
end

end %function