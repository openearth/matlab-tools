%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17477 $
%$Date: 2021-09-09 17:43:43 +0200 (Thu, 09 Sep 2021) $
%$Author: chavarri $
%$Id: D3D_results_time.m 17477 2021-09-09 15:43:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_results_time.m $
%
%

function nt=NC_nt(nc_map)

        nci=ncinfo(nc_map);
        idx_t=find_str_in_cell({nci.Dimensions.Name},{'time'});
        nt=nci.Dimensions(idx_t).Length;
        
end 