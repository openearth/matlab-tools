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
%Flags to plot and default values.

function flg_loc=gdm_default_flags(flg_loc)

[vals2add,def_v]=gdm_flags_plot_and_default();

nva=numel(vals2add);
nv=numel(flg_loc.var);
for kva=1:nva
    if isfield(flg_loc,vals2add{kva})
        if nv~=numel(flg_loc.(vals2add{kva}))
            error('Number of elements in flag should be the same as the number of variables: flag %s, number of variables %d, number of elements in flag %d',vals2add{kva},nv,numel(flg_loc.(vals2add{kva})))
        end
    else
        for kv=1:nv
            if iscell(def_v{kva}) %we use a cell to identify that we want to save it as cell. 
                flg_loc.(vals2add{kva}){1,kv}=def_v{kva}{:};
            else
                flg_loc.(vals2add{kva})(1,kv)=def_v{kva};
            end
        end
    end
end %kva

end %function
