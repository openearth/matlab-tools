%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18185 $
%$Date: 2022-06-21 13:23:15 +0200 (di, 21 jun 2022) $
%$Author: chavarri $
%$Id: create_mat_default_flags.m 18185 2022-06-21 11:23:15Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_default_flags.m $
%
%Assing default value to structure if it does not exist.

function struct=isfield_default(struct,var,def)

if ~isfield(struct,var)
    struct.(var)=def;
end

end %function