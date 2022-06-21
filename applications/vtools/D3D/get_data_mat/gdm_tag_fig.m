%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18002 $
%$Date: 2022-04-28 17:22:57 +0200 (Thu, 28 Apr 2022) $
%$Author: chavarri $
%$Id: plot_his_sal_01.m 18002 2022-04-28 15:22:57Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_his_sal_01.m $
%
%

function [tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc)

tag=flg_loc.tag;
if isfield(flg_loc,'tag_fig')==0
    tag_fig=tag;
else
    tag_fig=flg_loc.tag_fig;
end
tag_serie=flg_loc.tag_serie;

end %function