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

function in_plot_fig=gdm_check_tag(in_plot,tag_old,tag_check)

in_plot=gdm_check_deprecated_tag(in_plot,tag_old,tag_check);

if isfield(in_plot,tag_check)
    in_plot_fig=gmd_tag(in_plot,tag_check); %is this needed? I think it can be simplified and only take the still-relevant parts of it
end

end %function