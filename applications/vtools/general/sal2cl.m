%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 27 $
%$Date: 2021-09-01 16:22:33 +0200 (Wed, 01 Sep 2021) $
%$Author: chavarri $
%$Id: fig_his_xt.m 27 2021-09-01 14:22:33Z chavarri $
%$HeadURL: file:///P:/11206813-007-kpp2021_rmm-3d/E_Software_Scripts/00_svn/rmm_plot/fig_his_xt.m $
%

function out_val=sal2cl(flg_conv,in_val)

switch flg_conv
    case 1 %sal2cl
        out_val=in_val./1.80655*1000;
    case -1 %cl2sal
        out_val=in_val.*1.80655/1000;
end

end %function