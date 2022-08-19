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