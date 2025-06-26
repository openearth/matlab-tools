%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19787 $
%$Date: 2024-09-19 17:02:24 +0200 (Thu, 19 Sep 2024) $
%$Author: chavarri $
%$Id: gdm_parse_ylims.m 19787 2024-09-19 15:02:24Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_parse_ylims.m $
%
%Create string of colormap and colorbar. diff_t -> cmap_diff_t

function cmap_str=gdm_str_cmap_clim(tag_ref,str_map)

if strcmp(tag_ref,'val')
    tag_ref='';
end
cmap_str=sprintf('%s_%s',str_map,tag_ref);
if strcmp(cmap_str(end),'_')
    cmap_str(end)='';
end

end %function