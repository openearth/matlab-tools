%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20318 $
%$Date: 2025-09-12 14:45:57 +0200 (Fri, 12 Sep 2025) $
%$Author: chavarri $
%$Id: gdm_create_mat_M1D.m 20318 2025-09-12 12:45:57Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_create_mat_M1D.m $
%
%

function [branch_idx,offset,offset_rkm]=gdm_select_edgenode_1D_variable(var_id,gridInfo_br)

switch var_id
    case {'mesh1d_q1','mesh1d_mor_width_u','mesh1d_sbn','mesh1d_sbt','mesh1d_q1_main'}
        branch_idx=gridInfo_br.idx_edge;
        offset=gridInfo_br.offset_edge;
        offset_rkm=gridInfo_br.rkm;
    otherwise
        %It is a bit dangerous because new variables that are actually at
        %links will be set at nodes. 
        branch_idx=gridInfo_br.idx;
        offset=gridInfo_br.offset;
        offset_rkm=gridInfo_br.rkm_edge;
end


end %function
