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
layer=gdm_layer_needed(layer,var_str);

end %function