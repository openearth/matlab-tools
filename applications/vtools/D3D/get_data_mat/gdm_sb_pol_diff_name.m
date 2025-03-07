%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20061 $
%$Date: 2025-02-19 20:58:28 +0100 (Wed, 19 Feb 2025) $
%$Author: chavarri $
%$Id: D3D_gdm.m 20061 2025-02-19 19:58:28Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
%
%Create name of difference polygon

function [sb_pol,sb_pol_1,sb_pol_2]=gdm_sb_pol_diff_name(flg_loc,ksb)

ksb_diff=flg_loc.sb_pol_diff{ksb}(1);
fpath_sb_pol=flg_loc.sb_pol{ksb_diff};
[~,sb_pol_1,~]=fileparts(fpath_sb_pol);

ksb_diff=flg_loc.sb_pol_diff{ksb}(2);
fpath_sb_pol=flg_loc.sb_pol{ksb_diff};
[~,sb_pol_2,~]=fileparts(fpath_sb_pol);

sb_pol=sprintf('%s-%s',sb_pol_1,sb_pol_2);

end %function