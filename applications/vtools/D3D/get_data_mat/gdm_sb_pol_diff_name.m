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