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

function layer=gdm_station_layer(flg_loc,gridInfo,fpath_his,stations)
    
if isnan(flg_loc.layer)
    layer=gridInfo.no_layers;
elseif isinf(flg_loc.layer)
    data_sal=EHY_getmodeldata(fpath_his,stations,'dfm','varName','sal','layer',[],'t',1);
    layer=find(~isnan(data_sal.val),1,'first');
else
    layer=flg_loc.layer;
end

end %function