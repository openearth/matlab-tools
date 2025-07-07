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