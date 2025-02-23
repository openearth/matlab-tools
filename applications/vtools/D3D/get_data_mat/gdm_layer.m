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

function layer=gdm_layer(flg_loc,no_layers,var_str,kvar,varname_original)
        
if isfield(flg_loc,'layer')==0
    layer=[];
else
    if iscell(flg_loc.layer)
        layer=flg_loc.layer{kvar};
    else
        if isnan(flg_loc.layer)
            layer=no_layers;
        else
            layer=flg_loc.layer;
        end
    end
end

%remove the input if makes no sense. Otherwise the filename has the 'layer'.
layer=gdm_layer_needed(layer,var_str);

%add the layer if necessary. 
switch varname_original
    case {'La','Fak'} %referring to only active layer (do not add `lyrfrac` or similar, as these are for all layers).
        layer=1;
end

%throw an error if you need to specify a layer
switch varname_original
    case 'umag_layer'
        if isempty(layer)
            error('You need to specify a layer in case of variable %s',varname_original)
        end
end

end %function