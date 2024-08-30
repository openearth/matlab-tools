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

function layer=gdm_station_layer(flg_loc,gridInfo,fpath_his,stations,var_str,elev)
    
if isfield(flg_loc,'layer')==0
    flg_loc.layer=NaN;
end

% layer=[];
layer='';

if isnan(flg_loc.layer)
    layer=gridInfo.no_layers;
elseif isinf(flg_loc.layer)
    data_sal=EHY_getmodeldata(fpath_his,stations,'dfm','varName','sal','layer',[],'t',1);
    layer=find(~isnan(data_sal.val),1,'first');
else
    if isfield(flg_loc,'layer')
        layer=flg_loc.layer;
    end
end

%remove the input if makes no sense. Otherwise the filename has the 'layer'.
layer=gdm_layer_needed(layer,var_str);

%if there is 'elev' we load all layers because we need to match with elevation
if ~isnan(elev)
    layer=[];
end

end %function