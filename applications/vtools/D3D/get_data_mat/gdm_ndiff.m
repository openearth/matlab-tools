%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18344 $
%$Date: 2022-08-31 16:59:35 +0200 (Wed, 31 Aug 2022) $
%$Author: chavarri $
%$Id: create_mat_map_2DH_01.m 18344 2022-08-31 14:59:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_map_2DH_01.m $
%
%

function [ndiff,flg_loc]=gdm_ndiff(flg_loc)

if isfield(flg_loc,'do_diff')==0
    flg_loc.do_diff=1;
end

if flg_loc.do_diff==0
    ndiff=1;
else 
    ndiff=2;
end

end %function