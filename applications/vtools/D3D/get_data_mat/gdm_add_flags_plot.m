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
%Add at the end one more time the default values to the flags for plotting and getting data. 
%This is called after adding one variable to the list of plotting variables. 

function flg_loc=gdm_add_flags_plot(flg_loc)

[vals2add,def_v]=gdm_flags_plot_and_default();

nva=numel(vals2add);
for kva=1:nva
    if isfield(flg_loc,vals2add{kva})
        flg_loc.(vals2add{kva})=cat(2,flg_loc.(vals2add{kva}),def_v{kva});
    else
        error('Field should already exist at this point: %s',vals2add{kva})
    end
end %kva

end %function