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

function layer=gdm_layer_needed(layer,var_str)

switch var_str
    case {'sal','lyrfrac','thlyr','umag','vpara','vperp','umag_layer'} %needed
%         if isempty(layer)
        if ischar(layer)
            error('A layer number is needed')
        end
    otherwise %not needed
%         layer=[];
        layer='';
end

end %function