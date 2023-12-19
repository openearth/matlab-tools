%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19010 $
%$Date: 2023-06-20 17:14:57 +0200 (Tue, 20 Jun 2023) $
%$Author: kosters $
%$Id: gdm_parse_sediment_transport.m 19010 2023-06-20 15:14:57Z kosters $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_parse_sediment_transport.m $
%
%Empty array of sediment transport

function sediment_transport=gdm_struct_sediment_transport()

sediment_transport=struct('dk',NaN,'sedtrans',NaN,'sedtrans_param',NaN,'sedtrans_hiding',NaN,'sedtrans_hiding_param',NaN,'sedtrans_mu',NaN,'sedtrans_mu_param',NaN);

end