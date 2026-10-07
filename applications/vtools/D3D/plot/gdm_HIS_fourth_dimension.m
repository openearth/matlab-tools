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

function ndim4=gdm_HIS_fourth_dimension(flg_loc,gridInfo,simdef)
% Determine the size of the fourth dimension for the given variable
% This is a placeholder function and should be implemented based on the actual variable structure
ndim4=1; % Default value, replace with actual logic if needed

nvar=numel(flg_loc.var);

for kvar=1:nvar %variable
    [var_str_read,var_id]=D3D_var_num2str_structure(flg_loc.var{kvar},simdef);
    
    [~,max_layer]=gdm_layer(flg_loc,gridInfo.no_layers,gridInfo.no_bed_layers,var_str_read,kvar,flg_loc.var{kvar}); %we use <layer> for flow and sediment layers
    if ndim4<max_layer
        ndim4=max_layer;
    end
end

end

