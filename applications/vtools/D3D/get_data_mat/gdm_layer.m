%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18257 $
%$Date: 2022-07-22 13:19:06 +0200 (Fri, 22 Jul 2022) $
%$Author: chavarri $
%$Id: create_mat_map_sal_mass_cum_01.m 18257 2022-07-22 11:19:06Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_map_sal_mass_cum_01.m $
%
%

function layer=gdm_layer(flg_loc,no_layers,var_str)
        
if isfield(flg_loc,'layer')==0
    layer=[];
else
    if isnan(flg_loc.layer)
        layer=no_layers;
    else
        layer=flg_loc.layer;
    end
end

%remove the input if makes no sense. Otherwise the filename has the 'layer'.
switch var_str
    case {'clm2'}
        layer=[];
end

end %function