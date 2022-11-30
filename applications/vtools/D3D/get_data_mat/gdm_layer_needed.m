%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18107 $
%$Date: 2022-06-05 17:19:09 +0200 (Sun, 05 Jun 2022) $
%$Author: chavarri $
%$Id: gdm_station_layer.m 18107 2022-06-05 15:19:09Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_station_layer.m $
%
%

function layer=gdm_layer_needed(layer,var_str)

switch var_str
    case {'sal','lyrfrac','thlyr','umag'} %needed
%         if isempty(layer)
        if ischar(layer)
            error('A layer number is needed')
        end
    otherwise %not needed
%         layer=[];
        layer='';
end

end %function